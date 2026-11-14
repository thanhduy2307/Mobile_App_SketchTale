import 'dart:convert';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/child_profile_service.dart';
import '../services/story_service.dart';
import '../services/auth_service.dart';
import '../services/character_mapping_service.dart';
import '../services/char_type_service.dart';
import '../services/content_report_service.dart';
import '../services/reading_log_service.dart';
import '../services/character_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_config.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  // Kid Profile Data
  String kidName = 'Bé Bống';
  int stars = 120;
  int streakDays = 3;
  int screenTimeMinutesAllowed = 45;
  int screenTimeUsedToday = 20;
  int remainingTimeMinutesAllowed = 45;
  int dailyCharacterLimit = 5;
  int remainingCharacterLimit = 5;
  int parentCredits =
      3690; // Parent balance for AI Vision (-30) & Character Gen (-150 / -50)
  bool isLoggedIn = false;
  String? authToken;
  String? refreshToken;
  String userRole = 'Child'; // "Child", "Parent", "Admin", "ContentManager"
  String? childUsername;
  UserProfile? userProfile;

  /// ID (GUID) của tài khoản User đang đăng nhập (lấy từ UserProfile, giải mã JWT token, hoặc Active Profile)
  String? get currentUserId =>
      (userProfile?.id != null && AppConfig.isValidUuid(userProfile!.id))
      ? userProfile!.id
      : (AppConfig.extractUserIdFromJwt(authToken) ??
            (AppConfig.isValidUuid(activeChildProfile?.id)
                ? activeChildProfile?.id
                : null));

  // Active Child Profile from Swagger /api/child-profiles
  ChildProfile? activeChildProfile;
  List<ChildProfile> childProfiles = [];
  bool isLoadingProfiles = false;
  String? customAvatarPath;

  /// Đường dẫn ảnh đại diện của bé đồng bộ theo cài đặt của Phụ Huynh / Bé
  String get childAvatarAsset {
    if (customAvatarPath != null && customAvatarPath!.isNotEmpty) {
      return customAvatarPath!;
    }
    if (activeChildProfile != null) {
      return activeChildProfile!.avatarAssetPath;
    }
    final lower = kidName.toLowerCase();
    if (lower.contains('bống') || lower.contains('đổng') || lower.contains('bong') || lower.contains('dong')) {
      return 'assets/images/child-avatars/child-01.png';
    }
    if (lower.contains('bo') || lower.contains('bơ') || lower.contains('bảo')) {
      return 'assets/images/child-avatars/child-02.png';
    }
    if (lower.contains('mimi') || lower.contains('mi mi') || lower.contains('mây') || lower.contains('may')) {
      return 'assets/images/child-avatars/child-03.png';
    }
    return 'assets/images/child-avatars/child-01.png';
  }

  void setCustomAvatar(String path) {
    customAvatarPath = path;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('sketchtale_child_avatar', path);
    }).catchError((_) {});
  }

  /// ID hợp lệ của hồ sơ trẻ em (ChildProfileId) dùng cho các API
  String? get effectiveChildProfileId {
    if (activeChildProfile != null && AppConfig.isValidUuid(activeChildProfile!.id)) {
      return activeChildProfile!.id;
    }
    for (final p in childProfiles) {
      if (AppConfig.isValidUuid(p.id) && p.id != '00000000-0000-0000-0000-000000000000') {
        return p.id;
      }
    }
    return AppConfig.extractUserIdFromJwt(authToken);
  }

  // Character Types loaded from /api/char-types
  List<CharType> charTypes = [];
  bool isLoadingCharTypes = false;

  // Selected Story for Reading & Role assignment
  late Story currentStory;

  // Character Roles Assignment
  KidCharacter? heroCharacter;
  KidCharacter? companionCharacter;
  final Map<String, UserStoryCharacterMapping> storyRoleMappings = {};

  // List of kid's characters
  List<KidCharacter> characters = [];

  // List of all interactive stories
  List<Story> stories = [];

  // Story Templates & Education Themes loaded from API
  List<StoryTemplate> storyTemplates = [];
  List<EducationTheme> educationThemes = [];
  bool isLoadingStories = false;
  bool isLoadingStoryPages = false;
  String? storyLoadError;

  /// True whenever any global backend fetch is in flight
  bool get isAnyLoading =>
      isLoadingStories ||
      isLoadingProfiles ||
      isLoadingCharTypes ||
      isLoadingStoryPages;

  // Filter for Library
  String selectedCategory = 'Tất Cả';

  // ==========================================
  // FALLBACK & OFFLINE RESILIENCE STATUS
  // ==========================================
  final Map<String, bool> _fallbackStatus = {
    'Hồ Sơ Của Bé': false,
    'Thư Viện Truyện': false,
    'Chủng Loại Nhân Vật': false,
  };

  Map<String, bool> get fallbackStatus => Map.unmodifiable(_fallbackStatus);

  /// Whether any active service is currently operating in fallback mode
  bool get isFallbackMode =>
      _fallbackStatus.values.any((isFallback) => isFallback);

  /// List of features currently running in fallback mode
  List<String> get activeFallbackFeatures =>
      _fallbackStatus.entries.where((e) => e.value).map((e) => e.key).toList();

  void setFallbackStatus(String feature, bool isFallback) {
    if (_fallbackStatus[feature] != isFallback) {
      _fallbackStatus[feature] = isFallback;
      notifyListeners();
    }
  }

  /// Refreshes all core backend data at once and updates fallback status
  Future<void> syncAllData() async {
    await Future.wait([
      fetchChildProfiles(),
      fetchStoryTemplates(),
      fetchCharTypes(),
      if (authToken != null && authToken!.isNotEmpty) fetchUserProfile(),
    ]);
  }

  // Drawing Canvas State
  List<List<DrawingPoint>> strokeLines = [];
  Color currentBrushColor = const Color(0xFFF59E0B);
  double currentBrushSize = 8.0;
  bool isEraserMode = false;
  bool isCameraScannerMode = false;
  String selectedPersonality = 'Dũng Sĩ'; // 'Dũng Sĩ', 'Thú Cưng', 'Phù Thủy'

  /// Whether the child has daily character creation attempts left
  bool get canCreateCharacter =>
      activeChildProfile?.canCreateCharacter ?? (remainingCharacterLimit > 0);

  /// Whether parent has enough credit for Stage 1 vision analysis (30 credits)
  bool get canAffordAnalyze => parentCredits >= 30;

  /// Whether parent has enough credit for Stage 2 character generation (150 credits)
  bool get canAffordGenerate => parentCredits >= 150;

  /// Whether parent has enough credit for character regeneration (50 credits)
  bool get canAffordRegenerate => parentCredits >= 50;

  /// Whether parent has sufficient credits for full 2-stage creation (180 credits)
  bool get canAffordFullCreation => parentCredits >= 180;

  /// Whether the child has remaining screen time today
  bool get hasRemainingScreenTime =>
      activeChildProfile?.hasRemainingTime ?? (remainingTimeMinutesAllowed > 0);

  static const emptyQuiz = QuizQuestion(
    questionText: '',
    visualClueUrl: '',
    options: [],
    optionEmojis: [],
    correctIndex: 0,
    celebrationTitle: '',
    celebrationMessage: '',
  );

  static const emptyStory = Story(
    id: '',
    title: 'Chưa có câu chuyện',
    subtitle: '',
    coverUrl: '',
    ageRange: '',
    category: '',
    totalPages: 0,
    currentPage: 0,
    isCompleted: false,
    durationMinutes: 0,
    rating: 0.0,
    narrator: '',
    characterName: '',
    pages: [],
    quiz: emptyQuiz,
  );

  AppState() {
    _initializeInitialData();
    restoreSession();
  }

  void _initializeInitialData() {
    characters = [];
    _completedStoryIds.clear();
    heroCharacter = null;
    companionCharacter = null;

    storyTemplates = [];
    stories = [];
    currentStory = emptyStory;
  }

  Future<void> login(
    String name, {
    String? token,
    String? refreshToken,
    String? username,
    String? role,
    UserProfile? profile,
    String? avatarPath,
  }) async {
    // Dọn sạch dữ liệu bộ nhớ của tài khoản trước đó để không bị rò rỉ
    characters = [];
    _completedStoryIds.clear();
    stories = stories.map((s) => s.copyWith(isCompleted: false)).toList();

    if (name.trim().isNotEmpty) {
      kidName = name.trim();
    }
    if (avatarPath != null && avatarPath.isNotEmpty) {
      customAvatarPath = avatarPath;
    }
    if (token != null) {
      authToken = token;
    }
    if (refreshToken != null) {
      this.refreshToken = refreshToken;
    }
    if (username != null) {
      childUsername = username;
    }
    if (role != null) {
      userRole = role;
    }
    if (profile != null) {
      userProfile = profile;
    }
    isLoggedIn = true;

    // Immediately resolve child ID from JWT token so ChildProfileId is never empty or fallback
    final extractedUserId = AppConfig.extractUserIdFromJwt(token);
    if (extractedUserId != null) {
      if (activeChildProfile == null ||
          !AppConfig.isValidUuid(activeChildProfile?.id)) {
        activeChildProfile = ChildProfile(
          id: extractedUserId,
          nickName: kidName,
          dailyTimeLimit: screenTimeMinutesAllowed,
          remainingTimeLimit: remainingTimeMinutesAllowed,
          dailyCharacterLimit: dailyCharacterLimit,
          remainingCharacterLimit: remainingCharacterLimit,
          stars: stars,
          streakDays: streakDays,
        );
      }
    }

    notifyListeners();

    // Persist session to SharedPreferences (LocalStorage on Web)
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sketchtale_logged_in', true);
      if (authToken != null)
        await prefs.setString('sketchtale_auth_token', authToken!);
      if (this.refreshToken != null)
        await prefs.setString('sketchtale_refresh_token', this.refreshToken!);
      if (childUsername != null)
        await prefs.setString('sketchtale_username', childUsername!);
      await prefs.setString('sketchtale_nickname', kidName);
      if (customAvatarPath != null)
        await prefs.setString('sketchtale_child_avatar', customAvatarPath!);
      if (userRole.isNotEmpty)
        await prefs.setString('sketchtale_role', userRole);
    } catch (e) {
      debugPrint('[AppState] Lỗi lưu phiên đăng nhập: $e');
    }

    _loadCharactersFromPrefs();
    _loadCompletedStoriesFromPrefs();
    fetchStoryTemplates();
    fetchChildProfiles();
    fetchUserProfile();
    fetchCharTypes();
  }

  /// Khôi phục phiên đăng nhập từ LocalStorage / SharedPreferences khi reload trang F5
  Future<void> restoreSession() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final prefs = await SharedPreferences.getInstance();
      final savedLoggedIn = prefs.getBool('sketchtale_logged_in') ?? false;
      final savedToken = prefs.getString('sketchtale_auth_token');
      final savedUsername = prefs.getString('sketchtale_username');
      final savedNickname = prefs.getString('sketchtale_nickname');
      final savedRole = prefs.getString('sketchtale_role');
      final savedAvatar = prefs.getString('sketchtale_child_avatar');
      if (savedAvatar != null && savedAvatar.isNotEmpty) {
        customAvatarPath = savedAvatar;
      }

      if (savedLoggedIn && savedToken != null && savedToken.isNotEmpty) {
        authToken = savedToken;
        refreshToken = prefs.getString('sketchtale_refresh_token');
        if (savedUsername != null && savedUsername.isNotEmpty) {
          childUsername = savedUsername;
        }
        if (savedNickname != null && savedNickname.isNotEmpty) {
          kidName = savedNickname;
        }
        if (savedRole != null && savedRole.isNotEmpty) {
          userRole = savedRole;
        }
        isLoggedIn = true;

        // Immediately resolve child ID from JWT token on restore
        final extractedUserId = AppConfig.extractUserIdFromJwt(authToken);
        if (extractedUserId != null) {
          if (activeChildProfile == null ||
              !AppConfig.isValidUuid(activeChildProfile?.id)) {
            activeChildProfile = ChildProfile(
              id: extractedUserId,
              nickName: kidName,
              dailyTimeLimit: screenTimeMinutesAllowed,
              remainingTimeLimit: remainingTimeMinutesAllowed,
              dailyCharacterLimit: dailyCharacterLimit,
              remainingCharacterLimit: remainingCharacterLimit,
              stars: stars,
              streakDays: streakDays,
            );
          }
        }

        notifyListeners();

        // Tải lại dữ liệu đúng tài khoản sau khi khôi phục phiên
        await _loadCharactersFromPrefs();
        await _loadCompletedStoriesFromPrefs();
        fetchStoryTemplates();
        fetchChildProfiles();
        fetchUserProfile();
        fetchCharTypes();
      } else {
        // Chưa đăng nhập -> dọn sạch bộ nhớ
        characters = [];
        _completedStoryIds.clear();
      }
    } catch (e) {
      debugPrint('[AppState] Lỗi khôi phục phiên: $e');
    }
  }

  /// Tải danh sách hồ sơ của bé từ GET /api/child-profiles
  Future<void> fetchChildProfiles() async {
    isLoadingProfiles = true;
    notifyListeners();

    try {
      final profiles = await ChildProfileService.fetchChildProfiles(
        token: authToken,
      );
      final jwtUserId = AppConfig.extractUserIdFromJwt(authToken);
      final effectiveUserId = currentUserId ?? jwtUserId;

      if (profiles.isNotEmpty) {
        setFallbackStatus('Hồ Sơ Của Bé', false);
        childProfiles = profiles;

        // 1. Khớp theo userId tài khoản
        ChildProfile? matched;
        if (effectiveUserId != null && effectiveUserId.isNotEmpty) {
          matched = childProfiles.where(
            (p) =>
                (p.userId != null &&
                    p.userId!.toLowerCase() == effectiveUserId.toLowerCase()) ||
                p.id.toLowerCase() == effectiveUserId.toLowerCase(),
          ).firstOrNull;
        }

        // 2. Khớp theo username hoặc tên bé nếu chưa khớp
        if (matched == null && childUsername != null && childUsername!.isNotEmpty) {
          matched = childProfiles.where(
            (p) => p.nickName.toLowerCase() == childUsername!.toLowerCase(),
          ).firstOrNull;
        }

        if (matched == null && kidName.isNotEmpty && kidName != 'Bé Bống' && kidName != 'Bé Đổng') {
          matched = childProfiles.where(
            (p) => p.nickName.toLowerCase() == kidName.toLowerCase(),
          ).firstOrNull;
        }

        // 3. Nếu tìm thấy đúng hồ sơ của tài khoản đang đăng nhập -> gán activeChildProfile
        if (matched != null) {
          activeChildProfile = matched;
          kidName = matched.nickName;
          screenTimeMinutesAllowed = matched.dailyTimeLimit;
          remainingTimeMinutesAllowed = matched.remainingTimeLimit;
          dailyCharacterLimit = matched.dailyCharacterLimit;
          remainingCharacterLimit = matched.remainingCharacterLimit;
        } else if (activeChildProfile == null && userRole.toLowerCase() == 'parent') {
          // Chỉ phụ huynh quản lý nhiều con thì mới mặc định chọn bé đầu tiên
          activeChildProfile = childProfiles.first;
          kidName = childProfiles.first.nickName;
        }
        // Lưu ý: Nếu là tài khoản Trẻ em không khớp danh sách, KHÔNG tự ý lấy childProfiles.first
        // để tránh tình trạng đăng nhập tài khoản khác nhưng bị ghi đè thông tin bé khác.

        final rec = recommendedStories;
        if (rec.isNotEmpty) {
          currentStory = rec.first;
        }
      } else {
        childProfiles = [];
      }
    } catch (_) {
      childProfiles = [];
    } finally {
      isLoadingProfiles = false;
      notifyListeners();
    }
  }

  /// Cập nhật hồ sơ bé lên Swagger API (PUT /api/child-profiles/{id})
  Future<bool> updateActiveProfile(ChildProfile updated) async {
    activeChildProfile = updated;
    kidName = updated.nickName;
    screenTimeMinutesAllowed = updated.dailyTimeLimit;
    remainingTimeMinutesAllowed = updated.remainingTimeLimit;
    dailyCharacterLimit = updated.dailyCharacterLimit;
    remainingCharacterLimit = updated.remainingCharacterLimit;
    notifyListeners();

    if (updated.id.isNotEmpty && !updated.id.startsWith('local-')) {
      final success = await ChildProfileService.updateChildProfile(
        updated.id,
        updated.toUpdateDto(),
        token: authToken,
      );
      if (success) {
        final idx = childProfiles.indexWhere((p) => p.id == updated.id);
        if (idx != -1) {
          childProfiles[idx] = updated;
        }
      }
      return success;
    }
    return true;
  }

  /// Nhóm tuổi số tương ứng trong StoryTemplate (1: 3-5 tuổi, 2: 6-8 tuổi, 3: 9-12 tuổi)
  int get currentChildAgeGroup {
    if (activeChildProfile != null) {
      return activeChildProfile!.matchedStoryAgeGroup;
    }
    return 2;
  }

  /// Tên nhãn độ tuổi thân thiện của bé
  String get childAgeGroupLabel {
    switch (currentChildAgeGroup) {
      case 1:
        return '3 - 5 tuổi';
      case 2:
        return '6 - 8 tuổi';
      case 3:
        return '9 - 12 tuổi';
      default:
        return 'Nhóm $currentChildAgeGroup';
    }
  }

  /// Danh sách StoryTemplate được sắp xếp ưu tiên theo đúng độ tuổi của bé trước tiên
  List<StoryTemplate> get recommendedStoryTemplates {
    final targetAge = currentChildAgeGroup;
    final list = List<StoryTemplate>.from(storyTemplates);
    list.sort((a, b) {
      final aMatch = (a.ageGroup == targetAge) ? 0 : 1;
      final bMatch = (b.ageGroup == targetAge) ? 0 : 1;
      if (aMatch != bMatch) return aMatch.compareTo(bMatch);
      final aDist = (a.ageGroup - targetAge).abs();
      final bDist = (b.ageGroup - targetAge).abs();
      if (aDist != bDist) return aDist.compareTo(bDist);
      return a.title.compareTo(b.title);
    });
    return list;
  }

  /// Danh sách Story được sắp xếp ưu tiên đề xuất theo độ tuổi của bé
  List<Story> get recommendedStories {
    final targetAge = currentChildAgeGroup;
    final list = List<Story>.from(stories);
    list.sort((a, b) {
      final tA = storyTemplates.firstWhere(
        (t) => t.id == a.id,
        orElse: () => StoryTemplate(
          id: a.id,
          educationThemeId: '',
          title: a.title,
          description: a.subtitle,
          ageGroup: _inferAgeGroupFromRange(a.ageRange),
          coverImageUrl: '',
          totalPageNumbers: 2,
          status: 2,
        ),
      );
      final tB = storyTemplates.firstWhere(
        (t) => t.id == b.id,
        orElse: () => StoryTemplate(
          id: b.id,
          educationThemeId: '',
          title: b.title,
          description: b.subtitle,
          ageGroup: _inferAgeGroupFromRange(b.ageRange),
          coverImageUrl: '',
          totalPageNumbers: 2,
          status: 2,
        ),
      );
      final aMatch = (tA.ageGroup == targetAge) ? 0 : 1;
      final bMatch = (tB.ageGroup == targetAge) ? 0 : 1;
      if (aMatch != bMatch) return aMatch.compareTo(bMatch);
      final aDist = (tA.ageGroup - targetAge).abs();
      final bDist = (tB.ageGroup - targetAge).abs();
      if (aDist != bDist) return aDist.compareTo(bDist);
      return a.title.compareTo(b.title);
    });
    return list;
  }

  int _inferAgeGroupFromRange(String range) {
    if (range.contains('3') || range.contains('4') || range.contains('5'))
      return 1;
    if (range.contains('6') || range.contains('7') || range.contains('8'))
      return 2;
    if (range.contains('9') ||
        range.contains('10') ||
        range.contains('11') ||
        range.contains('12'))
      return 3;
    return 2;
  }

  /// Đổi bé đang sử dụng ứng dụng
  void selectChildProfile(ChildProfile profile) {
    activeChildProfile = profile;
    kidName = profile.nickName;
    screenTimeMinutesAllowed = profile.dailyTimeLimit;
    remainingTimeMinutesAllowed = profile.remainingTimeLimit;
    dailyCharacterLimit = profile.dailyCharacterLimit;
    remainingCharacterLimit = profile.remainingCharacterLimit;
    final rec = recommendedStories;
    if (rec.isNotEmpty) {
      currentStory = rec.first;
    }
    syncCompletedStoriesFromBackend();
    syncCharactersFromBackend();
    notifyListeners();
  }

  /// Fetches story templates and education themes from backend API,
  /// sorting them strictly by ageGroup ascending (từ thấp đến cao).
  Future<void> fetchStoryTemplates() async {
    // If not logged in and no token, avoid making protected calls that return 401
    if (!isLoggedIn && (authToken == null || authToken!.isEmpty)) {
      return;
    }

    isLoadingStories = true;
    storyLoadError = null;
    notifyListeners();

    try {
      final result = await StoryService.fetchStoriesSortedByAgeGroup(
        token: authToken,
      );
      if (result.templates.isNotEmpty) {
        setFallbackStatus('Thư Viện Truyện', false);
        storyTemplates = result.templates;
        educationThemes = result.themes;
        final convertedStories = storyTemplates
            .map((t) => t.toStory())
            .map((s) => s.copyWith(isCompleted: _completedStoryIds.contains(s.id)))
            .toList();
        if (convertedStories.isNotEmpty) {
          stories = convertedStories;
          final rec = recommendedStories;
          final unreadStory = rec.firstWhere(
            (s) => !s.isCompleted && !_completedStoryIds.contains(s.id),
            orElse: () => rec.isNotEmpty ? rec.first : stories[0],
          );
          currentStory = unreadStory;
        }
      } else {
        storyTemplates = [];
        stories = [];
        setFallbackStatus('Thư Viện Truyện', false);
        if (result.errorMessage != null) {
          storyLoadError = result.errorMessage;
        }
      }
    } catch (e) {
      storyTemplates = [];
      stories = [];
      setFallbackStatus('Thư Viện Truyện', false);
      storyLoadError = e.toString();
    } finally {
      isLoadingStories = false;
      notifyListeners();
    }
  }

  /// Fetches pages for a story template and updates state
  Future<StoryTemplate> loadStoryTemplatePages(StoryTemplate template) async {
    if (template.pages.isNotEmpty &&
        template.pages.length >= template.totalPageNumbers) {
      return template;
    }
    isLoadingStoryPages = true;
    notifyListeners();
    try {
      final pages = await StoryService.fetchStoryTemplatePages(
        template.id,
        token: authToken,
        storyTitle: template.title,
        totalPages: template.totalPageNumbers,
      );
      if (pages.isNotEmpty) {
        final updated = template.copyWith(pages: pages);
        final idx = storyTemplates.indexWhere((t) => t.id == template.id);
        if (idx != -1) {
          storyTemplates[idx] = updated;
        }
        final storyIdx = stories.indexWhere((s) => s.id == template.id);
        if (storyIdx != -1) {
          stories[storyIdx] = updated.toStory();
        } else {
          stories.add(updated.toStory());
        }
        if (currentStory.id == template.id) {
          currentStory = updated.toStory();
        }
        return updated;
      }
    } catch (_) {
    } finally {
      isLoadingStoryPages = false;
      notifyListeners();
    }
    return template;
  }

  /// Implements Section 3: Logout & JWT Blacklist
  Future<void> logout() async {
    final tokenToInvalidate = authToken;
    isLoggedIn = false;
    authToken = null;
    refreshToken = null;
    childUsername = null;
    userProfile = null;
    activeChildProfile = null;
    customAvatarPath = null;
    kidName = '';
    childProfiles = [];
    characters = [];
    _completedStoryIds.clear();
    stories = stories.map((s) => s.copyWith(isCompleted: false)).toList();
    userRole = 'Child';
    notifyListeners();

    // Clear saved session from SharedPreferences
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('sketchtale_logged_in');
      await prefs.remove('sketchtale_auth_token');
      await prefs.remove('sketchtale_refresh_token');
      await prefs.remove('sketchtale_username');
      await prefs.remove('sketchtale_nickname');
      await prefs.remove('sketchtale_role');
      await prefs.remove('sketchtale_child_avatar');
      // Xóa bỏ key toàn cục cũ để tránh rò rỉ nhân vật sang tài khoản khác
      await prefs.remove('sketchtale_characters_v2');
    } catch (e) {
      debugPrint('[AppState] Lỗi xóa phiên: $e');
    }

    if (tokenToInvalidate != null && tokenToInvalidate.isNotEmpty) {
      await AuthService.logout(token: tokenToInvalidate);
    }
  }

  /// Implements Section 4: Refresh Token Rotation
  Future<bool> refreshSession() async {
    if (authToken == null && refreshToken == null) return false;
    final res = await AuthService.refreshToken(
      token: authToken,
      refreshToken: refreshToken,
    );
    if (res.isSuccess && res.token != null) {
      authToken = res.token;
      if (res.refreshToken != null) {
        refreshToken = res.refreshToken;
      }
      if (res.role != null) {
        userRole = res.role!;
      }
      notifyListeners();
      return true;
    } else {
      // 7-day refresh token expired -> Logout immediately
      await logout();
      return false;
    }
  }

  /// Fetches User Profile from GET /api/auth/profile
  Future<void> fetchUserProfile() async {
    if (authToken == null || authToken!.isEmpty) return;
    try {
      final profile = await AuthService.getProfile(token: authToken!);
      if (profile != null) {
        userProfile = profile;
        userRole = profile.role;
        if (profile.parentProfile != null) {
          parentCredits = profile.parentProfile!.remainingMonthlyCreditLimit;
        }

        // Đồng bộ chuẩn xác thông tin tài khoản đang đăng nhập
        if (profile.isChild) {
          if (profile.childProfile != null && profile.childProfile!.isNotEmpty) {
            final child = ChildProfile.fromJson(profile.childProfile!);
            activeChildProfile = child;
            if (child.nickName.isNotEmpty) {
              kidName = child.nickName;
            }
            screenTimeMinutesAllowed = child.dailyTimeLimit;
            remainingTimeMinutesAllowed = child.remainingTimeLimit;
            dailyCharacterLimit = child.dailyCharacterLimit;
            remainingCharacterLimit = child.remainingCharacterLimit;
          } else {
            if (profile.displayName.isNotEmpty) {
              kidName = profile.displayName;
            } else if (profile.username.isNotEmpty) {
              kidName = profile.username;
            }
          }
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  final Set<String> _completedStoryIds = {};
  Set<String> get completedStoryIds => Set.unmodifiable(_completedStoryIds);

  List<Story> get completedStories {
    return stories.where((s) => s.isCompleted || _completedStoryIds.contains(s.id)).toList();
  }

  void markStoryCompleted(String storyId) {
    _completedStoryIds.add(storyId);
    final idx = stories.indexWhere((s) => s.id == storyId);
    if (idx != -1) {
      stories[idx] = stories[idx].copyWith(isCompleted: true);
    }
    if (currentStory.id == storyId) {
      currentStory = currentStory.copyWith(isCompleted: true);
    }
    _saveCompletedStoriesToPrefs();
    notifyListeners();
  }

  void selectStory(Story story) => setCurrentStory(story);

  void setCurrentStory(Story story) {
    currentStory = story;
    notifyListeners();
  }

  void assignHeroCharacter(KidCharacter? character) {
    heroCharacter = character;
    notifyListeners();
  }

  void assignCompanionCharacter(KidCharacter? character) {
    companionCharacter = character;
    notifyListeners();
  }

  void setHeroCharacter(KidCharacter? character) => assignHeroCharacter(character);

  void setCompanionCharacter(KidCharacter? character) => assignCompanionCharacter(character);

  void setSelectedCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  void setPersonality(String personality) {
    selectedPersonality = personality;
    notifyListeners();
  }

  void addStars(int count) {
    stars += count;
    notifyListeners();
  }

  void addStrokeLine(List<DrawingPoint> line) {
    strokeLines.add(line);
    notifyListeners();
  }

  void undoLastStroke() {
    if (strokeLines.isNotEmpty) {
      strokeLines.removeLast();
      notifyListeners();
    }
  }

  void clearCanvas() {
    strokeLines.clear();
    notifyListeners();
  }

  void setBrushColor(Color color) {
    currentBrushColor = color;
    isEraserMode = false;
    notifyListeners();
  }

  void setEraserMode(bool enabled) {
    isEraserMode = enabled;
    notifyListeners();
  }

  void setCameraScannerMode(bool enabled) {
    isCameraScannerMode = enabled;
    notifyListeners();
  }

  String get _userStorageSuffix {
    if (currentUserId != null && currentUserId!.isNotEmpty) {
      return currentUserId!;
    }
    if (childUsername != null && childUsername!.isNotEmpty) {
      return childUsername!;
    }
    if (kidName.isNotEmpty && kidName != 'Bé Bống' && kidName != 'Bé Đổng') {
      return kidName;
    }
    return 'guest';
  }

  String get _charactersStorageKey => 'sketchtale_characters_$_userStorageSuffix';
  String get _completedStoriesStorageKey => 'sketchtale_completed_stories_$_userStorageSuffix';

  Future<void> _loadCompletedStoriesFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_completedStoriesStorageKey);
      _completedStoryIds.clear();
      if (list != null && list.isNotEmpty) {
        _completedStoryIds.addAll(list);
        for (var i = 0; i < stories.length; i++) {
          if (_completedStoryIds.contains(stories[i].id)) {
            stories[i] = stories[i].copyWith(isCompleted: true);
          }
        }
        if (_completedStoryIds.contains(currentStory.id)) {
          currentStory = currentStory.copyWith(isCompleted: true);
        }
      } else {
        for (var i = 0; i < stories.length; i++) {
          stories[i] = stories[i].copyWith(isCompleted: false);
        }
        if (currentStory.isCompleted) {
          currentStory = currentStory.copyWith(isCompleted: false);
        }
      }
      notifyListeners();
      // Đồng bộ thêm từ máy chủ Backend nếu có hồ sơ bé
      syncCompletedStoriesFromBackend();
    } catch (e) {
      debugPrint('[AppState] Lỗi tải truyện hoàn thành: $e');
    }
  }

  Future<void> _saveCompletedStoriesToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_completedStoriesStorageKey, _completedStoryIds.toList());
    } catch (e) {
      debugPrint('[AppState] Lỗi lưu truyện hoàn thành: $e');
    }
  }

  /// Đồng bộ danh sách truyện đã hoàn thành từ Backend API
  /// GET /api/reading-logs/child-profiles/{childProfileId}/completed
  Future<void> syncCompletedStoriesFromBackend() async {
    final childId = activeChildProfile?.id;
    if (childId == null || !AppConfig.isValidUuid(childId)) return;

    try {
      final remoteCompleted = await ReadingLogService.fetchCompletedStories(
        childProfileId: childId,
        token: authToken,
      );

      if (remoteCompleted.isNotEmpty) {
        bool hasChanges = false;
        for (final item in remoteCompleted) {
          if (item.storyTemplateId.isNotEmpty && !_completedStoryIds.contains(item.storyTemplateId)) {
            _completedStoryIds.add(item.storyTemplateId);
            hasChanges = true;
          }
        }

        if (hasChanges) {
          for (var i = 0; i < stories.length; i++) {
            if (_completedStoryIds.contains(stories[i].id)) {
              stories[i] = stories[i].copyWith(isCompleted: true);
            }
          }
          if (_completedStoryIds.contains(currentStory.id)) {
            currentStory = currentStory.copyWith(isCompleted: true);
          }
          await _saveCompletedStoriesToPrefs();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('[AppState] Lỗi đồng bộ truyện đã đọc từ Backend: $e');
    }
  }

  Future<void> _saveCharactersToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = jsonEncode(characters.map((c) => c.toJson()).toList());
      await prefs.setString(_charactersStorageKey, listJson);
    } catch (e) {
      debugPrint('[AppState] Lỗi lưu nhân vật vào LocalStorage: $e');
    }
  }

  Future<void> _loadCharactersFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_charactersStorageKey);
      if (str != null && str.isNotEmpty) {
        final decoded = jsonDecode(str);
        if (decoded is List) {
          characters = decoded
              .whereType<Map<String, dynamic>>()
              .map((j) => KidCharacter.fromJson(j))
              .toList();
          notifyListeners();
          syncCharactersFromBackend();
          return;
        }
      }
      // Nếu tài khoản này chưa có nhân vật riêng thì đặt rỗng, không mượn nhân vật tài khoản khác
      characters = [];
      notifyListeners();
      syncCharactersFromBackend();
    } catch (e) {
      debugPrint('[AppState] Lỗi tải nhân vật từ LocalStorage: $e');
      characters = [];
    }
  }

  Future<void> reloadUserLocalData() async {
    await _loadCharactersFromPrefs();
    await _loadCompletedStoriesFromPrefs();
    syncCharactersFromBackend();
    notifyListeners();
  }

  /// Đồng bộ danh sách nhân vật của bé từ Backend API
  /// GET /api/characters/child-profiles/{childId}
  Future<void> syncCharactersFromBackend() async {
    final childId = activeChildProfile?.id;
    if (childId == null || !AppConfig.isValidUuid(childId)) return;

    try {
      final remoteList = await CharacterService.fetchCharactersByChildId(
        childId: childId,
        token: authToken,
      );

      if (remoteList.isNotEmpty) {
        characters = remoteList;
        await _saveCharactersToPrefs();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[AppState] Lỗi đồng bộ nhân vật từ Backend: $e');
    }
  }

  void addNewCharacter(KidCharacter char) {
    final idx = characters.indexWhere((c) => c.id == char.id);
    if (idx != -1) {
      characters[idx] = char;
    } else {
      characters.insert(0, char);
    }
    // KHÔNG tự động gán làm heroCharacter khi chưa được phụ huynh duyệt
    // heroCharacter chỉ được gán khi bé chủ động chọn vào vai diễn trong truyện
    _saveCharactersToPrefs();
    notifyListeners();
  }

  Future<void> updateCharacterName(String charId, String newName) async {
    final idx = characters.indexWhere((c) => c.id == charId);
    if (idx != -1) {
      characters[idx] = characters[idx].copyWith(name: newName);
      _saveCharactersToPrefs();
      notifyListeners();
    }
    if (AppConfig.isValidUuid(charId)) {
      try {
        await CharacterService.updateCharacterName(
          characterId: charId,
          newName: newName,
          token: authToken,
        );
      } catch (e) {
        debugPrint('[AppState] Lỗi gọi updateCharacterName API: $e');
      }
    }
  }

  void removeCharacter(String charId) {
    characters.removeWhere((c) => c.id == charId);
    _saveCharactersToPrefs();
    notifyListeners();
  }

  void addCharacter(KidCharacter char) => addNewCharacter(char);

  void setScreenTimeLimit(int minutes) {
    screenTimeMinutesAllowed = minutes;
    notifyListeners();
  }

  void appendPointToLastStroke(DrawingPoint point) {
    if (strokeLines.isNotEmpty) {
      strokeLines.last.add(point);
      notifyListeners();
    }
  }

  void approveCharacter(String charId) {
    final idx = characters.indexWhere((c) => c.id == charId);
    if (idx != -1) {
      characters[idx] = characters[idx].copyWith(isParentApproved: true);
      _saveCharactersToPrefs();
      notifyListeners();
    }
  }

  // ==========================================
  // WORKFLOW 3: CHARACTER CREATION & LIMITS
  // ==========================================
  /// Deduct 1 character creation attempt
  void useCharacterCreationAttempt() {
    if (remainingCharacterLimit > 0) {
      remainingCharacterLimit -= 1;
      if (activeChildProfile != null) {
        activeChildProfile = activeChildProfile!.copyWith(
          remainingCharacterLimit: remainingCharacterLimit,
        );
      }
      notifyListeners();
    }
  }

  /// Restore 1 character creation attempt (e.g. if kid cancels or generation fails)
  void restoreCharacterCreationAttempt() {
    remainingCharacterLimit += 1;
    if (activeChildProfile != null) {
      activeChildProfile = activeChildProfile!.copyWith(
        remainingCharacterLimit: remainingCharacterLimit,
      );
    }
    notifyListeners();
  }

  /// Synchronizes parent credits and daily limits after Stage 1 or Stage 2 AI calls
  void updateCreditsAndLimits({int? remainingCredits, int? remainingLimit}) {
    bool hasChanged = false;
    if (remainingCredits != null && remainingCredits != parentCredits) {
      parentCredits = remainingCredits;
      hasChanged = true;
    }
    if (remainingLimit != null && remainingLimit != remainingCharacterLimit) {
      remainingCharacterLimit = remainingLimit;
      if (activeChildProfile != null) {
        activeChildProfile = activeChildProfile!.copyWith(
          remainingCharacterLimit: remainingLimit,
        );
      }
      hasChanged = true;
    }
    if (hasChanged) {
      notifyListeners();
    }
  }

  /// Tải danh mục loại nhân vật (CharTypes) từ backend
  Future<void> fetchCharTypes() async {
    if (!isLoggedIn && (authToken == null || authToken!.isEmpty)) {
      charTypes = [];
      return;
    }

    isLoadingCharTypes = true;
    notifyListeners();
    try {
      charTypes = await CharTypeService.fetchCharTypes(token: authToken);
    } catch (_) {
      charTypes = [];
    } finally {
      isLoadingCharTypes = false;
      notifyListeners();
    }
  }

  // ==========================================
  // WORKFLOW 2: ROLE ASSIGNMENT MAPPING
  // ==========================================
  /// Gán nhân vật vào vai diễn truyện (POST /api/user-story-character-mappings)
  Future<UserStoryCharacterMapping?> assignCharacterRole({
    required String storyId,
    required String storyRoleTemplateId,
    required String characterId,
  }) async {
    final result = await CharacterMappingService.assignCharacterToRole(
      generatedStoryId: storyId,
      storyRoleTemplateId: storyRoleTemplateId,
      characterId: characterId,
      token: authToken,
    );
    if (result != null) {
      final key =
          '${storyId.toLowerCase().trim()}:${storyRoleTemplateId.toLowerCase().trim()}';
      storyRoleMappings[key] = result;
    }
    notifyListeners();
    return result;
  }

  /// Resolves a custom `KidCharacter` ONLY if the child explicitly assigned one to `(storyId, roleId)`.
  /// AND the character has been verified and approved by the parent (`isParentApproved == true`).
  KidCharacter? getMappedCharacterForRole(String storyId, String? roleId) {
    if (roleId == null || roleId.isEmpty) return null;
    final key =
        '${storyId.toLowerCase().trim()}:${roleId.toLowerCase().trim()}';
    final mapping = storyRoleMappings[key];
    if (mapping == null || !mapping.isApproved) return null;
    for (final c in characters) {
      if (c.id == mapping.characterId) {
        // Chỉ cho phép nhân vật đã được Ba Mẹ phê duyệt tham gia vào truyện
        if (!c.isParentApproved) return null;
        return c;
      }
    }
    return null;
  }

  /// Khôi phục vai diễn về mẫu gốc của Content Manager (CM)
  void clearRoleMapping(String storyId, String roleId) {
    final key =
        '${storyId.toLowerCase().trim()}:${roleId.toLowerCase().trim()}';
    storyRoleMappings.remove(key);
    notifyListeners();
  }

  /// Khôi phục toàn bộ các vai diễn trong truyện về mẫu gốc của Content Manager (CM)
  void resetRoleMappingsForStory(String storyId) {
    final prefix = '${storyId.toLowerCase().trim()}:';
    storyRoleMappings.removeWhere((key, _) => key.startsWith(prefix));
    heroCharacter = null;
    companionCharacter = null;
    notifyListeners();
  }

  // ==========================================
  // LUỒNG 8: BÁO CÁO NỘI DUNG AN TOÀN CHO BÉ
  // ==========================================
  /// Gửi báo cáo nội dung không phù hợp (POST /api/content-reports)
  Future<ContentReportResult> reportContent({
    required ReportTargetType targetType,
    required String targetId,
    required String reason,
  }) async {
    return await ContentReportService.reportContent(
      targetType: targetType,
      targetId: targetId,
      reason: reason,
      token: authToken,
    );
  }
}
