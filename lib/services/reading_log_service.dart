import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/reading_log_quiz.dart';
import '../utils/app_config.dart';

/// Service managing Reading Log sessions and completed stories on Backend:
/// 1. POST /api/reading-logs: Start reading session
/// 2. PUT /api/reading-logs/{id}/progress: Update current page & duration
/// 3. PUT /api/reading-logs/{id}/complete: Mark story as completed
/// 4. GET /api/reading-logs/child-profiles/{childProfileId}/completed: Get completed stories
class ReadingLogService {
  static http.Client _client = http.Client();

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

  /// Start a reading session.
  /// Requires `generatedStoryId` (UUID).
  static Future<ReadingLogSession?> startReadingSession({
    required String generatedStoryId,
    String? token,
  }) async {
    if (!AppConfig.isValidUuid(generatedStoryId)) return null;

    final url = Uri.parse(AppConfig.readingLogsUrl);
    final body = jsonEncode({'generatedStoryId': generatedStoryId});

    try {
      if (kDebugMode) debugPrint('[ReadingLogService] POST $url body: $body');
      final response = await _client
          .post(url, headers: _jsonHeaders(token, withBody: true), body: body)
          .timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint('[ReadingLogService] Start session response: ${response.statusCode}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return ReadingLogSession.fromJson(decoded);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ReadingLogService] Error starting session: $e');
    }
    return null;
  }

  /// Update current reading progress.
  static Future<ReadingLogSession?> updateProgress({
    required String readingLogId,
    required int currentPage,
    required int readDurationSeconds,
    String? token,
  }) async {
    if (!AppConfig.isValidUuid(readingLogId)) return null;

    final url = Uri.parse(AppConfig.readingLogProgressUrl(readingLogId));
    final body = jsonEncode({
      'currentPage': currentPage,
      'readDurationSeconds': readDurationSeconds < 0 ? 0 : readDurationSeconds,
    });

    try {
      if (kDebugMode) debugPrint('[ReadingLogService] PUT $url body: $body');
      final response = await _client
          .put(url, headers: _jsonHeaders(token, withBody: true), body: body)
          .timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint('[ReadingLogService] Update progress response: ${response.statusCode}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return ReadingLogSession.fromJson(decoded);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ReadingLogService] Error updating progress: $e');
    }
    return null;
  }

  /// Mark a reading session as completed.
  static Future<ReadingLogSession?> completeReadingSession({
    required String readingLogId,
    String? token,
  }) async {
    if (!AppConfig.isValidUuid(readingLogId)) return null;

    final url = Uri.parse(AppConfig.readingLogCompleteUrl(readingLogId));

    try {
      if (kDebugMode) debugPrint('[ReadingLogService] PUT $url');
      final response = await _client
          .put(url, headers: _jsonHeaders(token))
          .timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint('[ReadingLogService] Complete session response: ${response.statusCode}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return ReadingLogSession.fromJson(decoded);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ReadingLogService] Error completing session: $e');
    }
    return null;
  }

  /// Fetch list of completed stories for a child profile from Backend.
  static Future<List<CompletedReadingLog>> fetchCompletedStories({
    required String childProfileId,
    String? token,
  }) async {
    if (!AppConfig.isValidUuid(childProfileId)) return const [];

    final url = Uri.parse(AppConfig.childCompletedStoriesUrl(childProfileId));

    try {
      if (kDebugMode) debugPrint('[ReadingLogService] GET $url');
      final response = await _client
          .get(url, headers: _jsonHeaders(token))
          .timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint('[ReadingLogService] Completed stories response: ${response.statusCode}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .whereType<Map>()
              .map((e) => CompletedReadingLog.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ReadingLogService] Error fetching completed stories: $e');
    }
    return const [];
  }
}

