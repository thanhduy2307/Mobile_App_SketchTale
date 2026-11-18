import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../utils/app_config.dart';
import 'api_client.dart';

/// Service handling UserStoryCharacterMapping API (/api/user-story-character-mappings)
class CharacterMappingService {
  static final http.Client _client = ApiClient.instance;

  static Map<String, String> _buildHeaders(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static String _ensureGuid(String id) {
    final guidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    if (guidRegex.hasMatch(id)) {
      return id;
    }
    // Convert arbitrary ID string into a valid pseudo-UUID v4 format for ASP.NET Core Guid parser
    final clean = id.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
    final padded = '${clean}1234567890abcdef1234567890abcdef'.substring(0, 32);
    return '${padded.substring(0, 8)}-${padded.substring(8, 12)}-4${padded.substring(13, 16)}-a${padded.substring(17, 20)}-${padded.substring(20, 32)}';
  }

  /// 4.3. Gán nhân vật vào vai truyện (User Story Character Mapping)
  /// POST /api/user-story-character-mappings
  static Future<UserStoryCharacterMapping?> assignCharacterToRole({
    required String generatedStoryId,
    required String storyRoleTemplateId,
    required String characterId,
    String? token,
  }) async {
    final url = Uri.parse(AppConfig.userStoryCharacterMappingsUrl);
    final headers = _buildHeaders(token);
    final payload = jsonEncode({
      'generatedStoryId': _ensureGuid(generatedStoryId),
      'storyRoleTemplateId': _ensureGuid(storyRoleTemplateId),
      'characterId': _ensureGuid(characterId),
    });

    try {
      if (kDebugMode) {
        debugPrint('[CharacterMappingService] POST $url payload: $payload');
      }

      final response = await _client
          .post(url, headers: headers, body: payload)
          .timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint('[CharacterMappingService] Response status: ${response.statusCode}');
        debugPrint('[CharacterMappingService] Response body: ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final data = decoded['data'] is Map<String, dynamic>
              ? decoded['data'] as Map<String, dynamic>
              : decoded;
          return UserStoryCharacterMapping.fromJson(data);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CharacterMappingService] Error assignCharacterToRole: $e');
      }
    }

    return null;
  }

  /// GET /api/user-story-character-mappings/generate-story/{generateStoryId}
  static Future<List<UserStoryCharacterMapping>> fetchMappingsByStory(
    String generateStoryId, {
    String? token,
  }) async {
    final url = Uri.parse(AppConfig.userStoryCharacterMappingsByStoryUrl(generateStoryId));
    final headers = _buildHeaders(token);

    try {
      if (kDebugMode) debugPrint('[CharacterMappingService] GET $url');
      final response = await _client.get(url, headers: headers).timeout(
            const Duration(seconds: 12),
          );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .map((item) => UserStoryCharacterMapping.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (decoded is Map<String, dynamic> && decoded['data'] is List) {
          return (decoded['data'] as List)
              .map((item) => UserStoryCharacterMapping.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CharacterMappingService] Error fetchMappingsByStory: $e');
      }
    }
    return [];
  }

  /// GET /api/user-story-character-mappings/character/{charId}
  static Future<List<UserStoryCharacterMapping>> fetchMappingsByCharacter(
    String characterId, {
    String? token,
  }) async {
    final url = Uri.parse(AppConfig.userStoryCharacterMappingsByCharUrl(_ensureGuid(characterId)));
    final headers = _buildHeaders(token);

    try {
      if (kDebugMode) debugPrint('[CharacterMappingService] GET $url');
      final response = await _client.get(url, headers: headers).timeout(
            const Duration(seconds: 12),
          );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .map((item) => UserStoryCharacterMapping.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (decoded is Map<String, dynamic> && decoded['data'] is List) {
          return (decoded['data'] as List)
              .map((item) => UserStoryCharacterMapping.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CharacterMappingService] Error fetchMappingsByCharacter: $e');
      }
    }
    return [];
  }
}
