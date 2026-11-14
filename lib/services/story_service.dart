import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../utils/app_config.dart';

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
  static final http.Client _client = http.Client();

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
        if (decoded is List) {
          return decoded
              .map((item) => EducationTheme.fromJson(item as Map<String, dynamic>))
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
        if (decoded is List && decoded.isNotEmpty) {
          return decoded.map((item) {
            return StoryTemplate.fromJson(
              item as Map<String, dynamic>,
              themesMap: themesMap,
            );
          }).toList();
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
        if (decoded is List && decoded.isNotEmpty) {
          return decoded.map((item) {
            return StoryTemplate.fromJson(
              item as Map<String, dynamic>,
              themesMap: themesMap,
            );
          }).toList();
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
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty) {
          final pages = decoded
              .map((item) => StoryTemplatePage.fromJson(item as Map<String, dynamic>))
              .toList();
          pages.sort((a, b) => a.pageNumber.compareTo(b.pageNumber));
          return pages;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StoryService] Error fetching pages from $pagesUrl: $e');
      }
    }

    // 2. Secondary endpoint for ContentManager: GET /api/storypage-template/all-pages/{storyId}
    if (isContentManager && token != null && token.isNotEmpty) {
      final allPagesUrl = Uri.parse(AppConfig.storyTemplateAllPagesUrl(cleanId));
      try {
        if (kDebugMode) {
          debugPrint('[StoryService] GET $allPagesUrl (ContentManager)');
        }

        final response = await _client.get(allPagesUrl, headers: headers).timeout(
              const Duration(seconds: 10),
            );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final decoded = jsonDecode(response.body);
          if (decoded is List && decoded.isNotEmpty) {
            final pages = decoded
                .map((item) => StoryTemplatePage.fromJson(item as Map<String, dynamic>))
                .toList();
            pages.sort((a, b) => a.pageNumber.compareTo(b.pageNumber));
            return pages;
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[StoryService] Error fetching all-pages from $allPagesUrl: $e');
        }
      }
    }

    return const [];
  }

  // ==========================================
  // STORY ROLE TEMPLATE (Child Role: Actived Roles Only)
  // ==========================================
  /// 5. GET /api/story-template/{storyId}/roles
  /// Lấy tất cả roles actived của story (Authorize Role Child)
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
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty) {
          return decoded
              .map((item) => StoryRoleTemplate.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StoryService] Error fetching roles for $storyId: $e');
      }
    }

    return const [];
  }

  /// 6. GET /api/role/{id}
  /// Lấy role bằng Id (Authorize Role Child)
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
      return StoryDataResult(
        themes: const [],
        templates: const [],
        isSuccess: false,
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
        if (decoded is List) {
          final parsed = decoded
              .map((item) => CharacterSlotTemplate.fromJson(item as Map<String, dynamic>))
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
}
