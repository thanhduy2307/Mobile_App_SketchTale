import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../utils/app_config.dart';
import 'api_client.dart';

/// Service implementing Swagger StoryQuizTemplate endpoints for mobile:
/// 1. GET /api/story-template/{storyId}/quizzes (List quizzes for child to play)
/// 2. GET /api/story-quiz/{id} (Fetch single quiz detail)
/// (Parent-only endpoints on Web: POST, PUT, DELETE)
class QuizService {
  static http.Client _client = ApiClient.instance;

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

  /// POST /api/child-quiz-answers
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
    final effectiveReadingLogId = AppConfig.isValidUuid(readingLogId)
        ? readingLogId
        : '00000000-0000-0000-0000-000000000000';
    final effectiveQuizId = AppConfig.isValidUuid(storyQuizTemplateId)
        ? storyQuizTemplateId
        : '00000000-0000-0000-0000-000000000000';

    final body = <String, dynamic>{
      'readingLogId': effectiveReadingLogId,
      'storyQuizTemplateId': effectiveQuizId,
      'selectedOptionIndex': selectedOptionIndex,
      'responseTimeSeconds': responseTimeSeconds < 0 ? 0 : responseTimeSeconds,
    };
    if (AppConfig.isValidUuid(childProfileId)) {
      body['childProfileId'] = childProfileId;
    }

    final url = Uri.parse(AppConfig.childQuizAnswersUrl);
    try {
      if (kDebugMode) {
        debugPrint('[QuizService] POST $url body: ${jsonEncode(body)}');
      }
      final response = await _client
          .post(
            url,
            headers: _jsonHeaders(token, withBody: true),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint(
          '[QuizService] Submit answer response: ${response.statusCode} - ${response.body}',
        );
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

    List<StoryQuizTemplate> parseQuizzes(dynamic body) {
      try {
        final decoded = jsonDecode(body.toString());
        final list = (decoded is Map<String, dynamic> && decoded['data'] is List)
            ? decoded['data'] as List
            : (decoded is List ? decoded : null);
        if (list != null && list.isNotEmpty) {
          return list
              .whereType<Map>()
              .map((item) => StoryQuizTemplate.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      } catch (_) {}
      return const [];
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
        final quizzes = parseQuizzes(response.body);
        if (quizzes.isNotEmpty) return quizzes;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[QuizService] Error fetching quizzes for $storyId: $e');
      }
    }

    // Fallback: GET /api/story-template/{storyId}/all-quizzes
    final allQuizzesUrl = Uri.parse(AppConfig.storyAllQuizzesUrl(storyId));
    try {
      if (kDebugMode) {
        debugPrint('[QuizService] GET $allQuizzesUrl (Fallback)');
      }
      final response = await _client.get(allQuizzesUrl, headers: headers).timeout(
            const Duration(seconds: 10),
          );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final quizzes = parseQuizzes(response.body);
        if (quizzes.isNotEmpty) return quizzes;
      }
    } catch (_) {}

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
