import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../utils/app_config.dart';

/// Result wrapper for Character operations
class CharacterActionResult {
  final bool isSuccess;
  final String message;
  final dynamic data;

  const CharacterActionResult({
    required this.isSuccess,
    required this.message,
    this.data,
  });

  factory CharacterActionResult.success(String message, [dynamic data]) =>
      CharacterActionResult(isSuccess: true, message: message, data: data);

  factory CharacterActionResult.failure(String message) =>
      CharacterActionResult(isSuccess: false, message: message);
}

/// Service implementing Character Approval & Preview Lifecycle:
/// 1. POST /api/characters/{id}/accept?childProfileId={childProfileId} (Preview -> Pending)
/// 2. POST /api/characters/{id}/cancel-preview?childProfileId={childProfileId} (Preview -> Cancelled + refund attempt)
/// 3. GET /api/characters/pending-approval (Parent: List characters awaiting approval)
/// 4. PUT /api/characters/{id}/approve (Parent: Pending -> Approved)
/// 5. PUT /api/characters/{id}/reject (Parent: Pending -> Rejected)
class CharacterService {
  static final http.Client _client = http.Client();

  /// Gửi nhân vật xem trước (Preview) lên cho Phụ huynh phê duyệt (Pending)
  static Future<CharacterActionResult> acceptCharacterPreview({
    required String characterId,
    String? childProfileId,
    String? token,
  }) async {
    String? effectiveChildId = childProfileId;
    if ((effectiveChildId == null || !AppConfig.isValidUuid(effectiveChildId)) && token != null) {
      effectiveChildId = AppConfig.extractUserIdFromJwt(token);
    }

    final url = Uri.parse(
      AppConfig.characterAcceptPreviewUrl(
        characterId,
        childProfileId: effectiveChildId,
      ),
    );

    try {
      if (kDebugMode) {
        debugPrint('[CharacterService] POST $url (childProfileId: $childProfileId)');
      }

      final headers = <String, String>{
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _client.post(url, headers: headers).timeout(
            const Duration(seconds: 20),
          );

      if (kDebugMode) {
        debugPrint('[CharacterService] Accept status: ${response.statusCode}');
        debugPrint('[CharacterService] Accept body: ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        String msg = 'Nhân vật đã được gửi đến phụ huynh chờ phê duyệt!';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded['message'] != null) {
            msg = decoded['message'].toString();
          }
        } catch (_) {}
        return CharacterActionResult.success(msg);
      }

      String errMsg = 'Lỗi máy chủ (${response.statusCode})';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          errMsg = decoded['message'].toString();
        }
      } catch (_) {}

      return CharacterActionResult.failure(errMsg);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CharacterService] Exception in acceptCharacterPreview: $e');
      }
      return CharacterActionResult.failure('Lỗi kết nối khi gửi phê duyệt: $e');
    }
  }

  /// Hủy xem trước và hoàn lại 1 lượt tạo nhân vật trong ngày cho bé
  static Future<CharacterActionResult> cancelCharacterPreview({
    required String characterId,
    String? childProfileId,
    String? token,
  }) async {
    String? effectiveChildId = childProfileId;
    if ((effectiveChildId == null || !AppConfig.isValidUuid(effectiveChildId)) && token != null) {
      effectiveChildId = AppConfig.extractUserIdFromJwt(token);
    }

    final url = Uri.parse(
      AppConfig.characterCancelPreviewUrl(
        characterId,
        childProfileId: effectiveChildId,
      ),
    );

    try {
      if (kDebugMode) {
        debugPrint('[CharacterService] POST $url (childProfileId: $childProfileId)');
      }

      final headers = <String, String>{
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _client.post(url, headers: headers).timeout(
            const Duration(seconds: 20),
          );

      if (kDebugMode) {
        debugPrint('[CharacterService] Cancel status: ${response.statusCode}');
        debugPrint('[CharacterService] Cancel body: ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        String msg = 'Đã hủy xem trước và hoàn lại 1 lượt tạo nhân vật.';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded['message'] != null) {
            msg = decoded['message'].toString();
          }
        } catch (_) {}
        return CharacterActionResult.success(msg);
      }

      String errMsg = 'Lỗi máy chủ (${response.statusCode})';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          errMsg = decoded['message'].toString();
        }
      } catch (_) {}

      return CharacterActionResult.failure(errMsg);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CharacterService] Exception in cancelCharacterPreview: $e');
      }
      return CharacterActionResult.failure('Lỗi kết nối khi hủy xem trước: $e');
    }
  }

  /// Phụ huynh duyệt nhân vật (PUT /api/characters/{id}/approve)
  static Future<CharacterActionResult> approveCharacter({
    required String characterId,
    String? token,
  }) async {
    final url = Uri.parse(AppConfig.characterApproveUrl(characterId));

    try {
      final headers = <String, String>{
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _client.put(url, headers: headers).timeout(
            const Duration(seconds: 20),
          );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return CharacterActionResult.success('Nhân vật đã được phê duyệt thành công!');
      }

      String errMsg = 'Không thể phê duyệt nhân vật (${response.statusCode})';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          errMsg = decoded['message'].toString();
        }
      } catch (_) {}

      return CharacterActionResult.failure(errMsg);
    } catch (e) {
      return CharacterActionResult.failure('Lỗi kết nối khi duyệt nhân vật: $e');
    }
  }

  /// Phụ huynh từ chối nhân vật (PUT /api/characters/{id}/reject)
  static Future<CharacterActionResult> rejectCharacter({
    required String characterId,
    String? token,
  }) async {
    final url = Uri.parse(AppConfig.characterRejectUrl(characterId));

    try {
      final headers = <String, String>{
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _client.put(url, headers: headers).timeout(
            const Duration(seconds: 20),
          );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return CharacterActionResult.success('Đã từ chối nhân vật thành công!');
      }

      String errMsg = 'Không thể từ chối nhân vật (${response.statusCode})';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          errMsg = decoded['message'].toString();
        }
      } catch (_) {}

      return CharacterActionResult.failure(errMsg);
    } catch (e) {
      return CharacterActionResult.failure('Lỗi kết nối khi từ chối nhân vật: $e');
    }
  }

  /// 6. Lấy toàn bộ danh sách nhân vật của bé theo ChildId
  /// GET /api/characters/child-profiles/{childId}
  static Future<List<KidCharacter>> fetchCharactersByChildId({
    required String childId,
    String? token,
  }) async {
    if (!AppConfig.isValidUuid(childId)) return [];

    final url = Uri.parse(AppConfig.childCharactersUrl(childId));
    try {
      final headers = <String, String>{
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _client.get(url, headers: headers).timeout(
            const Duration(seconds: 15),
          );

      if (kDebugMode) {
        debugPrint('[CharacterService] GET $url -> ${response.statusCode}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .whereType<Map<String, dynamic>>()
              .map((j) => KidCharacter.fromJson(j))
              .toList();
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CharacterService] Exception fetchCharactersByChildId: $e');
      }
      return [];
    }
  }

  /// 7. Cập nhật tên nhân vật theo CharacterId
  /// PUT /api/characters/{characterId}/name
  static Future<CharacterActionResult> updateCharacterName({
    required String characterId,
    required String newName,
    String? token,
  }) async {
    if (!AppConfig.isValidUuid(characterId)) {
      return CharacterActionResult.failure('ID nhân vật không hợp lệ.');
    }

    final trimmedName = newName.trim();
    if (trimmedName.isEmpty) {
      return CharacterActionResult.failure('Tên nhân vật không được để trống.');
    }

    final url = Uri.parse(AppConfig.updateCharacterNameUrl(characterId));
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final body = jsonEncode({'name': trimmedName});

      final response = await _client.put(url, headers: headers, body: body).timeout(
            const Duration(seconds: 15),
          );

      if (kDebugMode) {
        debugPrint('[CharacterService] PUT $url -> ${response.statusCode}');
        debugPrint('[CharacterService] Response body: ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        String msg = 'Cập nhật tên nhân vật thành công!';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded['message'] != null) {
            msg = decoded['message'].toString();
          }
        } catch (_) {}
        return CharacterActionResult.success(msg);
      }

      String errMsg = 'Lỗi cập nhật tên nhân vật (${response.statusCode})';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          errMsg = decoded['message'].toString();
        }
      } catch (_) {}
      return CharacterActionResult.failure(errMsg);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CharacterService] Exception updateCharacterName: $e');
      }
      return CharacterActionResult.failure('Lỗi kết nối khi cập nhật tên: $e');
    }
  }

  /// 8. Lấy danh sách nhân vật chờ duyệt dành cho Phụ huynh
  /// GET /api/characters/pending-approval
  static Future<List<KidCharacter>> fetchPendingCharactersForParent({
    String? token,
  }) async {
    final url = Uri.parse(AppConfig.charactersPendingApprovalUrl);
    try {
      final headers = <String, String>{
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _client.get(url, headers: headers).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .whereType<Map<String, dynamic>>()
              .map((j) => KidCharacter.fromJson(j))
              .toList();
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CharacterService] Exception fetchPendingCharactersForParent: $e');
      }
      return [];
    }
  }
}

