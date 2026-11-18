import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/app_config.dart';
import 'api_client.dart';

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
  static final http.Client _client = ApiClient.instance;

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
      final effectiveToken = token ?? ApiClient.instance.currentToken;
      if (effectiveToken != null && effectiveToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $effectiveToken';
      }

      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
      );
      request.files.add(multipartFile);

      final streamedResponse = await _client.send(request).timeout(const Duration(seconds: 25));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 401) {
        if (kDebugMode) {
          debugPrint('[UploadService] 401 Unauthorized. Dang lam moi token va retry upload...');
        }
        final newToken = await ApiClient.instance.refreshToken();
        if (newToken != null && newToken.isNotEmpty) {
          final retryRequest = http.MultipartRequest('POST', url);
          retryRequest.headers['Accept'] = 'application/json';
          retryRequest.headers['Authorization'] = 'Bearer $newToken';
          retryRequest.files.add(
            http.MultipartFile.fromBytes(
              'file',
              bytes,
              filename: fileName,
            ),
          );
          final retryStreamed = await _client.send(retryRequest).timeout(const Duration(seconds: 25));
          response = await http.Response.fromStream(retryStreamed);
        }
      }

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
