import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/character_mapping_service.dart';
import '../../services/quiz_service.dart';
import '../../services/reading_log_service.dart';
import '../../services/story_audio_service.dart';
import '../../services/story_service.dart';
import '../../services/vocabulary_service.dart';
import '../../state/app_state.dart';
import '../../utils/app_config.dart';
import '../../widgets/squash_stretch_character.dart';
import '../../widgets/story_player/story_canvas_view.dart';
import '../../widgets/story_player/story_firefly_painter.dart';
import '../../widgets/story_player/story_tab_bar.dart';

/// Controller Quan Ly Logic Doc Truyen Tuong Tac (StoryPlayerController)
/// Tuong duong React Hook `useStoryPlayer`:
/// Quan ly am thanh Audio, Truc thoi gian chuyen dong CM, Chuyen trang,
/// Gan vai nhan vat, Do vui (Quiz) & Hoc tu vung (Vocabulary).
class StoryPlayerController extends ChangeNotifier {
  final TickerProvider vsync;
  final Story story;
  final AppState appState;
  final String? readingLogId;
  bool isOriginalTemplate;

  // Trạng thái trang và giao diện
  int currentPageIndex = 0;
  bool isPlayingAudio = false;
  bool showEnglish = true;
  StoryPlayerTab activeTab = StoryPlayerTab.reader;
  List<StoryPage> pages = [];
  bool isLoadingPages = false;

  // Audio Service
  final StoryAudioService audioService = StoryAudioService();
  Duration audioPosition = Duration.zero;
  Duration audioDuration = Duration.zero;
  bool isNarrationActive = false;
  StreamSubscription<Duration>? _audioPosSub;
  StreamSubscription<Duration>? _audioDurSub;
  StreamSubscription<bool>? _audioStateSub;
  StreamSubscription<void>? _audioCompleteSub;
  Timer? _autoAdvanceTimer;
  Timer? _lastPageAudioTimer;
  VoidCallback? onStoryCompleted;

  // Animation & Timeline
  AnimationController? _playheadController;
  double animationDurationMs = 4200.0;
  final List<FireflyParticle> particles = [];
  double screenShakeOffset = 0.0;

  // Character Action & Physics
  AnimationMode animationMode = AnimationMode.stateMachine3D;
  CharacterAction characterAction = CharacterAction.patrol;
  CharacterAction? manualToyAction;
  double manualScaleMultiplier = 1.0;
  bool? manualFlipOverride;
  Offset characterPosition = const Offset(40, 80);
  double characterScale = 1.0;
  bool flipHorizontal = false;

  // CM Slots & Animation Clips
  final Map<String, List<CharacterSlotTemplate>> slotsCacheByPage = {};
  List<CharacterSlotTemplate> activePageSlots = [];
  List<CharacterSlotTemplate> originalPageSlots = [];
  List<CharacterSlotTemplate> previousPageSlots = [];
  List<StoryAnimationClip> activeAnimationClips = [];
  final Set<String> userDraggedSlotIds = {};

  // Vocabularies
  List<VocabularyTemplate> pageVocabularies = [];
  final Map<String, VocabularyTemplate> allStoryVocabularies = {};
  final Set<String> learnedVocabIds = {};
  bool isLoadingVocabularies = false;

  // Quizzes & ReadingLog
  List<StoryQuizTemplate> quizTemplates = [];
  List<QuizQuestion> storyQuizzes = [];
  bool isLoadingQuizzes = false;
  bool isSubmittingTabQuiz = false;
  int currentTabQuizIndex = 0;
  int selectedTabQuizOption = 0;
  bool tabQuizChecked = false;
  bool tabQuizIsCorrect = false;
  int? tabQuizStars;
  String? tabQuizFeedback;
  DateTime tabQuizStartTime = DateTime.now();
  DateTime storySessionStartTime = DateTime.now();
  String? activeReadingLogId;
  Future<ReadingLogSession?>? _startSessionFuture;
  bool isReadingSessionCompleted = false;

  // Roles & Mappings
  List<StoryRoleTemplate> storyRoles = [];
  List<UserStoryCharacterMapping> storyMappings = [];

  StoryPlayerController({
    required this.vsync,
    required this.story,
    required this.appState,
    this.readingLogId,
    this.isOriginalTemplate = false,
  });

  AnimationController get playhead =>
      _playheadController ??= AnimationController(
        vsync: vsync,
        duration: Duration(
          milliseconds: animationDurationMs.round().clamp(600, 30000),
        ),
      )..addListener(() {
          notifyListeners();
        });

  double get playheadMs {
    if (isPlayingAudio && audioPosition > Duration.zero) {
      return audioPosition.inMilliseconds.toDouble();
    }
    return playhead.value * animationDurationMs;
  }

  bool get _needsBackendPagesLoad =>
      story.id.isNotEmpty &&
      (pages.isEmpty ||
          pages.length < story.totalPages ||
          pages.any(
            (p) =>
                p.id == null ||
                !AppConfig.isValidUuid(p.id) ||
                p.id!.startsWith('local-page-') ||
                p.id!.contains('fallback-page') ||
                p.textContent.trim().toLowerCase() == 'string' ||
                p.imageUrl.trim().toLowerCase() == 'string' ||
                p.imageUrl.endsWith('/string') ||
                p.imageUrl.isEmpty,
          ));

  void initialize() {
    // Khoi tao playhead controller
    playhead;

    // Lang nghe audio
    audioService.initialize();
    _audioPosSub = audioService.onPositionChanged.listen((pos) {
      audioPosition = pos;
      notifyListeners();
    });
    _audioDurSub = audioService.onDurationChanged.listen((dur) {
      audioDuration = dur;
      notifyListeners();
    });
    _audioStateSub = audioService.onPlayingStateChanged.listen((playing) {
      if (isPlayingAudio != playing) {
        isPlayingAudio = playing;
        notifyListeners();
      }
    });
    _audioCompleteSub = audioService.onPlayerComplete.listen((_) {
      _handleAudioCompleted();
    });

    storyRoles = List<StoryRoleTemplate>.from(story.roles);
    pages = List<StoryPage>.from(story.pages);
    activeReadingLogId = readingLogId;
    quizTemplates = List<StoryQuizTemplate>.from(story.quizTemplates);
    storyQuizzes = List<QuizQuestion>.from(story.allQuizzes);
    tabQuizStartTime = DateTime.now();
    storySessionStartTime = DateTime.now();

    final needLoad = _needsBackendPagesLoad;
    isLoadingPages = needLoad;

    // Bat dau phien doc truyen POST /api/reading-logs ngay lap tuc
    _startSessionFuture = startReadingSession();

    loadStoryRolesAndMappings();
    preloadStoryQuizzesAndReadingLog();
    ensureStoryPagesLoaded();

    if (!needLoad && pages.isNotEmpty) {
      currentPageIndex = (story.currentPage - 1).clamp(0, pages.length - 1);
      syncActionForCurrentPage(pages[currentPageIndex], fromInitState: true);
      preloadAllStoryVocabularies();
    }

  }

  void startTimelineLoop() {
    final ctrl = playhead;
    ctrl.duration = Duration(
      milliseconds: animationDurationMs.round().clamp(600, 30000),
    );
    ctrl
      ..stop()
      ..value = 0.0
      ..repeat();
  }

  void toggleEnglish() {
    showEnglish = !showEnglish;
    notifyListeners();
  }

  void setActiveTab(StoryPlayerTab tab) {
    activeTab = tab;
    if (tab == StoryPlayerTab.quiz && !tabQuizChecked) {
      tabQuizStartTime = DateTime.now();
    }
    spawnFireflies();
    notifyListeners();
  }

  void setAnimationMode(AnimationMode mode) {
    animationMode = mode;
    notifyListeners();
  }

  void setCharacterAction(CharacterAction act) {
    manualToyAction = act;
    characterAction = act;
    notifyListeners();
  }

  void setScale(double scale) {
    manualScaleMultiplier = scale;
    characterScale = scale;
    notifyListeners();
  }

  void setFlip(bool flip) {
    manualFlipOverride = flip;
    flipHorizontal = flip;
    notifyListeners();
  }

  void updateCharacterPosition(Offset pos) {
    characterPosition = pos;
    notifyListeners();
  }

  void resetCharacterPosition() {
    characterPosition = const Offset(40, 80);
    notifyListeners();
  }

  void spawnFireflies() {
    // Da bo hieu ung dom dom bay theo yeu cau
    particles.clear();
  }

  void triggerScreenShake() {
    // Da bo hieu ung rung lac man hinh theo yeu cau
    screenShakeOffset = 0.0;
  }

  void _handleAudioCompleted() {
    _autoAdvanceTimer?.cancel();
    if (!isNarrationActive) return;

    if (pages.isNotEmpty && currentPageIndex < pages.length - 1) {
      // Do tre tu nhien sau khi doc xong audio (2.2s) giup be kip ngam tranh,
      // va dong thoi dam bao tranh nen trang sau duoc tai truoc vao bo nho dem
      _autoAdvanceTimer = Timer(const Duration(milliseconds: 2200), () {
        if (!isNarrationActive) return;
        if (pages.isNotEmpty && currentPageIndex < pages.length - 1) {
          changePage(
            currentPageIndex + 1,
            pages,
            autoPlayAudio: true,
          );
        }
      });
    } else if (pages.isNotEmpty && currentPageIndex >= pages.length - 1) {
      // Da phat het audio trang cuoi cung cua truyen
      isNarrationActive = false;
      completeReadingSession();
      onStoryCompleted?.call();
    }
  }

  void toggleAudio() {
    final currentPage = (pages.isNotEmpty && currentPageIndex < pages.length)
        ? pages[currentPageIndex]
        : null;
    final audioUrl = currentPage?.audioNarrationUrl;

    if (isPlayingAudio || audioService.isPlaying) {
      // Nguoi dung chu dong bam tam dung
      isNarrationActive = false;
      _autoAdvanceTimer?.cancel();
      audioService.pauseAudio();
    } else {
      // Nguoi dung bat dau nghe ke truyen
      isNarrationActive = true;
      audioService.toggleAudio(
        audioUrl,
        pageNumber: currentPageIndex + 1,
        storyTitle: story.title,
      );
      replayPageMotion();
    }
    notifyListeners();
  }

  void changePage(int newIndex, List<StoryPage> allPages, {bool? autoPlayAudio}) {
    if (newIndex < 0 || newIndex >= allPages.length) return;
    _autoAdvanceTimer?.cancel();

    // Neu autoPlayAudio duoc chi dinh, hoac isNarrationActive dang bat,
    // hoac audio dang phat (chua nghe xong audio trang hien tai):
    // Thi audio cua trang moi se tu dong duoc phat ngay lap tuc!
    final shouldPlay = autoPlayAudio ?? (isNarrationActive || isPlayingAudio || audioService.isPlaying);

    final prevSlots = List<CharacterSlotTemplate>.from(activePageSlots);
    currentPageIndex = newIndex;
    syncActionForCurrentPage(
      allPages[newIndex],
      previousSlots: prevSlots,
    );
    spawnFireflies();

    if (shouldPlay) {
      isNarrationActive = true;
      final newPage = allPages[newIndex];
      audioService.playAudio(
        newPage.audioNarrationUrl,
        pageNumber: newIndex + 1,
        storyTitle: story.title,
      );
    } else {
      // Neu o che do doc tham (khong phat am thanh), dung audio trang cu
      audioService.stop();
    }

    // Precache toàn diện tranh nền và nhân vật của trang tiếp theo
    _precacheNextPageArt(newIndex, allPages);

    // Cap nhat tien do doc len Backend API (PUT /api/reading-logs/{id}/progress)
    _updateProgressOnPageChange(newIndex + 1);

    // Neu be da lat toi trang cuoi cung cua truyen, tu dong danh dau hoan thanh phien doc
    if (allPages.isNotEmpty && newIndex >= allPages.length - 1) {
      completeReadingSession();
    }

    notifyListeners();
  }

  void _precacheNextPageArt(int currentIndex, List<StoryPage> allPages) {
    if (currentIndex + 1 < allPages.length) {
      final next = allPages[currentIndex + 1];
      _precacheUrl(next.imageUrl);
      final key = _pageSlotKey(next);
      final nextSlots = slotsCacheByPage[key] ?? next.slots;
      for (var i = 0; i < nextSlots.length; i++) {
        final slot = nextSlots[i];
        StoryRoleTemplate? matchedRole;
        if (slot.storyRoleTemplateId != null && slot.storyRoleTemplateId!.isNotEmpty) {
          for (final r in storyRoles) {
            if (r.id.toLowerCase() == slot.storyRoleTemplateId!.toLowerCase()) {
              matchedRole = r;
              break;
            }
          }
        }
        matchedRole ??= (i < storyRoles.length)
            ? storyRoles[i]
            : (storyRoles.isNotEmpty ? storyRoles.first : null);

        final assigned = resolveMappedKidCharacter(
          roleId: slot.storyRoleTemplateId,
          matchedRole: matchedRole,
          slotIndex: i,
        );
        final characterUrl = assigned?.avatarAsset ?? matchedRole?.defaultAssetUrl ?? slot.assetUrl;
        _precacheUrl(characterUrl);
      }
    }
  }

  void _precacheAllStoryAssets() {
    final urls = <String>{};

    for (final p in pages) {
      if (p.imageUrl.isNotEmpty && p.imageUrl.startsWith('http') && !p.imageUrl.endsWith('/string')) {
        urls.add(p.imageUrl);
      }
      for (final s in p.slots) {
        if (s.assetUrl != null &&
            s.assetUrl!.isNotEmpty &&
            s.assetUrl!.startsWith('http') &&
            !s.assetUrl!.endsWith('/string')) {
          urls.add(s.assetUrl!);
        }
      }
      final key = _pageSlotKey(p);
      final cachedSlots = slotsCacheByPage[key];
      if (cachedSlots != null) {
        for (final s in cachedSlots) {
          if (s.assetUrl != null &&
              s.assetUrl!.isNotEmpty &&
              s.assetUrl!.startsWith('http') &&
              !s.assetUrl!.endsWith('/string')) {
            urls.add(s.assetUrl!);
          }
        }
      }
    }

    for (final r in storyRoles) {
      if (r.defaultAssetUrl != null &&
          r.defaultAssetUrl!.isNotEmpty &&
          r.defaultAssetUrl!.startsWith('http') &&
          !r.defaultAssetUrl!.endsWith('/string')) {
        urls.add(r.defaultAssetUrl!);
      }
    }

    for (final m in storyMappings) {
      for (final c in appState.characters) {
        if (c.id == m.characterId && c.avatarAsset.isNotEmpty && c.avatarAsset.startsWith('http')) {
          urls.add(c.avatarAsset);
        }
      }
    }

    for (final c in appState.characters) {
      if (c.avatarAsset.isNotEmpty && c.avatarAsset.startsWith('http')) {
        urls.add(c.avatarAsset);
      }
    }

    final hero = appState.heroCharacter;
    if (hero != null && hero.avatarAsset.isNotEmpty && hero.avatarAsset.startsWith('http')) {
      urls.add(hero.avatarAsset);
    }

    // Tải trước vào RAM bằng ImageCache của Flutter
    for (final url in urls) {
      _precacheUrl(url);
    }
  }

  void _precacheUrl(String? url) {
    if (url == null) return;
    final clean = url.trim();
    if (clean.isNotEmpty && clean.startsWith('http') && !clean.endsWith('/string')) {
      try {
        NetworkImage(clean).resolve(ImageConfiguration.empty);
      } catch (_) {}
    }
  }

  /// Bat dau phien doc truyen tren Backend API (POST /api/reading-logs)
  Future<ReadingLogSession?> startReadingSession() async {
    if (activeReadingLogId != null && AppConfig.isValidUuid(activeReadingLogId)) {
      return null;
    }

    // Neu la StoryTemplate goc, bo qua tao reading-logs vi backend chi nhan generatedStoryId
    if (isOriginalTemplate) {
      if (kDebugMode) {
        debugPrint('[StoryPlayerController] Bo qua POST /api/reading-logs vi day la StoryTemplate goc: ${story.id}');
      }
      return null;
    }

    final candidateGenId = AppConfig.isValidUuid(story.id) ? story.id : null;
    if (candidateGenId == null) {
      if (kDebugMode) {
        debugPrint('[StoryPlayerController] story.id khong phai UUID hop le: ${story.id}');
      }
      return null;
    }

    try {
      if (kDebugMode) {
        debugPrint('[StoryPlayerController] Bat dau phien doc POST /api/reading-logs voi storyId: $candidateGenId');
      }
      final startedSession = await ReadingLogService.startReadingSession(
        generatedStoryId: candidateGenId,
        token: appState.authToken,
      );
      if (startedSession != null && AppConfig.isValidUuid(startedSession.id)) {
        activeReadingLogId = startedSession.id;
        if (kDebugMode) {
          debugPrint('[StoryPlayerController] Da tao phien doc thanh cong: activeReadingLogId=$activeReadingLogId');
        }
        notifyListeners();
        return startedSession;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StoryPlayerController] Loi startReadingSession: $e');
      }
    }
    return null;
  }

  /// Cap nhat tien do khi be lat trang
  Future<void> _updateProgressOnPageChange(int pageNumber) async {
    if (activeReadingLogId == null && _startSessionFuture != null) {
      await _startSessionFuture;
    }
    if (activeReadingLogId != null && AppConfig.isValidUuid(activeReadingLogId)) {
      final duration = DateTime.now().difference(storySessionStartTime).inSeconds;
      if (kDebugMode) {
        debugPrint('[StoryPlayerController] Cap nhat tien do PUT /api/reading-logs/$activeReadingLogId/progress trang $pageNumber, thoi gian ${duration}s');
      }
      ReadingLogService.updateProgress(
        readingLogId: activeReadingLogId!,
        currentPage: pageNumber,
        readDurationSeconds: duration,
        token: appState.authToken,
      );
    }
  }

  /// Danh dau hoan thanh phien doc tren Backend API (PUT /api/reading-logs/{id}/complete)
  /// va dong bo danh sach truyen da doc xong (GET /api/reading-logs/child-profiles/{childProfileId}/completed)
  Future<void> completeReadingSession() async {
    if (isReadingSessionCompleted) return;
    isReadingSessionCompleted = true;

    // 1. Dam bao da co phien doc activeReadingLogId
    if (activeReadingLogId == null || !AppConfig.isValidUuid(activeReadingLogId)) {
      if (_startSessionFuture != null) {
        await _startSessionFuture;
      }
      if (activeReadingLogId == null || !AppConfig.isValidUuid(activeReadingLogId)) {
        await startReadingSession();
      }
    }

    // 2. Goi PUT /api/reading-logs/{id}/complete
    if (activeReadingLogId != null && AppConfig.isValidUuid(activeReadingLogId)) {
      if (kDebugMode) {
        debugPrint('[StoryPlayerController] Hoan thanh truyen: goi PUT /api/reading-logs/$activeReadingLogId/complete');
      }
      await ReadingLogService.completeReadingSession(
        readingLogId: activeReadingLogId!,
        token: appState.authToken,
      );
    } else {
      if (kDebugMode) {
        debugPrint('[StoryPlayerController] Canh bao: activeReadingLogId null nen khong the goi PUT complete.');
      }
    }

    // 3. Danh dau hoan thanh cuc bo ngay lap tuc de UI duoc cap nhat tuc thi
    appState.markStoryCompleted(story.id);

    // 4. Dong bo danh sach completed tu backend (GET /api/reading-logs/child-profiles/{childProfileId}/completed)
    await appState.syncCompletedStoriesFromBackend();
  }

  void replayPageMotion() {
    if (activePageSlots.isEmpty) return;
    final currentPage = (pages.isNotEmpty && currentPageIndex < pages.length)
        ? pages[currentPageIndex]
        : null;
    if (currentPage == null) return;

    manualToyAction = null;
    userDraggedSlotIds.clear();
    activePageSlots = List<CharacterSlotTemplate>.from(originalPageSlots);
    activeAnimationClips = currentPage.animationClips.isNotEmpty
        ? currentPage.animationClips
        : StoryAnimationEngine.buildContextualClipsForSlots(
            slots: originalPageSlots,
            previousSlots: previousPageSlots,
            pageNumber: currentPage.pageNumber,
            storyTitle: story.title,
            characterAction: currentPage.characterAction,
          );
    startTimelineLoop();
    spawnFireflies();
    notifyListeners();
  }

  Future<void> loadStoryRolesAndMappings() async {
    try {
      final roles = await StoryService.fetchStoryRoles(
        story.id,
        token: appState.authToken,
        storyTitle: story.title,
      );
      if (roles.isNotEmpty) {
        storyRoles = roles;
        // Cập nhật lại slots cho toàn bộ các trang nếu đang dùng fallback auto-slot bị thiếu vai
        for (final p in pages) {
          final pKey = _pageSlotKey(p);
          final pSlots = slotsCacheByPage[pKey];
          final needsUpdate = pSlots == null ||
              pSlots.isEmpty ||
              pSlots.any((s) =>
                  s.id.startsWith('auto-') &&
                  (s.storyRoleTemplateId == null || s.storyRoleTemplateId!.isEmpty));
          if (needsUpdate) {
            slotsCacheByPage[pKey] = _generateFallbackSlotsForPage(p);
          }
        }
        if (pages.isNotEmpty && currentPageIndex < pages.length) {
          final current = pages[currentPageIndex];
          final currentKey = _pageSlotKey(current);
          final currentSlots = slotsCacheByPage[currentKey];
          if (currentSlots != null && currentSlots.isNotEmpty) {
            _applyPageSlots(current, currentSlots, restartTimeline: true);
          }
        }
        notifyListeners();
      }
    } catch (_) {}

    if (!isOriginalTemplate && AppConfig.isValidUuid(story.id)) {
      try {
        final mappings = await CharacterMappingService.fetchMappingsByStory(
          story.id,
          token: appState.authToken,
        );
        if (mappings.isNotEmpty) {
          storyMappings = mappings;
          notifyListeners();
        }
      } catch (_) {}
    }
  }

  Future<void> ensureStoryPagesLoaded() async {
    final hasExistingPages = pages.isNotEmpty;
    // Chỉ hiển thị loading che màn hình nếu chưa có trang nào để đọc
    if (!hasExistingPages) {
      isLoadingPages = true;
      notifyListeners();
    }

    try {
      if (story.id.isNotEmpty && AppConfig.isValidUuid(story.id)) {
        final backendPages = await StoryService.fetchStoryTemplatePages(
          story.id,
          token: appState.authToken,
          storyTitle: story.title,
          totalPages: story.totalPages,
        );
        if (backendPages.isNotEmpty) {
          final mappedPages = backendPages.map((dto) {
            final pageImg = (dto.imageUrl.isNotEmpty &&
                    !dto.imageUrl.endsWith('/string') &&
                    dto.imageUrl.toLowerCase() != 'string' &&
                    dto.fullImageUrl.isNotEmpty)
                ? dto.fullImageUrl
                : (story.coverUrl.isNotEmpty && story.coverUrl.toLowerCase() != 'string'
                    ? story.coverUrl
                    : 'assets/images/Br.png');
            final pageText = (dto.rawText.isNotEmpty &&
                    dto.rawText.toLowerCase() != 'string')
                ? dto.rawText
                : (story.subtitle.isNotEmpty &&
                        story.subtitle.toLowerCase() != 'string'
                    ? story.subtitle
                    : 'Trang ${dto.pageNumber}: Bé hãy cùng khám phá câu chuyện "${story.title}" thật kỳ diệu nhé!');
            final audioUrl = (dto.audioNarrationUrl != null &&
                    !dto.audioNarrationUrl!.endsWith('/string') &&
                    dto.audioNarrationUrl!.toLowerCase() != 'string')
                ? dto.audioNarrationUrl
                : AppConfig.fallbackAudioUrlForPage(dto.pageNumber);

            return StoryPage(
              id: dto.id,
              pageNumber: dto.pageNumber,
              imageUrl: pageImg,
              textContent: pageText,
              englishSubtitle: pageText,
              chapterTitle: 'Trang ${dto.pageNumber}: ${story.title}',
              narratorName: 'Chú Gấu Pô',
              audioNarrationUrl: audioUrl,
              slots: dto.slots,
              animationClips: dto.animationClips,
              subtitles: dto.composition?.subtitles ?? const [],
            );
          }).toList();

          mappedPages.sort((a, b) => a.pageNumber.compareTo(b.pageNumber));

          // Bổ sung các trang còn lại nếu backend totalPages lớn hơn số trang đã tạo
          while (story.totalPages > 0 && mappedPages.length < story.totalPages) {
            final nextNum = mappedPages.length + 1;
            mappedPages.add(
              StoryPage(
                id: '${story.id}-page-$nextNum',
                pageNumber: nextNum,
                imageUrl: story.coverUrl.isNotEmpty && story.coverUrl.toLowerCase() != 'string'
                    ? story.coverUrl
                    : 'assets/images/Br.png',
                textContent: 'Trang $nextNum: Bé hãy cùng khám phá tiếp câu chuyện "${story.title}" thật kỳ diệu nhé!',
                englishSubtitle: 'Page $nextNum: Let us continue exploring "${story.title}" together!',
                chapterTitle: 'Trang $nextNum: ${story.title}',
                narratorName: 'Chú Gấu Pô',
                audioNarrationUrl: AppConfig.fallbackAudioUrlForPage(nextNum),
              ),
            );
          }
          pages = mappedPages;
          if (pages.isNotEmpty && currentPageIndex < pages.length) {
            syncActionForCurrentPage(pages[currentPageIndex], fromInitState: false);
          }
        }
      }

      // Đảm bảo không còn trang nào mang ảnh/text là dummy "string"
      for (var i = 0; i < pages.length; i++) {
        final p = pages[i];
        final badImg = p.imageUrl.isEmpty ||
            p.imageUrl.toLowerCase() == 'string' ||
            p.imageUrl.endsWith('/string') ||
            p.imageUrl.toLowerCase() == 'null';
        final badText = p.textContent.isEmpty ||
            p.textContent.toLowerCase() == 'string' ||
            p.textContent.toLowerCase() == 'null';
        if (badImg || badText) {
          final fallbackImg = (story.coverUrl.isNotEmpty &&
                  story.coverUrl.toLowerCase() != 'string' &&
                  !story.coverUrl.endsWith('/string'))
              ? story.coverUrl
              : 'assets/images/Br.png';
          pages[i] = StoryPage(
            id: p.id,
            pageNumber: p.pageNumber,
            imageUrl: badImg ? fallbackImg : p.imageUrl,
            textContent: badText
                ? (story.subtitle.isNotEmpty &&
                        story.subtitle.toLowerCase() != 'string'
                    ? story.subtitle
                    : 'Trang ${p.pageNumber}: Bé hãy cùng khám phá câu chuyện "${story.title}" thật kỳ diệu nhé!')
                : p.textContent,
            englishSubtitle: p.englishSubtitle,
            chapterTitle: p.chapterTitle,
            narratorName: p.narratorName,
            audioNarrationUrl: p.audioNarrationUrl ?? AppConfig.fallbackAudioUrlForPage(p.pageNumber),
            slots: p.slots,
            animationClips: p.animationClips,
          );
        }
      }

      if (pages.isNotEmpty) {
        currentPageIndex = (story.currentPage - 1).clamp(0, pages.length - 1);
        syncActionForCurrentPage(pages[currentPageIndex], fromInitState: true);
      }

      // Luôn gọi nạp Slots và Vocabularies từ server cho tất cả các trang
      await Future.wait([
        preloadAllStorySlots(),
        preloadAllStoryVocabularies(),
      ]);

      // Tải trước ngầm toàn bộ ảnh nhân vật và tranh nền vào RAM để chuyển trang tức thì
      _precacheAllStoryAssets();

      if (!hasExistingPages) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StoryPlayerController] Error ensureStoryPagesLoaded: $e');
      }
    } finally {
      isLoadingPages = false;
      notifyListeners();
    }
  }

  Future<void> preloadAllStorySlots() async {
    final futures = pages.map((page) async {
      final pageId = page.id;
      if (pageId == null || !AppConfig.isValidUuid(pageId)) return;
      final key = _pageSlotKey(page);
      if (slotsCacheByPage.containsKey(key)) return;
      try {
        final fetched = await StoryService.fetchPageSlots(
          pageId,
          token: appState.authToken,
          pageNumber: page.pageNumber,
          storyId: story.id,
          storyTitle: story.title,
        );
        if (fetched.isNotEmpty) {
          slotsCacheByPage[key] = fetched;
        } else if (page.slots.isNotEmpty) {
          slotsCacheByPage[key] = page.slots;
        } else {
          slotsCacheByPage[key] = _generateFallbackSlotsForPage(page);
        }
      } catch (_) {
        if (page.slots.isNotEmpty) {
          slotsCacheByPage[key] = page.slots;
        } else {
          slotsCacheByPage[key] = _generateFallbackSlotsForPage(page);
        }
      }
    });

    await Future.wait(futures);

    // Cập nhật lại slots cho trang hiện tại sau khi nạp xong
    if (pages.isNotEmpty && currentPageIndex < pages.length) {
      final current = pages[currentPageIndex];
      final currentKey = _pageSlotKey(current);
      final loadedSlots = slotsCacheByPage[currentKey];
      if (loadedSlots != null && loadedSlots.isNotEmpty) {
        _applyPageSlots(current, loadedSlots, restartTimeline: false);
      }
      notifyListeners();
    }
  }

  /// Tự động sinh slots hiển thị nhân vật trên sân khấu khi backend chưa tạo slot
  List<CharacterSlotTemplate> _generateFallbackSlotsForPage(StoryPage page) {
    if (storyRoles.isNotEmpty) {
      final generated = <CharacterSlotTemplate>[];
      final count = storyRoles.length;
      for (var i = 0; i < count; i++) {
        final role = storyRoles[i];
        final double posX;
        if (count == 1) {
          posX = 50.0;
        } else if (count == 2) {
          posX = i == 0 ? 25.0 : 75.0;
        } else {
          posX = 18.0 + (i * 64.0 / (count - 1));
        }
        generated.add(
          CharacterSlotTemplate(
            id: 'auto-slot-${page.pageNumber}-$i',
            storyPageId: page.id ?? '',
            storyRoleTemplateId: role.id,
            assetUrl: role.defaultAssetUrl,
            posX: posX,
            posY: 60.0,
            scale: 1.05,
            flipHorizontal: (count == 2 && i == 1) ? true : false,
          ),
        );
      }
      return generated;
    }

    return [
      CharacterSlotTemplate(
        id: 'auto-hero-slot-${page.pageNumber}',
        storyPageId: page.id ?? '',
        posX: 60.0,
        posY: 60.0,
        scale: 1.05,
      ),
    ];
  }

  String _pageSlotKey(StoryPage page) => page.id ?? 'page-${page.pageNumber}';

  void syncActionForCurrentPage(
    StoryPage? page, {
    List<CharacterSlotTemplate>? previousSlots,
    bool fromInitState = false,
  }) {
    if (page == null) return;
    previousPageSlots = previousSlots != null
        ? List<CharacterSlotTemplate>.from(previousSlots)
        : const [];
    manualToyAction = null;
    manualScaleMultiplier = 1.0;
    manualFlipOverride = null;

    if (page.characterAction != null) {
      switch (page.characterAction!.toLowerCase()) {
        case 'dance':
          characterAction = CharacterAction.dance;
          break;
        case 'fly':
          characterAction = CharacterAction.fly;
          break;
        case 'stomp':
          characterAction = CharacterAction.stomp;
          break;
        case 'sleep':
          characterAction = CharacterAction.sleep;
          break;
        default:
          characterAction = CharacterAction.patrol;
      }
    } else {
      characterAction = CharacterAction.patrol;
    }

    _loadSlotsForPage(page, silentInitial: fromInitState);
    loadVocabulariesForPage(page);
    notifyListeners();
  }

  Future<void> _loadSlotsForPage(
    StoryPage page, {
    bool silentInitial = false,
  }) async {
    final key = _pageSlotKey(page);
    final cached = slotsCacheByPage[key];
    if (cached != null && cached.isNotEmpty) {
      _applyPageSlots(page, cached, restartTimeline: true);
      return;
    }

    if (page.slots.isNotEmpty) {
      _applyPageSlots(page, page.slots, restartTimeline: true);
    } else {
      // Trong lúc đợi nạp slots chuẩn của trang này, không gán slot fallback sai vai để tránh chớp đổi nhân vật
      _applyPageSlots(page, const [], restartTimeline: false);
    }

    if (page.id == null || !AppConfig.isValidUuid(page.id)) {
      if (page.slots.isEmpty) {
        final fallback = _generateFallbackSlotsForPage(page);
        slotsCacheByPage[key] = fallback;
        _applyPageSlots(page, fallback, restartTimeline: true);
      }
      return;
    }

    try {
      final fetched = await StoryService.fetchPageSlots(
        page.id!,
        token: appState.authToken,
        pageNumber: page.pageNumber,
        storyId: story.id,
        storyTitle: story.title,
      );
      if (fetched.isNotEmpty) {
        slotsCacheByPage[key] = fetched;
      } else {
        slotsCacheByPage[key] = page.slots.isNotEmpty
            ? page.slots
            : _generateFallbackSlotsForPage(page);
      }
    } catch (_) {
      slotsCacheByPage[key] = page.slots.isNotEmpty
          ? page.slots
          : _generateFallbackSlotsForPage(page);
    }

    final currentPage = (pages.isNotEmpty && currentPageIndex < pages.length)
        ? pages[currentPageIndex]
        : null;
    if (currentPage != null && _pageSlotKey(currentPage) == key) {
      final finalSlots = slotsCacheByPage[key] ?? const [];
      _applyPageSlots(currentPage, finalSlots, restartTimeline: true);
    }
  }

  void _applyPageSlots(
    StoryPage page,
    List<CharacterSlotTemplate> rawSlots, {
    bool restartTimeline = true,
  }) {
    // Giu nguyen danh sach slot do Content Manager thiet lap
    final slots = List<CharacterSlotTemplate>.from(rawSlots);
    final explicitClips = <StoryAnimationClip>[
      ...page.animationClips,
      for (final s in slots) ...s.animationClips,
    ];
    final clips = explicitClips.isNotEmpty
        ? explicitClips
        : StoryAnimationEngine.buildContextualClipsForSlots(
            slots: slots,
            previousSlots: previousPageSlots,
            pageNumber: page.pageNumber,
            storyTitle: story.title,
            characterAction: page.characterAction,
          );
    final durationMs = StoryAnimationEngine.animationDuration(
      clips,
      slots: slots,
      minDurationMs: 3600.0,
      loopHoldMs: explicitClips.isNotEmpty ? 1100.0 : 0.0,
    );

    final subDuration = page.subtitles.isNotEmpty
        ? (page.subtitles.last.startMs + page.subtitles.last.durationMs)
        : 0.0;
    final effectiveDuration = math.max(durationMs, subDuration);

    originalPageSlots = List<CharacterSlotTemplate>.from(slots);
    activePageSlots = List<CharacterSlotTemplate>.from(slots);
    activeAnimationClips = clips;
    animationDurationMs = effectiveDuration;
    userDraggedSlotIds.clear();

    if (slots.isNotEmpty && clips.isNotEmpty) {
      if (restartTimeline || !playhead.isAnimating) {
        startTimelineLoop();
      } else {
        playhead.duration = Duration(
          milliseconds: effectiveDuration.round().clamp(600, 30000),
        );
      }
    } else {
      if (_playheadController != null && _playheadController!.isAnimating) {
        _playheadController!.stop();
      }
    }
    notifyListeners();
  }

  KidCharacter? resolveMappedKidCharacter({
    String? roleId,
    StoryRoleTemplate? matchedRole,
    int slotIndex = 0,
  }) {
    // 0. Khi dang xem mau truyen goc (Original Mode), luon tra ve null de hien thi 100% anh va vai goc tu CM
    if (isOriginalTemplate) return null;

    // 1. Kiem tra mapping theo roleId truc tiep tu appState cho dung truyen nay
    if (roleId != null && roleId.isNotEmpty) {
      final fromState = appState.getMappedCharacterForRole(story.id, roleId);
      if (fromState != null && fromState.isParentApproved) return fromState;
    }

    // 2. Kiem tra mapping theo matchedRole.id tu appState cho dung truyen nay
    if (matchedRole != null && matchedRole.id.isNotEmpty && matchedRole.id != roleId) {
      final fromMatched = appState.getMappedCharacterForRole(story.id, matchedRole.id);
      if (fromMatched != null && fromMatched.isParentApproved) return fromMatched;
    }

    // 3. Kiem tra storyMappings tu API may chu neu co cho dung vai nay
    final effectiveRoleId = (roleId != null && roleId.isNotEmpty) ? roleId : matchedRole?.id;
    if (effectiveRoleId != null && effectiveRoleId.isNotEmpty) {
      for (final m in storyMappings) {
        if (m.isApproved &&
            m.storyRoleTemplateId.toLowerCase() == effectiveRoleId.toLowerCase()) {
          for (final c in appState.characters) {
            if (c.id == m.characterId && c.isParentApproved) return c;
          }
        }
      }
    }

    // 4. Neu vai nay chua duoc be chu dong gan rieng cho truyen nay,
    // TUYET DOI KHONG tu dong gan hoac lay trung nhan vat tu vai khac.
    // Tra ve null de he thong tu dong hien thi 100% hinh anh goc tu Content Manager (CM).
    return null;
  }

  List<StoryStageSlotItem> buildStageSlotItems(StoryPage? currentPage) {
    if (activePageSlots.isEmpty) return const [];
    final pageNum = currentPage?.pageNumber ?? (currentPageIndex + 1);
    final items = <StoryStageSlotItem>[];

    for (var slotIndex = 0; slotIndex < activePageSlots.length; slotIndex++) {
      final rawSlot = activePageSlots[slotIndex];
      final effectiveSlot = rawSlot.copyWith(
        scale: (rawSlot.scale * manualScaleMultiplier).clamp(0.25, 3.0),
        flipHorizontal: manualFlipOverride ?? rawSlot.flipHorizontal,
      );

      final isDragged = userDraggedSlotIds.contains(rawSlot.id);
      final renderState = isDragged
          ? SlotRenderState(
              x: effectiveSlot.posX,
              y: effectiveSlot.posY,
              scale: effectiveSlot.scale,
              rotation: effectiveSlot.rotation,
              opacity: 1.0,
            )
          : StoryAnimationEngine.evaluateSlotAnimation(
              effectiveSlot,
              activeAnimationClips,
              playheadMs,
            );

      StoryRoleTemplate? matchedRole;
      if (rawSlot.storyRoleTemplateId != null &&
          rawSlot.storyRoleTemplateId!.isNotEmpty) {
        for (final r in storyRoles) {
          if (r.id.toLowerCase() == rawSlot.storyRoleTemplateId!.toLowerCase()) {
            matchedRole = r;
            break;
          }
        }
      }
      matchedRole ??= (slotIndex < storyRoles.length)
          ? storyRoles[slotIndex]
          : (storyRoles.isNotEmpty ? storyRoles.first : null);

      final activeKidChar = resolveMappedKidCharacter(
        roleId: rawSlot.storyRoleTemplateId,
        matchedRole: matchedRole,
        slotIndex: slotIndex,
      );
      final displayName = activeKidChar?.name ?? matchedRole?.roleName ?? 'Nhân vật';
      final fallbackAsset = _localFallbackAssetForRole(
        matchedRole?.roleName ?? displayName,
        pageNum,
      );

      String primaryUrl = '';
      if (activeKidChar != null && activeKidChar.avatarAsset.isNotEmpty) {
        primaryUrl = activeKidChar.avatarAsset;
      } else if (effectiveSlot.fullAssetUrl.isNotEmpty) {
        primaryUrl = effectiveSlot.fullAssetUrl;
      } else if (matchedRole != null && matchedRole.fullDefaultAssetUrl.isNotEmpty) {
        primaryUrl = matchedRole.fullDefaultAssetUrl;
      } else if (fallbackAsset != null) {
        primaryUrl = fallbackAsset;
      }

      final speech = currentPage?.characterSpeech ??
          activeKidChar?.voicePhrase ??
          _contextualSpeechForRole(displayName, pageNum);

      items.add(
        StoryStageSlotItem(
          slot: effectiveSlot,
          renderState: renderState,
          imageUrl: primaryUrl,
          fallbackAssetPath: fallbackAsset,
          displayName: displayName,
          speechPhrase: speech,
          flipHorizontal: effectiveSlot.flipHorizontal,
        ),
      );

      if (kDebugMode) {
        debugPrint(
          '[StoryPlayer] Trang $pageNum Slot $slotIndex (Vai: "${matchedRole?.roleName ?? "Chưa rõ"}" - RoleId: ${rawSlot.storyRoleTemplateId ?? "null"}) -> '
          '${activeKidChar != null ? "Gán thành công nhân vật: \"${activeKidChar.name}\"" : "Dùng mẫu gốc Content Manager"}',
        );
      }
    }

    return items;
  }

  String? _localFallbackAssetForRole(String roleName, int pageNumber) {
    final lower = '${roleName.toLowerCase()} ${story.title.toLowerCase()}';
    if (lower.contains('bobby') || lower.contains('khu vườn')) {
      switch (pageNumber) {
        case 1:
          return 'assets/images/bobby-di-bo.webp';
        case 2:
          return 'assets/images/bobby-chinh-dien.webp';
        case 3:
          return 'assets/images/bobby-nhay.webp';
        case 4:
          return 'assets/images/bobby-dung-phai.webp';
        case 5:
          return 'assets/images/bobby-ngoi.webp';
        default:
          return 'assets/images/bobby-dung-phai.webp';
      }
    }
    return null;
  }

  String _contextualSpeechForRole(String roleName, int pageNumber) {
    if (roleName.toLowerCase().contains('bobby')) {
      switch (pageNumber) {
        case 1:
          return 'Gâu gâu! Chiếc lá vàng đang bay đi đâu thế nhỉ?';
        case 2:
          return 'Đi chậm lại một chút để không làm đổ chậu cây nhé!';
        case 3:
          return 'Ôi, có một mầm cây bé xíu bên lối đi kìa!';
        case 4:
          return 'Tớ sẽ đứng chắn gió bảo vệ mầm cây nhỏ!';
        case 5:
          return 'Biết quan tâm chăm sóc cũng là một món quà thật ấm áp!';
      }
    }
    return 'Chào bé! Cùng $roleName khám phá trang truyện này nhé!';
  }

  Future<void> loadVocabulariesForPage(StoryPage? page) async {
    if (page == null) return;
    final pageId = page.id ?? '';
    if (!AppConfig.isValidUuid(pageId)) return;

    isLoadingVocabularies = true;
    notifyListeners();

    try {
      final list = await VocabularyService.fetchPageVocabularies(
        pageId,
        token: appState.authToken,
        pageNumber: page.pageNumber,
        storyTitle: story.title,
      );
      pageVocabularies = list;
      for (final v in list) {
        allStoryVocabularies[v.id] = v;
      }
    } catch (_) {
    } finally {
      isLoadingVocabularies = false;
      notifyListeners();
    }
  }

  Future<void> preloadAllStoryVocabularies() async {
    final targetPages = pages.isNotEmpty ? pages : story.pages;
    for (final page in targetPages) {
      final pageId = page.id ?? '';
      if (!AppConfig.isValidUuid(pageId)) continue;
      try {
        final list = await VocabularyService.fetchPageVocabularies(
          pageId,
          token: appState.authToken,
          pageNumber: page.pageNumber,
          storyTitle: story.title,
        );
        for (final v in list) {
          allStoryVocabularies[v.id] = v;
        }
        if (pages.isNotEmpty &&
            currentPageIndex < pages.length &&
            pages[currentPageIndex].id == pageId &&
            list.isNotEmpty) {
          pageVocabularies = list;
        }
      } catch (_) {}
    }
    notifyListeners();
  }

  void markVocabLearned(String vocabId) {
    learnedVocabIds.add(vocabId);
    spawnFireflies();
    notifyListeners();
  }

  /// Goi GET /api/story-vocabulary/{id} de lay chi tiet tu vung khi be cham hoc
  Future<VocabularyTemplate> inspectVocabularyDetail(
    VocabularyTemplate vocab,
  ) async {
    if (AppConfig.isValidUuid(vocab.id)) {
      try {
        final detail = await VocabularyService.fetchVocabularyById(
          vocab.id,
          token: appState.authToken,
        );
        if (detail != null) {
          allStoryVocabularies[detail.id] = detail;
          final idx = pageVocabularies.indexWhere((v) => v.id == detail.id);
          if (idx >= 0) {
            pageVocabularies[idx] = detail;
          }
          notifyListeners();
          return detail;
        }
      } catch (_) {}
    }
    return vocab;
  }

  ReadingLogQuizSummary? activeQuizSummary;

  Future<void> preloadStoryQuizzesAndReadingLog() async {
    if (storyQuizzes.isEmpty) {
      isLoadingQuizzes = true;
      notifyListeners();
    }
    try {
      final fetched = await QuizService.fetchStoryQuizzes(
        story.id,
        token: appState.authToken,
        storyTitle: story.title,
      );
      if (fetched.isNotEmpty) {
        quizTemplates = fetched;
        storyQuizzes = fetched.map((q) => q.toQuizQuestion()).toList();
        if (currentTabQuizIndex >= storyQuizzes.length) {
          currentTabQuizIndex = 0;
        }
      }
    } catch (_) {
    } finally {
      isLoadingQuizzes = false;
      notifyListeners();
    }

    final childProfileId = appState.effectiveChildProfileId;

    // 1. Kiem tra danh sach truyen da doc xong tren Backend (GET /api/reading-logs/child-profiles/{childProfileId}/completed)
    if (AppConfig.isValidUuid(childProfileId)) {
      await appState.syncCompletedStoriesFromBackend();
    }

    // 2. Dam bao da bat dau phien doc
    if (activeReadingLogId == null || !AppConfig.isValidUuid(activeReadingLogId)) {
      if (_startSessionFuture != null) {
        await _startSessionFuture;
      }
      if (activeReadingLogId == null || !AppConfig.isValidUuid(activeReadingLogId)) {
        await startReadingSession();
      }
    }

    // 3. Tra cuu lich su lam quiz cua be neu chua co activeQuizSummary
    if (activeQuizSummary == null && AppConfig.isValidUuid(childProfileId)) {
      try {
        final history = await QuizService.fetchChildQuizHistory(
          childProfileId!,
          token: appState.authToken,
        );
        if (history.isNotEmpty) {
          final quizIds = quizTemplates.map((q) => q.id).toSet();
          ReadingLogQuizSummary? matched;
          for (final item in history) {
            if (!AppConfig.isValidUuid(item.readingLogId)) continue;
            final matchesStory = item.answers.any(
              (a) => quizIds.contains(a.storyQuizTemplateId),
            );
            if (matchesStory) {
              matched = item;
              break;
            }
          }
          if (matched != null) {
            activeQuizSummary = matched;
            notifyListeners();
          }
        }
      } catch (_) {}
    }

    // 4. Neu da co activeReadingLogId, kiem tra tom tat ket qua quiz cua phien doc nay
    // (GET /api/child-quiz-answers/reading-logs/{readingLogId})
    if (activeReadingLogId != null && AppConfig.isValidUuid(activeReadingLogId)) {
      try {
        final summary = await QuizService.fetchReadingLogSummary(
          activeReadingLogId!,
          token: appState.authToken,
        );
        if (summary != null) {
          activeQuizSummary = summary;
          notifyListeners();
        }
      } catch (_) {}
    }
  }

  void selectTabQuizOption(int idx) {
    selectedTabQuizOption = idx;
    notifyListeners();
  }

  Future<void> checkTabQuizAnswer() async {
    if (isSubmittingTabQuiz || storyQuizzes.isEmpty) return;
    final idx = currentTabQuizIndex.clamp(0, storyQuizzes.length - 1);
    final currentQuiz = storyQuizzes[idx];
    final template = idx < quizTemplates.length ? quizTemplates[idx] : null;
    final elapsedSeconds = DateTime.now()
        .difference(tabQuizStartTime)
        .inSeconds
        .clamp(0, 600);

    SubmitQuizAnswerResult? serverResult;
    final logIdToSend = (activeReadingLogId != null && AppConfig.isValidUuid(activeReadingLogId))
        ? activeReadingLogId!
        : '00000000-0000-0000-0000-000000000000';
    final quizIdToSend = (template != null && AppConfig.isValidUuid(template.id))
        ? template.id
        : (AppConfig.isValidUuid(story.id) ? story.id : '00000000-0000-0000-0000-000000000000');

    isSubmittingTabQuiz = true;
    notifyListeners();
    try {
      serverResult = await QuizService.submitAnswer(
        readingLogId: logIdToSend,
        storyQuizTemplateId: quizIdToSend,
        selectedOptionIndex: selectedTabQuizOption,
        responseTimeSeconds: elapsedSeconds,
        childProfileId: appState.effectiveChildProfileId,
        token: appState.authToken,
      );
    } finally {
      isSubmittingTabQuiz = false;
      notifyListeners();
    }

    if (serverResult != null) {
      final starsAwarded = serverResult.isQuizCompleted && serverResult.stars > 0
          ? serverResult.stars
          : (serverResult.isCorrect ? 5 : 0);
      if (starsAwarded > 0) {
        appState.addStars(starsAwarded);
        spawnFireflies();
      } else {
        triggerScreenShake();
      }
      tabQuizChecked = true;
      tabQuizIsCorrect = serverResult.isCorrect;
      tabQuizStars = starsAwarded;
      tabQuizFeedback = serverResult.message.isNotEmpty
          ? serverResult.message
          : (serverResult.isCorrect
              ? currentQuiz.celebrationMessage
              : 'Bé thử xem lại đáp án đúng màu xanh nhé!');
      notifyListeners();
      return;
    }

    // Local fallback
    final isCorrect = selectedTabQuizOption == currentQuiz.correctIndex;
    final localStars = isCorrect ? currentQuiz.rewardStars : 0;
    if (isCorrect) {
      appState.addStars(localStars);
      spawnFireflies();
    } else {
      triggerScreenShake();
    }
    tabQuizChecked = true;
    tabQuizIsCorrect = isCorrect;
    tabQuizStars = localStars;
    tabQuizFeedback = isCorrect
        ? currentQuiz.celebrationMessage
        : 'Chưa chính xác rồi! Đáp án đúng đã được tô sáng màu xanh lá cho bé nhé!';
    notifyListeners();
  }

  void nextTabQuiz(VoidCallback onOpenRewardScreen) {
    if (currentTabQuizIndex < storyQuizzes.length - 1) {
      currentTabQuizIndex++;
      selectedTabQuizOption = 0;
      tabQuizChecked = false;
      tabQuizIsCorrect = false;
      tabQuizStars = null;
      tabQuizFeedback = null;
      tabQuizStartTime = DateTime.now();
      spawnFireflies();
      notifyListeners();
    } else {
      onOpenRewardScreen();
    }
  }

  @override
  void dispose() {
    if (!isReadingSessionCompleted &&
        activeReadingLogId != null &&
        AppConfig.isValidUuid(activeReadingLogId)) {
      final duration = DateTime.now().difference(storySessionStartTime).inSeconds;
      ReadingLogService.updateProgress(
        readingLogId: activeReadingLogId!,
        currentPage: currentPageIndex + 1,
        readDurationSeconds: duration,
        token: appState.authToken,
      );
    }
    _autoAdvanceTimer?.cancel();
    _audioCompleteSub?.cancel();
    _audioPosSub?.cancel();
    _audioDurSub?.cancel();
    _audioStateSub?.cancel();
    _lastPageAudioTimer?.cancel();
    audioService.dispose();
    _playheadController?.dispose();
    super.dispose();
  }
}

