import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../utils/app_config.dart';

/// Service implementing Swagger StoryQuizTemplate endpoints for mobile:
/// 1. GET /api/story-template/{storyId}/quizzes (List quizzes for child to play)
/// 2. GET /api/story-quiz/{id} (Fetch single quiz detail)
/// (Parent-only endpoints on Web: POST, PUT, DELETE)
class QuizService {
  static http.Client _client = http.Client();

  /// Lets tests inject a mock HTTP client.
  @visibleForTesting
  static set httpClient(http.Client client) => _client = client;

  static Map<String, String> _jsonHeaders(String? token, {bool withBody = false}) {
    final headers = <String, String>{'Accept': 'application/json'};
    if (withBody) headers['Content-Type'] = 'application/json';
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// POST /api/reading-logs/child-quiz-answers
  /// Child submits one answer; the backend grades it and returns progress + stars.
  /// Returns `null` when the answer could not be recorded.
  static Future<SubmitQuizAnswerResult?> submitAnswer({
    required String readingLogId,
    required String storyQuizTemplateId,
    required int selectedOptionIndex,
    int responseTimeSeconds = 0,
    String? childProfileId,
    String? token,
  }) async {
    if (!AppConfig.isValidUuid(readingLogId) ||
        !AppConfig.isValidUuid(storyQuizTemplateId)) {
      return null;
    }

    final body = <String, dynamic>{
      'readingLogId': readingLogId,
      'storyQuizTemplateId': storyQuizTemplateId,
      'selectedOptionIndex': selectedOptionIndex,
      'responseTimeSeconds': responseTimeSeconds < 0 ? 0 : responseTimeSeconds,
    };
    if (AppConfig.isValidUuid(childProfileId)) {
      body['childProfileId'] = childProfileId;
    }

    final url = Uri.parse(AppConfig.readingLogSubmitAnswerUrl);
    try {
      if (kDebugMode) debugPrint('[QuizService] POST $url');
      final response = await _client
          .post(
            url,
            headers: _jsonHeaders(token, withBody: true),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint('[QuizService] Submit answer response: ${response.statusCode}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return SubmitQuizAnswerResult.fromJson(decoded);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[QuizService] Error submitting answer: $e');
    }
    return null;
  }

  /// GET /api/reading-logs/{readingLogId}/quiz-answers
  static Future<ReadingLogQuizSummary?> fetchReadingLogSummary(
    String readingLogId, {
    String? token,
  }) async {
    if (!AppConfig.isValidUuid(readingLogId)) return null;
    final url = Uri.parse(AppConfig.readingLogQuizAnswersUrl(readingLogId));
    try {
      final response = await _client
          .get(url, headers: _jsonHeaders(token))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return ReadingLogQuizSummary.fromJson(decoded);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[QuizService] Error fetching reading log summary: $e');
    }
    return null;
  }

  /// GET /api/reading-logs/child-profiles/{childProfileId}/quiz-answers
  /// Whole quiz history of a child (one summary per reading session).
  static Future<List<ReadingLogQuizSummary>> fetchChildQuizHistory(
    String childProfileId, {
    String? token,
  }) async {
    if (!AppConfig.isValidUuid(childProfileId)) return const [];
    final url = Uri.parse(AppConfig.childQuizHistoryUrl(childProfileId));
    try {
      final response = await _client
          .get(url, headers: _jsonHeaders(token))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .whereType<Map>()
              .map((e) => ReadingLogQuizSummary.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[QuizService] Error fetching child quiz history: $e');
    }
    return const [];
  }

  /// 1. GET /api/story-template/{storyId}/quizzes
  /// Fetches all quiz questions for a given story template (Read-only for child play)
  static Future<List<StoryQuizTemplate>> fetchStoryQuizzes(
    String storyId, {
    String? token,
    String? storyTitle,
  }) async {
    if (!AppConfig.isValidUuid(storyId)) {
      return const [];
    }

    final url = Uri.parse(AppConfig.storyQuizzesUrl(storyId));
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      if (kDebugMode) {
        debugPrint('[QuizService] GET $url');
      }

      final response = await _client.get(url, headers: headers).timeout(
            const Duration(seconds: 15),
          );

      if (kDebugMode) {
        debugPrint('[QuizService] Story $storyId quizzes response: ${response.statusCode}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          final list = decoded
              .map((item) => StoryQuizTemplate.fromJson(item as Map<String, dynamic>))
              .toList();
          return list;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[QuizService] Error fetching quizzes for $storyId: $e');
      }
    }

    return const [];
  }

  /// 2. GET /api/story-quiz/{id}
  /// Fetches a specific quiz item by its ID
  static Future<StoryQuizTemplate?> fetchQuizById(
    String id, {
    String? token,
  }) async {
    if (!AppConfig.isValidUuid(id)) return null;

    final url = Uri.parse(AppConfig.storyQuizUrl(id));
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      var response = await _client.get(url, headers: headers).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 404) {
        final altUrl = Uri.parse(AppConfig.storyQuizAltUrl(id));
        response = await _client.get(altUrl, headers: headers).timeout(
              const Duration(seconds: 15),
            );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return StoryQuizTemplate.fromJson(decoded);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[QuizService] Error fetching quiz $id: $e');
      }
    }
    return null;
  }
}
