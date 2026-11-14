import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String _defaultBaseUrl = 'https://sketch-tale-be.onrender.com';
  static const String _defaultChildLoginEndpoint = '/api/auth/login/child';

  static bool _isInitialized = false;

  /// Initializes environment variables from the `.env` file.
  /// Gracefully catches any file reading errors on platforms or test environments.
  static Future<void> init() async {
    if (_isInitialized) return;
    try {
      await dotenv.load(fileName: '.env');
      if (kDebugMode) {
        debugPrint('[AppConfig] Successfully loaded .env');
        debugPrint('[AppConfig] API_BASE_URL: $baseUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AppConfig] Note: Could not load .env file ($e), using default config: $_defaultBaseUrl');
      }
    } finally {
      _isInitialized = true;
    }
  }

  /// Base API URL (e.g. https://sketch-tale-be.onrender.com)
  static String get baseUrl {
    try {
      final fromEnv = dotenv.maybeGet('API_BASE_URL');
      if (fromEnv != null && fromEnv.trim().isNotEmpty) {
        return fromEnv.trim().replaceAll(RegExp(r'/+$'), '');
      }
    } catch (_) {}
    return const String.fromEnvironment('API_BASE_URL', defaultValue: _defaultBaseUrl);
  }

  /// Child Login Endpoint (e.g. /api/auth/login/child)
  static String get childLoginEndpoint {
    try {
      final fromEnv = dotenv.maybeGet('API_LOGIN_CHILD_ENDPOINT');
      if (fromEnv != null && fromEnv.trim().isNotEmpty) {
        return fromEnv.trim();
      }
    } catch (_) {}
    return const String.fromEnvironment(
      'API_LOGIN_CHILD_ENDPOINT',
      defaultValue: _defaultChildLoginEndpoint,
    );
  }

  /// Full URL for Child Login (Backwards compatibility)
  static String get childLoginUrl => authLoginChildUrl;

  // ==========================================
  // AUTH CONTROLLER ENDPOINTS (v2.2 Specification)
  // ==========================================
  /// 2.1. Phụ huynh tự đăng ký: POST /api/auth/register/parent
  static String get authRegisterParentUrl => '$baseUrl/api/auth/register/parent';

  /// 2.2. Phụ huynh tạo tài khoản cho con: POST /api/auth/register/child
  static String get authRegisterChildUrl => '$baseUrl/api/auth/register/child';

  /// 2.3. Đăng nhập chung (Admin, ContentManager, Parent): POST /api/auth/login
  static String get authLoginUrl => '$baseUrl/api/auth/login';

  /// 2.4. Đăng nhập riêng cho Trẻ em (Child): POST /api/auth/login/child
  static String get authLoginChildUrl => '$baseUrl/api/auth/login/child';

  /// 2.5. Quên mật khẩu: POST /api/auth/forgot-password
  static String get authForgotPasswordUrl => '$baseUrl/api/auth/forgot-password';

  /// 2.6. Đặt lại mật khẩu: POST /api/auth/reset-password
  static String get authResetPasswordUrl => '$baseUrl/api/auth/reset-password';

  /// 2.7. Đổi mật khẩu: POST /api/auth/change-password
  static String get authChangePasswordUrl => '$baseUrl/api/auth/change-password';

  /// 2.8. Lấy thông tin cá nhân: GET /api/auth/profile
  static String get authProfileUrl => '$baseUrl/api/auth/profile';

  /// 2.9 & 2.10. Xác thực email: /api/auth/confirm-email
  static String get authConfirmEmailUrl => '$baseUrl/api/auth/confirm-email';

  /// 2.11. Gửi lại email xác thực: POST /api/auth/resend-confirmation-email
  static String get authResendConfirmationEmailUrl =>
      '$baseUrl/api/auth/resend-confirmation-email';

  /// 2.12. Đăng xuất (JWT Blacklist): POST /api/auth/logout
  static String get authLogoutUrl => '$baseUrl/api/auth/logout';

  /// 2.13. Cấp mới token (Refresh Token Rotation): POST /api/auth/refresh-token
  static String get authRefreshTokenUrl => '$baseUrl/api/auth/refresh-token';

  /// 2.14. Lấy Role hiện tại của người dùng: GET /api/auth/current-role
  static String get authCurrentRoleUrl => '$baseUrl/api/auth/current-role';

  // ==========================================
  // STORY TEMPLATE SWAGGER ENDPOINTS (Child Role: Actived Only)
  // ==========================================
  /// 1. GET /api/story-template/stories (Lấy tất cả story có status actived - Authorize Role Child)
  static String get storyTemplatesUrl => '$baseUrl/api/story-template/stories';

  /// 2. GET /api/story-template/stories/education-theme/{id} (Lấy tất cả story actived theo EduID - Authorize Role Child)
  static String storyTemplatesByThemeUrl(String themeId) =>
      '$baseUrl/api/story-template/stories/education-theme/$themeId';

  /// 3. GET /api/story-template/stories/{id} (Lấy chi tiết story bằng Id - Authorize Role Child)
  static String storyTemplateDetailUrl(String id) =>
      '$baseUrl/api/story-template/stories/$id';

  /// Education Themes Endpoint (GET /api/education-themes)
  static String get educationThemesUrl => '$baseUrl/api/education-themes';

  // ==========================================
  // STORY PAGE TEMPLATE SWAGGER ENDPOINTS (Child Role: Actived Pages Only)
  // ==========================================
  /// 1. GET /api/storypage-template/pages/{storyId} (Lấy tất cả trang actived của story)
  static String storyTemplatePagesUrl(String storyId) =>
      '$baseUrl/api/storypage-template/pages/$storyId';

  /// 1b. GET /api/storypage-template/all-pages/{storyId}
  /// Note: The route /api/storypage-template/pages/{storyId} causes an ASP.NET
  /// AmbiguousMatchException 500 error on the backend because it collides with /pages/{id}.
  /// Matching Web FE implementation, /all-pages/{storyId} is used to reliably fetch pages.
  static String storyTemplateAllPagesUrl(String storyId) =>
      '$baseUrl/api/storypage-template/all-pages/$storyId';

  /// 2. GET /api/storypage-template/pages/{id} (Lấy chi tiết trang)
  static String storyTemplatePageDetailUrl(String id) =>
      '$baseUrl/api/storypage-template/pages/$id';

  /// Story Page Slots Endpoint (GET /api/story-pages/{pageId}/slots)
  static String storyPageSlotsUrl(String pageId) => '$baseUrl/api/story-pages/$pageId/slots';

  /// Story Page Create Slot Endpoint (POST /api/story-pages/{pageId}/slot)
  static String storyPageCreateSlotUrl(String pageId) => '$baseUrl/api/story-pages/$pageId/slot';

  /// Story Slot URL by ID (PUT /api/story-slots/{id}, DELETE /api/story-slots/{id})
  static String storySlotUrl(String slotId) => '$baseUrl/api/story-slots/$slotId';

  // ==========================================
  // STORY ROLE TEMPLATE SWAGGER ENDPOINTS (Child Role: Actived Roles Only)
  // ==========================================
  /// 1. GET /api/story-template/{storyId}/roles (Lấy tất cả roles actived của story - Authorize Role Child)
  static String storyRolesUrl(String storyId) => '$baseUrl/api/story-template/$storyId/roles';

  /// 2. GET /api/role/{id} (Lấy role bằng Id - Authorize Role Child)
  static String storyRoleUrl(String id) => '$baseUrl/api/role/$id';

  // ==========================================
  // CHILD PROFILE SWAGGER ENDPOINTS (Child View-Only)
  // ==========================================
  /// 1. GET /api/child-profiles (List all child profiles)
  static String get childProfilesUrl => '$baseUrl/api/child-profiles';

  /// 2 & 3. GET / PUT /api/child-profiles/{id}
  static String childProfileUrl(String id) => '$baseUrl/api/child-profiles/$id';

  /// 4. GET /api/child-profiles/{id}/nickname
  static String childProfileNicknameUrl(String id) => '$baseUrl/api/child-profiles/$id/nickname';

  /// 5. GET /api/child-profiles/{id}/target-age-group
  static String childProfileTargetAgeGroupUrl(String id) => '$baseUrl/api/child-profiles/$id/target-age-group';

  /// 6. GET /api/child-profiles/{id}/daily-time-limit
  static String childProfileDailyTimeLimitUrl(String id) => '$baseUrl/api/child-profiles/$id/daily-time-limit';

  /// 7. GET /api/child-profiles/{id}/daily-character-limit
  static String childProfileDailyCharacterLimitUrl(String id) => '$baseUrl/api/child-profiles/$id/daily-character-limit';

  // ==========================================
  // VOCABULARY TEMPLATE SWAGGER ENDPOINTS (Child View-Only Learning)
  // ==========================================
  /// 1. GET /api/story-pages/{pageId}/vocabularies (List all vocabularies of a story page)
  static String storyPageVocabulariesUrl(String pageId) => '$baseUrl/api/story-pages/$pageId/vocabularies';

  /// 2. GET /api/story-vocabulary/{id} (Fetch vocabulary details)
  static String storyVocabularyUrl(String id) => '$baseUrl/api/story-vocabulary/$id';

  // ==========================================
  // STORY QUIZ TEMPLATE SWAGGER ENDPOINTS (Child View & Play-Only)
  // ==========================================
  /// 1. GET /api/story-template/{storyId}/quizzes (List all actived quizzes for story)
  static String storyQuizzesUrl(String storyId) => '$baseUrl/api/story-template/$storyId/quizzes';

  /// 2. GET /api/story-quizz/{id} / GET /api/story-quiz/{id} (Fetch single quiz details)
  static String storyQuizUrl(String id) => '$baseUrl/api/story-quizz/$id';
  static String storyQuizAltUrl(String id) => '$baseUrl/api/story-quiz/$id';

  // ==========================================
  // READING LOG SWAGGER ENDPOINTS (Child reading session & progress)
  // ==========================================
  /// 1. POST /api/reading-logs (Bắt đầu phiên đọc một cuốn truyện)
  static String get readingLogsUrl => '$baseUrl/api/reading-logs';

  /// 2. PUT /api/reading-logs/{id}/progress (Cập nhật tiến độ đọc)
  static String readingLogProgressUrl(String id) => '$baseUrl/api/reading-logs/$id/progress';

  /// 3. PUT /api/reading-logs/{id}/complete (Đánh dấu hoàn thành cuốn truyện)
  static String readingLogCompleteUrl(String id) => '$baseUrl/api/reading-logs/$id/complete';

  /// 4. GET /api/reading-logs/child-profiles/{childProfileId}/completed (Danh sách truyện bé đã đọc xong)
  static String childCompletedStoriesUrl(String childProfileId) =>
      '$baseUrl/api/reading-logs/child-profiles/$childProfileId/completed';

  // ==========================================
  // CHILD QUIZ ANSWER SWAGGER ENDPOINTS (Child submit quiz & view history)
  // ==========================================
  /// 1. POST /api/child-quiz-answers (Child nộp đáp án, BE tự chấm điểm và tính sao)
  static String get childQuizAnswersUrl => '$baseUrl/api/child-quiz-answers';
  static String get readingLogSubmitAnswerUrl => '$baseUrl/api/child-quiz-answers';

  /// 2. GET /api/child-quiz-answers/reading-logs/{readingLogId} (Kết quả quiz của 1 phiên đọc)
  static String readingLogQuizAnswersUrl(String readingLogId) =>
      '$baseUrl/api/child-quiz-answers/reading-logs/$readingLogId';

  /// 3. GET /api/child-quiz-answers/child-profiles/{childProfileId} (Lịch sử làm quiz của bé)
  static String childQuizHistoryUrl(String childProfileId) =>
      '$baseUrl/api/child-quiz-answers/child-profiles/$childProfileId';

  // ==========================================
  // MEDIA UPLOAD ENDPOINTS (Cloudinary)
  // ==========================================
  /// POST /api/upload/avatar (Upload child drawing or character avatar)
  static String get uploadAvatarUrl => '$baseUrl/api/upload/avatar';

  /// POST /api/upload/background-image (Upload background image)
  static String get uploadBackgroundImageUrl => '$baseUrl/api/upload/background-image';

  // ==========================================
  // USER STORY CHARACTER MAPPING ENDPOINTS
  // ==========================================
  /// GET / POST /api/user-story-character-mappings
  static String get userStoryCharacterMappingsUrl => '$baseUrl/api/user-story-character-mappings';

  /// GET / PATCH / DELETE /api/user-story-character-mappings/{id}
  static String userStoryCharacterMappingUrl(String id) =>
      '$baseUrl/api/user-story-character-mappings/$id';

  /// GET /api/user-story-character-mappings/character/{charId}
  static String userStoryCharacterMappingsByCharUrl(String charId) =>
      '$baseUrl/api/user-story-character-mappings/character/$charId';

  /// GET /api/user-story-character-mappings/generate-story/{generateStoryId}
  static String userStoryCharacterMappingsByStoryUrl(String generateStoryId) =>
      '$baseUrl/api/user-story-character-mappings/generate-story/$generateStoryId';

  // ==========================================
  // CHARACTER TYPES (CharTypes) ENDPOINTS
  // ==========================================
  /// GET /api/char-types (List all character types for age group classification)
  static String get charTypesUrl => '$baseUrl/api/char-types';

  /// GET /api/char-types/{id}
  static String charTypeUrl(String id) => '$baseUrl/api/char-types/$id';

  // ==========================================
  // CONTENT SAFETY & REPORT ENDPOINTS
  // ==========================================
  /// GET / POST /api/content-reports (Submit child safety / content report)
  static String get contentReportsUrl => '$baseUrl/api/content-reports';

  /// GET /api/content-reports/{id}
  static String contentReportUrl(String id) => '$baseUrl/api/content-reports/$id';

  // ==========================================
  // CREDIT COSTS ENDPOINTS (AI Feature Costs)
  // ==========================================
  /// GET /api/credit-costs (List AI features & credit deduction costs)
  static String get creditCostsUrl => '$baseUrl/api/credit-costs';

  /// GET /api/credit-costs/{id}
  static String creditCostUrl(String id) => '$baseUrl/api/credit-costs/$id';

  // ==========================================
  // 2-STAGE AI DRAWING & CHARACTER GENERATION ENDPOINTS
  // ==========================================
  /// Stage 1: POST /api/drawings/analyze (Multipart: File, DrawingType, ChildProfileId)
  static String get drawingsAnalyzeUrl => '$baseUrl/api/drawings/analyze';

  /// Stage 2: POST /api/drawings/generate-character (JSON: drawingId, charTypeId, standardizedPrompt, isRegenerate)
  static String get drawingsGenerateCharacterUrl => '$baseUrl/api/drawings/generate-character';

  // ==========================================
  // CHARACTER PREVIEW & APPROVAL ENDPOINTS
  // ==========================================
  /// POST /api/characters/{id}/accept?childProfileId={childProfileId}
  static String characterAcceptPreviewUrl(String id, {String? childProfileId}) {
    final effectiveId = (childProfileId != null && childProfileId.trim().isNotEmpty)
        ? childProfileId.trim()
        : '00000000-0000-0000-0000-000000000000';
    return '$baseUrl/api/characters/$id/accept?childProfileId=$effectiveId';
  }

  /// POST /api/characters/{id}/cancel-preview?childProfileId={childProfileId}
  static String characterCancelPreviewUrl(String id, {String? childProfileId}) {
    final effectiveId = (childProfileId != null && childProfileId.trim().isNotEmpty)
        ? childProfileId.trim()
        : '00000000-0000-0000-0000-000000000000';
    return '$baseUrl/api/characters/$id/cancel-preview?childProfileId=$effectiveId';
  }

  /// GET /api/characters/pending-approval (Parent only)
  static String get charactersPendingApprovalUrl => '$baseUrl/api/characters/pending-approval';

  /// PUT /api/characters/{id}/approve (Parent only)
  static String characterApproveUrl(String id) => '$baseUrl/api/characters/$id/approve';

  /// PUT /api/characters/{id}/reject (Parent only)
  static String characterRejectUrl(String id) => '$baseUrl/api/characters/$id/reject';

  /// GET /api/characters/child-profiles/{childId} (Lấy toàn bộ danh sách nhân vật của một bé)
  static String childCharactersUrl(String childId) => '$baseUrl/api/characters/child-profiles/$childId';

  /// PUT /api/characters/{characterId}/name (Cập nhật tên nhân vật)
  static String updateCharacterNameUrl(String characterId) => '$baseUrl/api/characters/$characterId/name';

  // ==========================================
  // CREDIT TRANSACTION LOGS ENDPOINTS
  // ==========================================
  /// GET /api/credit-transaction-logs
  static String get creditTransactionLogsUrl => '$baseUrl/api/credit-transaction-logs';

  /// GET /api/credit-transaction-logs/{id}
  static String creditTransactionLogUrl(String id) => '$baseUrl/api/credit-transaction-logs/$id';

  /// GET /api/credit-transaction-logs/parent-profile/{parentId}
  static String creditTransactionLogsByParentUrl(String parentId) =>
      '$baseUrl/api/credit-transaction-logs/parent-profile/$parentId';

  /// GET /api/credit-transaction-logs/users/{userId}
  static String creditTransactionLogsByUserUrl(String userId) =>
      '$baseUrl/api/credit-transaction-logs/users/$userId';

  /// Resolves relative API image URLs (e.g. /seed/covers/abc.png) to absolute URLs
  static String resolveImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final cleanPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$baseUrl$cleanPath';
  }

  /// High quality Cloudinary fallback audio narrations for story pages
  static const List<String> fallbackAudioNarrationUrls = [
    'https://res.cloudinary.com/yldatcw7/video/upload/v1793170151/SketchTale/audios/n0jg2belgk3jphzgelx4.mp3',
    'https://res.cloudinary.com/yldatcw7/video/upload/v1793170155/SketchTale/audios/b1dxckfypwwfz8qa5yyo.mp3',
    'https://res.cloudinary.com/yldatcw7/video/upload/v1793170159/SketchTale/audios/oift8fhzzkqo1bgx9y6b.mp3',
    'https://res.cloudinary.com/yldatcw7/video/upload/v1793170163/SketchTale/audios/ucxn64qhpsmgqobuuwx4.mp3',
    'https://res.cloudinary.com/yldatcw7/video/upload/v1793170167/SketchTale/audios/ugsylcrrivkydnkcvmuu.mp3',
  ];

  static String fallbackAudioUrlForPage(int pageNumber) {
    final idx = (pageNumber - 1).clamp(0, fallbackAudioNarrationUrls.length - 1);
    return fallbackAudioNarrationUrls[idx];
  }

  /// Resolves narration or background music audio URLs
  static String resolveAudioUrl(String? url, {int pageNumber = 1, String storyTitle = ''}) {
    if (url != null && (url.contains('bombin') || url.contains('upbeat'))) {
      return 'assets/audio/bombinsound-upbeat-advertising-version-7-only-time-626842.mp3';
    }
    final titleLower = storyTitle.toLowerCase();
    if (titleLower.contains('sharing') || titleLower.contains('picnic')) {
      return 'assets/audio/bombinsound-upbeat-advertising-version-7-only-time-626842.mp3';
    }
    if (url == null || url.trim().isEmpty) {
      return fallbackAudioUrlForPage(pageNumber);
    }
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('assets/')) {
      return trimmed;
    }
    // Seed paths that return 404 on Render backend fallback to Cloudinary narrations
    if (trimmed.contains('/seed/audio/') || trimmed.contains('seed/audio/')) {
      return fallbackAudioUrlForPage(pageNumber);
    }
    final cleanPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$baseUrl$cleanPath';
  }

  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  /// Validates if an ID is a valid GUID/UUID before sending to ASP.NET controllers
  /// (avoids 400 Bad Request on Guid path params like /story-pages/{pageId}/slots)
  static bool isValidUuid(String? id) =>
      id != null && _uuidRegex.hasMatch(id.trim());

  /// Extracts the User Id (Guid) from a JWT token payload
  static String? extractUserIdFromJwt(String? token) {
    if (token == null || token.trim().isEmpty) return null;
    final parts = token.trim().split('.');
    if (parts.length < 2) return null;
    try {
      final normalized = base64Url.normalize(parts[1]);
      final payloadString = utf8.decode(base64Url.decode(normalized));
      final decoded = jsonDecode(payloadString);
      if (decoded is Map<String, dynamic>) {
        final candidate = decoded['sub']?.toString() ??
            decoded['nameid']?.toString() ??
            decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier']?.toString() ??
            decoded['userId']?.toString() ??
            decoded['Id']?.toString() ??
            decoded['id']?.toString();
        if (isValidUuid(candidate)) {
          return candidate!.trim();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AppConfig] Error decoding JWT: $e');
      }
    }
    return null;
  }
}
