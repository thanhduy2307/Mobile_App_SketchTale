import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../utils/app_config.dart';

/// Result from ContentReportService
class ContentReportResult {
  final bool isSuccess;
  final String? reportId;
  final String message;

  const ContentReportResult({
    required this.isSuccess,
    this.reportId,
    required this.message,
  });

  factory ContentReportResult.success({String? reportId, String? message}) =>
      ContentReportResult(
        isSuccess: true,
        reportId: reportId,
        message: message ??
            'Báo cáo của bạn đã được tiếp nhận và sẽ được đội ngũ kiểm duyệt xem xét ngay lập tức.',
      );

  factory ContentReportResult.failure(String message) =>
      ContentReportResult(isSuccess: false, message: message);
}

/// Service handling Child Safety & Content Reports (/api/content-reports)
class ContentReportService {
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

  /// 8.1. Gửi báo cáo nội dung không phù hợp (POST /api/content-reports)
  static Future<ContentReportResult> reportContent({
    required ReportTargetType targetType,
    required String targetId,
    required String reason,
    String? token,
  }) async {
    final url = Uri.parse(AppConfig.contentReportsUrl);
    final headers = _buildHeaders(token);
    final safeTargetId = _ensureGuid(targetId);
    final payload = jsonEncode({
      'targetType': targetType.index,
      'targetId': safeTargetId,
      'reason': reason,
      'status': ContentReportStatus.pending.index,
    });

    try {
      if (kDebugMode) {
        debugPrint('[ContentReportService] POST $url payload: $payload');
      }

      final response = await _client
          .post(url, headers: headers, body: payload)
          .timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint('[ContentReportService] Status: ${response.statusCode}');
        debugPrint('[ContentReportService] Body: ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        String? reportId;
        String message =
            'Báo cáo của bạn đã được tiếp nhận và sẽ được đội ngũ kiểm duyệt xem xét ngay lập tức.';

        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            reportId = decoded['id']?.toString() ?? decoded['data']?['id']?.toString();
            if (decoded['message'] != null) message = decoded['message'].toString();
          }
        } catch (_) {}

        return ContentReportResult.success(reportId: reportId, message: message);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ContentReportService] Error reportContent: $e');
      }
      return ContentReportResult.failure('Lỗi gửi báo cáo: $e');
    }

    return ContentReportResult.failure('Không thể gửi báo cáo vi phạm. Vui lòng thử lại sau.');
  }
}
