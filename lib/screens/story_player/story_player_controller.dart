import 'dart:async';
import 'dart:math';
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

/// 🧠 Controller Quản Lý Logic Đọc Truyện Tương Tác (StoryPlayerController)
/// Tương đương React Hook `useStoryPlayer`:
/// Quản lý âm thanh Audio, Trục thời gian chuyển động CM, Chuyển trang,
/// Gán vai nhân vật, Đố vui (Quiz) & Học từ vựng (Vocabulary).
class StoryPlayerController extends ChangeNotifier {
  final TickerProvider vsync;
  final Story story;
  final AppState appState;
  final String? readingLogId;

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
  StreamSubscription<Duration>? _audioPosSub;
  StreamSubscription<Duration>? _audioDurSub;
  StreamSubscription<bool>? _audioStateSub;
  Timer? _lastPageAudioTimer;

  // Animation & Timeline
  late AnimationController _sparkleController;
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

  // Roles & Mappings
  List<StoryRoleTemplate> storyRoles = [];
  List<UserStoryCharacterMapping> storyMappings = [];

  StoryPlayerController({
    required this.vsync,
    required this.story,
    required this.appState,
    this.readingLogId,
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

  double get playheadMs => playhead.value * animationDurationMs;

  void initialize() {
    // Khởi tạo playhead controller
    playhead;

    // Lắng nghe audio
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

    storyRoles = List<StoryRoleTemplate>.from(story.roles);
    pages = List<StoryPage>.from(story.pages);
    activeReadingLogId = readingLogId;
    quizTemplates = List<StoryQuizTemplate>.from(story.quizTemplates);
    storyQuizzes = List<QuizQuestion>.from(story.allQuizzes);
    tabQuizStartTime = DateTime.now();

    isLoadingPages = true;

    loadStoryRolesAndMappings();
    preloadAllStoryVocabularies();
    preloadStoryQuizzesAndReadingLog();
    ensureStoryPagesLoaded();

    if (pages.isNotEmpty) {
      currentPageIndex = (story.currentPage - 1).clamp(0, pages.length - 1);
      syncActionForCurrentPage(pages[currentPageIndex], fromInitState: true);
    }

    _sparkleController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1400),
    )..addListener(() {
        for (final p in particles) {
          p.update();
        }
        particles.removeWhere((p) => p.life <= 0);
        notifyListeners();
      });
    _sparkleController.repeat();
    spawnFireflies();
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
    final random = Random();
    for (int i = 0; i < 6; i++) {
      particles.add(
        FireflyParticle(
          x: 20 + random.nextDouble() * 320,
          y: 20 + random.nextDouble() * 180,
          vx: (random.nextDouble() - 0.5) * 1.5,
          vy: (random.nextDouble() - 0.5) * 1.5,
          color: const Color(0xFFFBBF24),
          maxLife: (40 + random.nextInt(30)).toDouble(),
        ),
      );
    }
    notifyListeners();
  }

  void triggerScreenShake() {
    screenShakeOffset = 8.0;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 80), () {
      screenShakeOffset = -6.0;
      notifyListeners();
      Future.delayed(const Duration(milliseconds: 80), () {
        screenShakeOffset = 0.0;
        notifyListeners();
      });
    });
  }

  void toggleAudio() {
    final currentPage = (pages.isNotEmpty && currentPageIndex < pages.length)
        ? pages[currentPageIndex]
        : null;
    final audioUrl = currentPage?.audioNarrationUrl;
    audioService.toggleAudio(
      audioUrl,
      pageNumber: currentPageIndex + 1,
      storyTitle: story.title,
    );

    if (!isPlayingAudio) {
      replayPageMotion();
    }
  }

  void changePage(int newIndex, List<StoryPage> allPages) {
    if (newIndex < 0 || newIndex >= allPages.length) return;
    final wasPlaying = isPlayingAudio;
    final prevSlots = List<CharacterSlotTemplate>.from(activePageSlots);
    currentPageIndex = newIndex;
    syncActionForCurrentPage(
      allPages[newIndex],
      previousSlots: prevSlots,
    );
    spawnFireflies();
    if (wasPlaying) {
      final newPage = allPages[newIndex];
      audioService.playAudio(
        newPage.audioNarrationUrl,
        pageNumber: newIndex + 1,
        storyTitle: story.title,
      );
    }

    // Cập nhật tiến độ đọc lên Backend API (PUT /api/reading-logs/{id}/progress)
    if (activeReadingLogId != null && AppConfig.isValidUuid(activeReadingLogId)) {
      final duration = DateTime.now().difference(storySessionStartTime).inSeconds;
      ReadingLogService.updateProgress(
        readingLogId: activeReadingLogId!,
        currentPage: newIndex + 1,
        readDurationSeconds: duration,
        token: appState.authToken,
      );
    }

    notifyListeners();
  }

  /// Đánh dấu hoàn thành phiên đọc trên Backend API (PUT /api/reading-logs/{id}/complete)
  Future<void> completeReadingSession() async {
    if (activeReadingLogId != null && AppConfig.isValidUuid(activeReadingLogId)) {
      await ReadingLogService.completeReadingSession(
        readingLogId: activeReadingLogId!,
        token: appState.authToken,
      );
    }
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
        notifyListeners();
      }
    } catch (_) {}

    if (AppConfig.isValidUuid(story.id)) {
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
    isLoadingPages = true;
    notifyListeners();

    try {
      final needLoad = story.id.isNotEmpty &&
          (pages.isEmpty ||
              pages.length < story.totalPages ||
              pages.any((p) => p.id == null || p.id!.startsWith('local-page-')));

      if (needLoad) {
        final backendPages = await StoryService.fetchStoryTemplatePages(
          story.id,
          token: appState.authToken,
          storyTitle: story.title,
          totalPages: story.totalPages,
        );
        if (backendPages.isNotEmpty) {
          pages = backendPages.map((dto) {
            return StoryPage(
              id: dto.id,
              pageNumber: dto.pageNumber,
              imageUrl: dto.fullImageUrl.isNotEmpty ? dto.fullImageUrl : story.coverUrl,
              textContent: dto.rawText,
              englishSubtitle: dto.rawText,
              chapterTitle: 'Trang ${dto.pageNumber}: ${story.title}',
              narratorName: 'Chú Gấu Pô',
              audioNarrationUrl: dto.audioNarrationUrl,
              slots: dto.slots,
              animationClips: dto.animationClips,
            );
          }).toList();

          pages.sort((a, b) => a.pageNumber.compareTo(b.pageNumber));
        }
      }

      if (pages.isNotEmpty) {
        currentPageIndex = (story.currentPage - 1).clamp(0, pages.length - 1);
        syncActionForCurrentPage(pages[currentPageIndex], fromInitState: true);
      }

      await preloadAllStorySlots();

      // Delay 650ms để màn hình loading hiển thị êm ái, tránh chớp giật màn hình
      await Future.delayed(const Duration(milliseconds: 650));
    } catch (_) {
    } finally {
      isLoadingPages = false;
      notifyListeners();
    }
  }

  Future<void> preloadAllStorySlots() async {
    for (final page in pages) {
      final pageId = page.id;
      if (pageId == null || !AppConfig.isValidUuid(pageId)) continue;
      final key = _pageSlotKey(page);
      if (slotsCacheByPage.containsKey(key)) continue;
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
        }
      } catch (_) {}
    }
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
    final initialSlots = cached ??
        (page.slots.isNotEmpty
            ? page.slots
            : const <CharacterSlotTemplate>[]);

    if (initialSlots.isNotEmpty) {
      _applyPageSlots(
        page,
        initialSlots,
        restartTimeline: true,
      );
    } else {
      originalPageSlots = [];
      activePageSlots = [];
      activeAnimationClips = [];
      notifyListeners();
    }

    if (page.id == null || !AppConfig.isValidUuid(page.id)) return;

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
        final currentPage = (pages.isNotEmpty && currentPageIndex < pages.length)
            ? pages[currentPageIndex]
            : null;
        if (currentPage != null && _pageSlotKey(currentPage) == key) {
          _applyPageSlots(
            currentPage,
            fetched,
            restartTimeline: true,
          );
        }
      }
    } catch (_) {}
  }

  void _applyPageSlots(
    StoryPage page,
    List<CharacterSlotTemplate> rawSlots, {
    bool restartTimeline = true,
  }) {
    final slots = StoryAnimationEngine.collapseRoleWaypoints(rawSlots);
    final hasExplicitClips = page.animationClips.isNotEmpty ||
        slots.any((s) => s.animationClips.isNotEmpty);
    final clips = page.animationClips.isNotEmpty
        ? page.animationClips
        : StoryAnimationEngine.buildContextualClipsForSlots(
            slots: slots,
            previousSlots: previousPageSlots,
            pageNumber: page.pageNumber,
            storyTitle: story.title,
          );
    final durationMs = StoryAnimationEngine.animationDuration(
      clips,
      slots: slots,
      minDurationMs: 4200.0,
      loopHoldMs: hasExplicitClips ? 1100.0 : 0.0,
    );

    originalPageSlots = List<CharacterSlotTemplate>.from(slots);
    activePageSlots = List<CharacterSlotTemplate>.from(slots);
    activeAnimationClips = clips;
    animationDurationMs = durationMs;
    userDraggedSlotIds.clear();

    if (slots.isNotEmpty) {
      if (restartTimeline || !playhead.isAnimating) {
        startTimelineLoop();
      } else {
        playhead.duration = Duration(
          milliseconds: durationMs.round().clamp(600, 30000),
        );
      }
    }
    notifyListeners();
  }

  KidCharacter? resolveMappedKidCharacter(String? roleId) {
    final fromState = appState.getMappedCharacterForRole(
      story.id,
      roleId,
    );
    if (fromState != null && fromState.isParentApproved) return fromState;

    if (roleId == null || roleId.isEmpty) return null;
    for (final m in storyMappings) {
      if (m.isApproved &&
          m.storyRoleTemplateId.toLowerCase() == roleId.toLowerCase()) {
        for (final c in appState.characters) {
          if (c.id == m.characterId && c.isParentApproved) return c;
        }
      }
    }
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
      matchedRole ??= storyRoles.isNotEmpty ? storyRoles.first : null;

      final activeKidChar = resolveMappedKidCharacter(rawSlot.storyRoleTemplateId);
      final displayName = activeKidChar?.name ?? matchedRole?.roleName ?? 'Nhân vật';
      final fallbackAsset = _localFallbackAssetForRole(
        matchedRole?.roleName ?? displayName,
        pageNum,
      );

      String primaryUrl = '';
      if (activeKidChar != null && activeKidChar.avatar3dUrl.isNotEmpty) {
        primaryUrl = activeKidChar.avatar3dUrl;
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
    for (final page in story.pages) {
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
      } catch (_) {}
    }
    notifyListeners();
  }

  void markVocabLearned(String vocabId) {
    learnedVocabIds.add(vocabId);
    spawnFireflies();
    notifyListeners();
  }

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

    if (activeReadingLogId == null) {
      final childProfileId = appState.activeChildProfile?.id;
      if (AppConfig.isValidUuid(childProfileId)) {
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
            matched ??= history.cast<ReadingLogQuizSummary?>().firstWhere(
              (s) => s != null && !s.isQuizCompleted && AppConfig.isValidUuid(s.readingLogId),
              orElse: () => null,
            );
            if (matched != null) {
              activeReadingLogId = matched.readingLogId;
              notifyListeners();
            }
          }
        } catch (_) {}
      }
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
    if (activeReadingLogId != null &&
        template != null &&
        AppConfig.isValidUuid(activeReadingLogId) &&
        AppConfig.isValidUuid(template.id)) {
      isSubmittingTabQuiz = true;
      notifyListeners();
      try {
        serverResult = await QuizService.submitAnswer(
          readingLogId: activeReadingLogId!,
          storyQuizTemplateId: template.id,
          selectedOptionIndex: selectedTabQuizOption,
          responseTimeSeconds: elapsedSeconds,
          childProfileId: appState.activeChildProfile?.id,
          token: appState.authToken,
        );
      } finally {
        isSubmittingTabQuiz = false;
        notifyListeners();
      }
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
    _audioPosSub?.cancel();
    _audioDurSub?.cancel();
    _audioStateSub?.cancel();
    _lastPageAudioTimer?.cancel();
    audioService.dispose();
    _playheadController?.dispose();
    _sparkleController.dispose();
    super.dispose();
  }
}

