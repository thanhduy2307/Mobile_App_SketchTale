import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/app_config.dart';

/// Result from UploadService
class UploadResult {
  final bool isSuccess;
  final String? imageUrl;
  final String message;

  const UploadResult({
    required this.isSuccess,
    this.imageUrl,
    required this.message,
  });

  factory UploadResult.success(String url, {String message = 'Tải ảnh lên thành công.'}) =>
      UploadResult(isSuccess: true, imageUrl: url, message: message);

  factory UploadResult.failure(String message) =>
      UploadResult(isSuccess: false, message: message);
}

/// Service handling Media Uploads to Backend / Cloudinary (/api/upload/avatar)
class UploadService {
  static final http.Client _client = http.Client();

  /// 4.2. Tải lên ảnh vẽ hoặc avatar nhân vật của bé
  /// POST /api/upload/avatar (Multipart Form-Data)
  static Future<UploadResult> uploadAvatar({
    required Uint8List bytes,
    String fileName = 'character_drawing.png',
    String? token,
  }) async {
    final url = Uri.parse(AppConfig.uploadAvatarUrl);

    try {
      if (kDebugMode) {
        debugPrint('[UploadService] POST $url (bytes: ${bytes.length}, file: $fileName)');
      }

      final request = http.MultipartRequest('POST', url);
      request.headers['Accept'] = 'application/json';
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
      );
      request.files.add(multipartFile);

      final streamedResponse = await _client.send(request).timeout(const Duration(seconds: 25));
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        debugPrint('[UploadService] Upload response status: ${response.statusCode}');
        debugPrint('[UploadService] Upload response body: ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final imageUrl = decoded['imageUrl']?.toString() ??
              decoded['data']?['imageUrl']?.toString() ??
              decoded['url']?.toString();
          if (imageUrl != null && imageUrl.isNotEmpty) {
            final resolvedUrl = AppConfig.resolveImageUrl(imageUrl);
            return UploadResult.success(resolvedUrl);
          }
        }
      }

      // If backend returned an error message
      String errorMsg = 'Không thể tải ảnh lên máy chủ.';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['message'] != null) {
          errorMsg = decoded['message'].toString();
        }
      } catch (_) {}

      if (kDebugMode) {
        debugPrint('[UploadService] Upload failed ($errorMsg), using local resilience');
      }
      return UploadResult.failure(errorMsg);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[UploadService] Error uploadAvatar: $e');
      }
      return UploadResult.failure('Lỗi kết nối máy chủ: $e');
    }
  }
}
