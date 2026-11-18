import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../utils/app_config.dart';
import 'api_client.dart';

class StoryDataResult {
  final List<EducationTheme> themes;
  final List<StoryTemplate> templates;
  final bool isSuccess;
  final String? errorMessage;

  const StoryDataResult({
    required this.themes,
    required this.templates,
    required this.isSuccess,
    this.errorMessage,
  });
}

class StoryService {
  static final http.Client _client = ApiClient.instance;

  /// Fetches all Education Themes from GET /api/education-themes
  static Future<List<EducationTheme>> fetchEducationThemes({String? token}) async {
    final url = Uri.parse(AppConfig.educationThemesUrl);
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      if (kDebugMode) {
        debugPrint('[StoryService] GET $url');
      }

      final response = await _client.get(url, headers: headers).timeout(
            const Duration(seconds: 15),
          );

      if (kDebugMode) {
        debugPrint('[StoryService] Themes response code: ${response.statusCode}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        final list = (decoded is Map<String, dynamic> && decoded['data'] is List)
            ? decoded['data'] as List
            : (decoded is List ? decoded : null);
        if (list != null) {
          return list
              .whereType<Map>()
              .map((item) => EducationTheme.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StoryService] Error fetching education themes: $e');
      }
    }
    return const [];
  }

  /// Fetches all Story Templates from GET /api/story-template/getallstories
  static Future<List<StoryTemplate>> fetchStoryTemplates({
    String? token,
    Map<String, EducationTheme>? themesMap,
  }) async {
    final url = Uri.parse(AppConfig.storyTemplatesUrl);
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      if (kDebugMode) {
        debugPrint('[StoryService] GET $url');
      }

      final response = await _client.get(url, headers: headers).timeout(
            const Duration(seconds: 15),
          );

      if (kDebugMode) {
        debugPrint('[StoryService] StoryTemplates response code: ${response.statusCode}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        final list = (decoded is Map<String, dynamic> && decoded['data'] is List)
            ? decoded['data'] as List
            : (decoded is List ? decoded : null);
        if (list != null && list.isNotEmpty) {
          return list
              .whereType<Map>()
              .map((item) => StoryTemplate.fromJson(
                    Map<String, dynamic>.from(item),
                    themesMap: themesMap,
                  ))
              .toList();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StoryService] Error fetching story templates: $e');
      }
    }

    return const [];
  }

  /// 2. GET /api/story-template/stories/education-theme/{id}
  /// Lấy tất cả story actived theo EduID (Authorize Role Child)
  static Future<List<StoryTemplate>> fetchStoriesByTheme(
    String themeId, {
    String? token,
    Map<String, EducationTheme>? themesMap,
  }) async {
    final url = Uri.parse(AppConfig.storyTemplatesByThemeUrl(themeId));
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      if (kDebugMode) {
        debugPrint('[StoryService] GET $url');
      }

      final response = await _client.get(url, headers: headers).timeout(
            const Duration(seconds: 15),
          );

      if (kDebugMode) {
        debugPrint('[StoryService] StoriesByTheme response code: ${response.statusCode}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        final list = (decoded is Map<String, dynamic> && decoded['data'] is List)
            ? decoded['data'] as List
            : (decoded is List ? decoded : null);
        if (list != null && list.isNotEmpty) {
          return list
              .whereType<Map>()
              .map((item) => StoryTemplate.fromJson(
                    Map<String, dynamic>.from(item),
                    themesMap: themesMap,
                  ))
              .toList();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StoryService] Error fetching stories for theme $themeId: $e');
      }
    }

    return const [];
  }

  /// 3. GET /api/story-template/stories/{id}
  /// Lấy chi tiết story bằng Id (Authorize Role Child)
  static Future<StoryTemplate?> fetchStoryById(
    String id, {
    String? token,
    Map<String, EducationTheme>? themesMap,
  }) async {
    final url = Uri.parse(AppConfig.storyTemplateDetailUrl(id));
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await _client.get(url, headers: headers).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return StoryTemplate.fromJson(decoded, themesMap: themesMap);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StoryService] Error fetching story $id: $e');
      }
    }

    return null;
  }

  /// 4. GET /api/storypage-template/pages/{storyId}
  /// Fetches actived pages for a story template (available for Child role & public reading)
  static Future<List<StoryTemplatePage>> fetchStoryTemplatePages(
    String storyTemplateId, {
    String? token,
    String? storyTitle,
    int? totalPages,
    bool isContentManager = false,
  }) async {
    final cleanId = storyTemplateId.trim();
    if (!AppConfig.isValidUuid(cleanId)) {
      return const [];
    }

    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    List<StoryTemplatePage> parsePages(dynamic body) {
      try {
        final decoded = jsonDecode(body.toString());
        final list = (decoded is Map<String, dynamic> && decoded['data'] is List)
            ? decoded['data'] as List
            : (decoded is List ? decoded : null);
        if (list != null && list.isNotEmpty) {
          final pages = list
              .whereType<Map>()
              .map((item) => StoryTemplatePage.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          pages.sort((a, b) => a.pageNumber.compareTo(b.pageNumber));
          return pages;
        }
      } catch (_) {}
      return const [];
    }

    // 1. Primary endpoint: GET /api/storypage-template/pages/{storyId}
    final pagesUrl = Uri.parse(AppConfig.storyTemplatePagesUrl(cleanId));
    try {
      if (kDebugMode) {
        debugPrint('[StoryService] GET $pagesUrl');
      }

      final response = await _client.get(pagesUrl, headers: headers).timeout(
            const Duration(seconds: 15),
          );

      if (kDebugMode) {
        debugPrint('[StoryService] StoryPages response code: ${response.statusCode}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final pages = parsePages(response.body);
        if (pages.isNotEmpty) return pages;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StoryService] Error fetching pages from $pagesUrl: $e');
      }
    }

    // 2. Secondary endpoint: GET /api/storypage-template/all-pages/{storyId}
    // Giai quyet van de xung dot route ASP.NET Core hoac role
    final allPagesUrl = Uri.parse(AppConfig.storyTemplateAllPagesUrl(cleanId));
    try {
      if (kDebugMode) {
        debugPrint('[StoryService] GET $allPagesUrl (Fallback)');
      }

      final response = await _client.get(allPagesUrl, headers: headers).timeout(
            const Duration(seconds: 12),
          );

      if (kDebugMode) {
        debugPrint('[StoryService] AllPages response code: ${response.statusCode}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final pages = parsePages(response.body);
        if (pages.isNotEmpty) return pages;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StoryService] Error fetching all-pages from $allPagesUrl: $e');
      }
    }

    return const [];
  }

  // ==========================================
  // STORY ROLE TEMPLATE (Child Role & Content Manager)
  // ==========================================
  /// 1. GET /api/story-template/{storyId}/all-roles
  /// Lấy tất cả roles của story (Authorize Role CM)
  static Future<List<StoryRoleTemplate>> fetchAllStoryRoles(
    String storyId, {
    String? token,
  }) async {
    if (!AppConfig.isValidUuid(storyId)) return const [];

    final url = Uri.parse(AppConfig.storyAllRolesUrl(storyId));
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      if (kDebugMode) {
        debugPrint('[StoryService] GET $url');
      }

      final response = await _client.get(url, headers: headers).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        final list = (decoded is Map<String, dynamic> && decoded['data'] is List)
            ? decoded['data'] as List
            : (decoded is List ? decoded : null);
        if (list != null) {
          return list
              .whereType<Map>()
              .map((item) => StoryRoleTemplate.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StoryService] Error fetching all roles for $storyId: $e');
      }
    }

    return const [];
  }

  /// 2. GET /api/story-template/{storyId}/roles
  /// Lấy tất cả roles actived của story (Authorize)
  static Future<List<StoryRoleTemplate>> fetchStoryRoles(
    String storyId, {
    String? token,
    String? storyTitle,
  }) async {
    if (!AppConfig.isValidUuid(storyId)) {
      return const [];
    }

    final url = Uri.parse(AppConfig.storyRolesUrl(storyId));
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    List<StoryRoleTemplate> parseRoles(dynamic body) {
      try {
        final decoded = jsonDecode(body.toString());
        final list = (decoded is Map<String, dynamic> && decoded['data'] is List)
            ? decoded['data'] as List
            : (decoded is List ? decoded : null);
        if (list != null && list.isNotEmpty) {
          return list
              .whereType<Map>()
              .map((item) => StoryRoleTemplate.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      } catch (_) {}
      return const [];
    }

    // 1. Primary: GET /api/story-template/{storyId}/roles
    try {
      if (kDebugMode) {
        debugPrint('[StoryService] GET $url');
      }

      final response = await _client.get(url, headers: headers).timeout(
            const Duration(seconds: 15),
          );

      if (kDebugMode) {
        debugPrint('[StoryService] Story $storyId roles response: ${response.statusCode}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final roles = parseRoles(response.body);
        if (roles.isNotEmpty) return roles;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StoryService] Error fetching roles for $storyId: $e');
      }
    }

    // 2. Fallback: GET /api/story-template/{storyId}/all-roles
    final allRolesUrl = Uri.parse(AppConfig.storyAllRolesUrl(storyId));
    try {
      if (kDebugMode) {
        debugPrint('[StoryService] GET $allRolesUrl (Fallback)');
      }
      final response = await _client.get(allRolesUrl, headers: headers).timeout(
            const Duration(seconds: 10),
          );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final roles = parseRoles(response.body);
        if (roles.isNotEmpty) return roles;
      }
    } catch (_) {}

    return const [];
  }

  /// 3. GET /api/role/{id}
  /// Lấy role bằng Id
  static Future<StoryRoleTemplate?> fetchRoleById(
    String id, {
    String? token,
  }) async {
    if (id.isEmpty) return null;

    final url = Uri.parse(AppConfig.storyRoleUrl(id));
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await _client.get(url, headers: headers).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return StoryRoleTemplate.fromJson(decoded);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StoryService] Error fetching role $id: $e');
      }
    }

    return null;
  }

  /// 4. POST /api/story-template/{storyId}/role
  /// Tạo mới một role (Authorize Role CM)
  static Future<StoryRoleTemplate?> createStoryRole({
    required String storyId,
    required String roleName,
    required StoryRoleType storyRoleType,
    String? description,
    bool allowCustomCharacter = true,
    bool requiresParentApproval = false,
    String? defaultAssetUrl,
    String? token,
  }) async {
    if (!AppConfig.isValidUuid(storyId)) return null;

    final url = Uri.parse(AppConfig.storyCreateRoleUrl(storyId));
    try {
      final request = http.MultipartRequest('POST', url);
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.fields['RoleName'] = roleName;
      request.fields['StoryRoleType'] = storyRoleType.index.toString();
      if (description != null && description.isNotEmpty) {
        request.fields['Description'] = description;
      }
      request.fields['AllowCustomCharacter'] = allowCustomCharacter.toString();
      request.fields['RequiresParentApproval'] = requiresParentApproval.toString();
      if (defaultAssetUrl != null && defaultAssetUrl.isNotEmpty) {
        request.fields['DefaultAssetUrl'] = defaultAssetUrl;
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return StoryRoleTemplate.fromJson(decoded);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StoryService] Error createStoryRole for story $storyId: $e');
      }
    }
    return null;
  }

  /// 5. PUT /api/story-role/{id}
  /// Update thông tin của role (Authorize Role CM)
  static Future<bool> updateStoryRole({
    required String roleId,
    required String roleName,
    required StoryRoleType storyRoleType,
    String? description,
    bool allowCustomCharacter = true,
    bool requiresParentApproval = false,
    String? defaultAssetUrl,
    String? token,
  }) async {
    if (!AppConfig.isValidUuid(roleId)) return false;

    final url = Uri.parse(AppConfig.storyUpdateRoleUrl(roleId));
    try {
      final request = http.MultipartRequest('PUT', url);
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.fields['RoleName'] = roleName;
      request.fields['StoryRoleType'] = storyRoleType.index.toString();
      if (description != null && description.isNotEmpty) {
        request.fields['Description'] = description;
      }
      request.fields['AllowCustomCharacter'] = allowCustomCharacter.toString();
      request.fields['RequiresParentApproval'] = requiresParentApproval.toString();
      if (defaultAssetUrl != null && defaultAssetUrl.isNotEmpty) {
        request.fields['DefaultAssetUrl'] = defaultAssetUrl;
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamedResponse);

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StoryService] Error updateStoryRole $roleId: $e');
      }
      return false;
    }
  }

  /// 6. DELETE /api/story-role/{id}
  /// Chuyển trạng thái actived -> inactived / soft delete (Authorize Role CM)
  static Future<bool> deleteStoryRole(
    String roleId, {
    String? token,
  }) async {
    if (!AppConfig.isValidUuid(roleId)) return false;

    final url = Uri.parse(AppConfig.storyDeleteRoleUrl(roleId));
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await _client.delete(url, headers: headers).timeout(
            const Duration(seconds: 15),
          );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StoryService] Error deleteStoryRole $roleId: $e');
      }
      return false;
    }
  }

  // ==========================================
  // COMBINED ORCHESTRATION FOR HOME & LIBRARY
  // ==========================================
  /// Fetches themes and story templates together, maps them, and sorts templates
  /// strictly by ageGroup in ascending order (0 -> 1 -> 2...).
  static Future<StoryDataResult> fetchStoriesSortedByAgeGroup({String? token}) async {
    try {
      final results = await Future.wait([
        fetchEducationThemes(token: token),
        fetchStoryTemplates(token: token),
      ]);

      final themes = results[0] as List<EducationTheme>;
      var templates = results[1] as List<StoryTemplate>;

      final themesMap = <String, EducationTheme>{};
      for (final t in themes) {
        themesMap[t.id] = t;
      }

      templates = templates.map((tmpl) {
        final theme = themesMap[tmpl.educationThemeId];
        return tmpl.copyWith(educationTheme: theme);
      }).toList();

      // Sort by ageGroup from lowest to highest (0 -> 1 -> 2 -> 3...)
      templates.sort((a, b) {
        final cmp = a.ageGroup.compareTo(b.ageGroup);
        if (cmp != 0) return cmp;
        return a.title.compareTo(b.title);
      });

      if (templates.isEmpty) {
        final fallbackTheme = themes.isNotEmpty
            ? themes.first
            : const EducationTheme(
                id: 'theme-nature',
                name: 'Thiên Nhiên',
                description: 'Bảo vệ thiên nhiên kỳ thú',
              );
        final defaultThemes = themes.isNotEmpty ? themes : [fallbackTheme];
        templates = defaultStoryTemplates.map((t) {
          return t.copyWith(educationTheme: fallbackTheme);
        }).toList();

        return StoryDataResult(
          themes: defaultThemes,
          templates: templates,
          isSuccess: true,
        );
      }

      if (kDebugMode) {
        debugPrint('[StoryService] Loaded ${templates.length} story templates sorted by ageGroup:');
        for (final t in templates) {
          debugPrint('  - [Age ${t.ageGroup}] "${t.title}" | Theme: ${t.educationTheme?.name ?? "Unknown"}');
        }
      }

      return StoryDataResult(
        themes: themes,
        templates: templates,
        isSuccess: templates.isNotEmpty,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StoryService] fetchStoriesSortedByAgeGroup error: $e');
      }
      const fallbackTheme = EducationTheme(
        id: 'theme-nature',
        name: 'Thiên Nhiên',
        description: 'Bảo vệ thiên nhiên kỳ thú',
      );
      return StoryDataResult(
        themes: const [fallbackTheme],
        templates: defaultStoryTemplates.map((t) => t.copyWith(educationTheme: fallbackTheme)).toList(),
        isSuccess: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// 1. GET /api/story-pages/{pageId}/slots
  /// Fetches character slot templates for a specific story page
  static Future<List<CharacterSlotTemplate>> fetchPageSlots(
    String pageId, {
    String? token,
    int? pageNumber,
    String? storyId,
    String? storyTitle,
  }) async {
    if (!AppConfig.isValidUuid(pageId)) {
      return const [];
    }

    final url = Uri.parse(AppConfig.storyPageSlotsUrl(pageId));
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      if (kDebugMode) {
        debugPrint('[StoryService] GET $url');
      }

      final response = await _client.get(url, headers: headers).timeout(
            const Duration(seconds: 15),
          );

      if (kDebugMode) {
        debugPrint('[StoryService] Page $pageId slots response code: ${response.statusCode}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        final list = (decoded is Map<String, dynamic> && decoded['data'] is List)
            ? decoded['data'] as List
            : (decoded is List ? decoded : null);
        if (list != null) {
          final parsed = list
              .whereType<Map>()
              .map((item) => CharacterSlotTemplate.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          return parsed;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StoryService] Error fetching slots for page $pageId: $e');
      }
    }
    return const [];
  }

  // ==========================================
  // STATIC MOCK / DEFAULT FALLBACK HELPERS
  // ==========================================
  /// Default role templates fallback
  static List<StoryRoleTemplate> getDefaultRolesForStory(
    String storyId, {
    String? storyTitle,
  }) {
    return [
      StoryRoleTemplate(
        id: '11911ece-1f1e-4134-8c27-978f24623c4a',
        storyTemplateId: storyId,
        storyRoleType: StoryRoleType.mainCharacter,
        roleName: 'Nhân Vật Chính',
        description: 'Nhân vật chính dũng cảm',
        allowCustomCharacter: true,
        requiresParentApproval: false,
        status: 1,
      ),
      StoryRoleTemplate(
        id: '22911ece-1f1e-4134-8c27-978f24623c4b',
        storyTemplateId: storyId,
        storyRoleType: StoryRoleType.companion,
        roleName: 'Bạn Đồng Hành',
        description: 'Người bạn đồng hành dễ thương',
        allowCustomCharacter: true,
        requiresParentApproval: false,
        status: 1,
      ),
    ];
  }

  /// Default slot templates fallback for page
  static List<CharacterSlotTemplate> getDefaultSlotsForPage(
    String pageId, {
    int? pageNumber,
    String? storyId,
    String? storyTitle,
  }) {
    if (pageNumber == 3) {
      return [
        CharacterSlotTemplate(
          id: pageId.isNotEmpty ? pageId : 'slot-p3',
          storyPageId: pageId,
          storyRoleTemplateId: '11911ece-1f1e-4134-8c27-978f24623c4a',
          posX: 28.0,
          posY: 60.0,
          scale: 1.0,
        ),
      ];
    } else if (pageNumber == 4) {
      return [
        CharacterSlotTemplate(
          id: pageId.isNotEmpty ? pageId : 'slot-p4',
          storyPageId: pageId,
          storyRoleTemplateId: '11911ece-1f1e-4134-8c27-978f24623c4a',
          posX: 68.0,
          posY: 60.0,
          scale: 1.0,
        ),
      ];
    }
    return [
      CharacterSlotTemplate(
        id: 'bobby-slot-1',
        storyPageId: pageId,
        storyRoleTemplateId: '11911ece-1f1e-4134-8c27-978f24623c4a',
        posX: 67.0,
        posY: 60.0,
        scale: 1.05,
      ),
    ];
  }

  /// Default pages for a story template fallback
  static List<StoryTemplatePage> getDefaultPagesForStory(String storyId) {
    return [
      StoryTemplatePage(
        id: 'b9e0a450-f357-48b5-a27d-b31ce11df38d',
        storyTemplateId: storyId,
        pageNumber: 1,
        imageUrl: 'https://res.cloudinary.com/page1.jpg',
        rawText: 'Bobby bước vào khu vườn kỳ diệu...',
        slots: getDefaultSlotsForPage('b9e0a450-f357-48b5-a27d-b31ce11df38d', pageNumber: 1, storyId: storyId),
      ),
      StoryTemplatePage(
        id: 'page-2-$storyId',
        storyTemplateId: storyId,
        pageNumber: 2,
        imageUrl: 'https://res.cloudinary.com/page2.jpg',
        rawText: 'Bobby chăm sóc cho những khóm hoa xinh đẹp...',
        slots: const [],
      ),
      StoryTemplatePage(
        id: '8151605a-1d43-4d7b-9a51-71abd97f04f0',
        storyTemplateId: storyId,
        pageNumber: 3,
        imageUrl: 'https://res.cloudinary.com/page3.jpg',
        rawText: 'Bobby cùng bạn nhỏ ngắm nhìn khu vườn rực rỡ...',
        slots: getDefaultSlotsForPage('8151605a-1d43-4d7b-9a51-71abd97f04f0', pageNumber: 3, storyId: storyId),
      ),
      StoryTemplatePage(
        id: '782a765f-c333-417b-8b41-0addce91ff07',
        storyTemplateId: storyId,
        pageNumber: 4,
        imageUrl: 'https://res.cloudinary.com/page4.jpg',
        rawText: 'Bobby học được bài học về tình yêu cây cỏ...',
        slots: getDefaultSlotsForPage('782a765f-c333-417b-8b41-0addce91ff07', pageNumber: 4, storyId: storyId),
      ),
      StoryTemplatePage(
        id: 'page-5-$storyId',
        storyTemplateId: storyId,
        pageNumber: 5,
        imageUrl: 'https://res.cloudinary.com/page5.jpg',
        rawText: 'Bobby và món quà của khu vườn đong đầy niềm vui...',
        slots: const [],
      ),
    ];
  }

  /// Default story templates list
  static List<StoryTemplate> get defaultStoryTemplates => [
        StoryTemplate(
          id: '21a89526-20b1-471b-bce0-bc23c4fb7418',
          educationThemeId: 'theme-nature',
          title: 'Bobby và món quà của khu vườn',
          description: 'Qua năm trang truyện sinh động, bé học được tình yêu thiên nhiên.',
          ageGroup: 0,
          coverImageUrl: 'https://res.cloudinary.com/cover.jpg',
          totalPageNumbers: 5,
          status: 2,
          pages: getDefaultPagesForStory('21a89526-20b1-471b-bce0-bc23c4fb7418'),
        ),
      ];
}
