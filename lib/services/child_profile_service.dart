import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/child_profile.dart';
import '../utils/app_config.dart';

class ChildProfileService {
  static final http.Client _client = http.Client();

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

  /// 1. GET /api/child-profiles
  /// Lấy danh sách hồ sơ của bé (dành cho phụ huynh hoặc trẻ)
  static Future<List<ChildProfile>> fetchChildProfiles({String? token}) async {
    final url = Uri.parse(AppConfig.childProfilesUrl);
    final headers = _buildHeaders(token);

    try {
      if (kDebugMode) debugPrint('[ChildProfileService] GET $url');
      final response = await _client.get(url, headers: headers).timeout(
            const Duration(seconds: 15),
          );

      if (kDebugMode) {
        debugPrint('[ChildProfileService] GET $url status: ${response.statusCode}');
        debugPrint('[ChildProfileService] Body: ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .map((item) => ChildProfile.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (decoded is Map<String, dynamic>) {
          if (decoded['data'] is List) {
            return (decoded['data'] as List)
                .map((item) => ChildProfile.fromJson(item as Map<String, dynamic>))
                .toList();
          } else {
            return [ChildProfile.fromJson(decoded)];
          }
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ChildProfileService] Error fetchChildProfiles: $e');
    }
    return [];
  }

  /// 2. GET /api/child-profiles/{id}
  /// Lấy chi tiết một hồ sơ trẻ em theo ID
  static Future<ChildProfile?> fetchChildProfile(String id, {String? token}) async {
    final url = Uri.parse(AppConfig.childProfileUrl(id));
    final headers = _buildHeaders(token);

    try {
      if (kDebugMode) debugPrint('[ChildProfileService] GET $url');
      final response = await _client.get(url, headers: headers).timeout(
            const Duration(seconds: 15),
          );

      if (kDebugMode) {
        debugPrint('[ChildProfileService] GET $url status: ${response.statusCode}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final data = decoded['data'] is Map<String, dynamic>
              ? decoded['data'] as Map<String, dynamic>
              : decoded;
          return ChildProfile.fromJson(data);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ChildProfileService] Error fetchChildProfile: $e');
    }
    return null;
  }

  /// 3. PUT /api/child-profiles/{id}
  /// Cập nhật thông tin hồ sơ của bé (UpdateChildProfileDto)
  static Future<bool> updateChildProfile(
    String id,
    Map<String, dynamic> updateDto, {
    String? token,
  }) async {
    final url = Uri.parse(AppConfig.childProfileUrl(id));
    final headers = _buildHeaders(token);
    final body = jsonEncode(updateDto);

    try {
      if (kDebugMode) debugPrint('[ChildProfileService] PUT $url payload: $body');
      final response = await _client.put(url, headers: headers, body: body).timeout(
            const Duration(seconds: 15),
          );

      if (kDebugMode) {
        debugPrint('[ChildProfileService] PUT $url status: ${response.statusCode}');
        debugPrint('[ChildProfileService] Response: ${response.body}');
      }

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (kDebugMode) debugPrint('[ChildProfileService] Error updateChildProfile: $e');
      return false;
    }
  }

  /// 4. GET /api/child-profiles/{id}/nickname
  /// Lấy biệt danh của bé
  static Future<String?> fetchNickname(String id, {String? token}) async {
    final url = Uri.parse(AppConfig.childProfileNicknameUrl(id));
    final headers = _buildHeaders(token);

    try {
      final response = await _client.get(url, headers: headers).timeout(
            const Duration(seconds: 10),
          );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = response.body.trim();
        if (body.startsWith('"') && body.endsWith('"') && body.length >= 2) {
          return body.substring(1, body.length - 1);
        }
        try {
          final decoded = jsonDecode(body);
          if (decoded is String) return decoded;
          if (decoded is Map<String, dynamic>) {
            return decoded['nickName']?.toString() ?? decoded['nickname']?.toString();
          }
        } catch (_) {
          return body;
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ChildProfileService] Error fetchNickname: $e');
    }
    return null;
  }

  /// 5. GET /api/child-profiles/{id}/target-age-group
  /// Lấy nhóm tuổi mục tiêu của bé
  static Future<String?> fetchTargetAgeGroup(String id, {String? token}) async {
    final url = Uri.parse(AppConfig.childProfileTargetAgeGroupUrl(id));
    final headers = _buildHeaders(token);

    try {
      final response = await _client.get(url, headers: headers).timeout(
            const Duration(seconds: 10),
          );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = response.body.trim();
        try {
          final decoded = jsonDecode(body);
          return decoded?.toString();
        } catch (_) {
          return body;
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ChildProfileService] Error fetchTargetAgeGroup: $e');
    }
    return null;
  }

  /// 6. GET /api/child-profiles/{id}/daily-time-limit
  /// Lấy thời lượng sử dụng cho phép mỗi ngày (phút)
  static Future<int?> fetchDailyTimeLimit(String id, {String? token}) async {
    final url = Uri.parse(AppConfig.childProfileDailyTimeLimitUrl(id));
    final headers = _buildHeaders(token);

    try {
      final response = await _client.get(url, headers: headers).timeout(
            const Duration(seconds: 10),
          );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = response.body.trim();
        return int.tryParse(body) ?? (jsonDecode(body) as num?)?.toInt();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ChildProfileService] Error fetchDailyTimeLimit: $e');
    }
    return null;
  }

  /// 7. GET /api/child-profiles/{id}/daily-character-limit
  /// Lấy giới hạn tạo nhân vật mỗi ngày
  static Future<int?> fetchDailyCharacterLimit(String id, {String? token}) async {
    final url = Uri.parse(AppConfig.childProfileDailyCharacterLimitUrl(id));
    final headers = _buildHeaders(token);

    try {
      final response = await _client.get(url, headers: headers).timeout(
            const Duration(seconds: 10),
          );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = response.body.trim();
        return int.tryParse(body) ?? (jsonDecode(body) as num?)?.toInt();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ChildProfileService] Error fetchDailyCharacterLimit: $e');
    }
    return null;
  }
}
