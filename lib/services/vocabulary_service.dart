import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../utils/app_config.dart';

/// Service implementing Swagger VocabularyTemplate endpoints:
/// 1. GET  /api/story-pages/{pageId}/vocabularies
/// 2. POST /api/story-pages/{pageId}/vocabularies
/// 3. GET  /api/story-vocabulary/{id}
/// 4. PUT  /api/story-vocabulary/{id}
/// 5. DELETE /api/story-vocabulary/{id}
class VocabularyService {
  static final http.Client _client = http.Client();

  /// 1. GET /api/story-pages/{pageId}/vocabularies
  /// Fetches all vocabulary items for a given story page
  static Future<List<VocabularyTemplate>> fetchPageVocabularies(
    String pageId, {
    String? token,
    int? pageNumber,
    String? storyTitle,
  }) async {
    if (!AppConfig.isValidUuid(pageId)) {
      return const [];
    }

    final url = Uri.parse(AppConfig.storyPageVocabulariesUrl(pageId));
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      if (kDebugMode) {
        debugPrint('[VocabularyService] GET $url');
      }

      final response = await _client.get(url, headers: headers).timeout(
            const Duration(seconds: 15),
          );

      if (kDebugMode) {
        debugPrint('[VocabularyService] Page $pageId vocabularies response: ${response.statusCode}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty) {
          final list = decoded
              .map((item) => VocabularyTemplate.fromJson(item as Map<String, dynamic>))
              .toList();
          return list;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[VocabularyService] Error fetching vocabularies for $pageId: $e');
      }
    }

    // Fallback nếu CM chưa cấu hình từ vựng trên server cho trang này
    if (storyTitle != null && storyTitle.isNotEmpty) {
      return getDefaultVocabulariesForPage(
        pageNumber ?? 1,
        storyTitle,
        pageId: pageId,
      );
    }

    return const [];
  }

  /// Danh sách từ vựng thông minh theo ngữ cảnh câu chuyện khi CM chưa tạo từ vựng
  static List<VocabularyTemplate> getDefaultVocabulariesForPage(
    int pageNumber,
    String storyTitle, {
    String? textContent,
    String? pageId,
  }) {
    final pid = pageId ?? 'default-page-$pageNumber';
    final lowerTitle = storyTitle.toLowerCase();
    final lowerText = (textContent ?? '').toLowerCase();

    final List<VocabularyTemplate> result = [];

    if (lowerTitle.contains('tôn giáo') || lowerText.contains('tôn giáo')) {
      result.add(VocabularyTemplate(
        id: 'vocab-$pid-religion',
        storyPageTemplateId: pid,
        word: 'Tôn giáo',
        meaning: 'Hệ thống niềm tin, đạo đức và những điều tốt đẹp giúp con người sống yêu thương, hướng thiện.',
      ));
    }
    if (lowerText.contains('nội dung')) {
      result.add(VocabularyTemplate(
        id: 'vocab-$pid-content',
        storyPageTemplateId: pid,
        word: 'Nội dung',
        meaning: 'Những thông điệp, ý nghĩa và câu chuyện thú vị được gửi gắm trong trang sách.',
      ));
    }
    if (lowerText.contains('mới') && !result.any((v) => v.word == 'Nội dung')) {
      result.add(VocabularyTemplate(
        id: 'vocab-$pid-new',
        storyPageTemplateId: pid,
        word: 'Mới',
        meaning: 'Những điều vừa xuất hiện, tươi vui và mang lại nhiều điều kỳ diệu cho bé.',
      ));
    }
    if (lowerTitle.contains('đom đóm') || lowerText.contains('đom đóm')) {
      result.add(VocabularyTemplate(
        id: 'vocab-$pid-firefly',
        storyPageTemplateId: pid,
        word: 'Đom Đóm',
        meaning: 'Loài bọ cánh cứng nhỏ bé có thể tự phát sáng lấp lánh trong đêm tối.',
      ));
    }
    if (lowerTitle.contains('cứu hỏa') || lowerText.contains('cứu hỏa')) {
      result.add(VocabularyTemplate(
        id: 'vocab-$pid-firefighter',
        storyPageTemplateId: pid,
        word: 'Cứu Hỏa',
        meaning: 'Hành động dũng cảm dập tắt đám cháy và bảo vệ an toàn cho mọi người.',
      ));
    }
    if (lowerTitle.contains('chia sẻ') || lowerText.contains('chia sẻ') || lowerTitle.contains('picnic')) {
      result.add(VocabularyTemplate(
        id: 'vocab-$pid-share',
        storyPageTemplateId: pid,
        word: 'Chia sẻ',
        meaning: 'Cùng nhau san sẻ đồ ăn, đồ chơi và niềm vui với bạn bè xung quanh.',
      ));
    }
    if (lowerTitle.contains('chìa khóa') || lowerText.contains('chìa khóa') || (pageNumber == 3 && lowerTitle.contains('đom đóm'))) {
      result.add(VocabularyTemplate(
        id: 'vocab-$pid-key',
        storyPageTemplateId: pid,
        word: 'Chìa Khóa',
        meaning: 'Vật dụng dùng để mở ra những cánh cửa hoặc khám phá những điều bí ẩn.',
      ));
    }

    return result;
  }

  /// 2. GET /api/story-vocabulary/{id}
  /// Fetches a specific vocabulary item by its ID (Read-only for child learning)
  static Future<VocabularyTemplate?> fetchVocabularyById(
    String id, {
    String? token,
  }) async {
    if (!AppConfig.isValidUuid(id)) {
      return null;
    }
    final url = Uri.parse(AppConfig.storyVocabularyUrl(id));
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
          return VocabularyTemplate.fromJson(decoded);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[VocabularyService] Error fetching vocabulary $id: $e');
      }
    }
    return null;
  }
}
