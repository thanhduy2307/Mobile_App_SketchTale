import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/reading_log_quiz.dart';
import '../utils/app_config.dart';
import 'api_client.dart';

/// Service managing Reading Log sessions and completed stories on Backend:
/// 1. POST /api/reading-logs: Start reading session
/// 2. PUT /api/reading-logs/{id}/progress: Update current page & duration
/// 3. PUT /api/reading-logs/{id}/complete: Mark story as completed
/// 4. GET /api/reading-logs/child-profiles/{childProfileId}/completed: Get completed stories
class ReadingLogService {
  static http.Client _client = ApiClient.instance;

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
  /// POST /api/reading-logs
  static Future<ReadingLogSession?> startReadingSession({
    required String generatedStoryId,
    String? token,
  }) async {
    if (!AppConfig.isValidUuid(generatedStoryId)) {
      if (kDebugMode) {
        debugPrint('[ReadingLogService] generatedStoryId khong phai UUID hop le: $generatedStoryId');
      }
      return null;
    }

    final url = Uri.parse(AppConfig.readingLogsUrl);
    final body = jsonEncode({'generatedStoryId': generatedStoryId});

    try {
      if (kDebugMode) debugPrint('[ReadingLogService] POST $url body: $body');
      final response = await _client
          .post(url, headers: _jsonHeaders(token, withBody: true), body: body)
          .timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint('[ReadingLogService] Start session response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.trim().isEmpty) return null;
        final decoded = jsonDecode(response.body);
        final data = (decoded is Map<String, dynamic> && decoded.containsKey('data'))
            ? decoded['data']
            : decoded;
        if (data is Map<String, dynamic>) {
          return ReadingLogSession.fromJson(data);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ReadingLogService] Error starting session: $e');
    }
    return null;
  }

  /// Update current reading progress.
  /// PUT /api/reading-logs/{id}/progress
  static Future<ReadingLogSession?> updateProgress({
    required String readingLogId,
    required int currentPage,
    required int readDurationSeconds,
    String? token,
  }) async {
    if (!AppConfig.isValidUuid(readingLogId)) {
      if (kDebugMode) {
        debugPrint('[ReadingLogService] readingLogId khong phai UUID hop le: $readingLogId');
      }
      return null;
    }

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
        debugPrint('[ReadingLogService] Update progress response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.trim().isEmpty) return null;
        final decoded = jsonDecode(response.body);
        final data = (decoded is Map<String, dynamic> && decoded.containsKey('data'))
            ? decoded['data']
            : decoded;
        if (data is Map<String, dynamic>) {
          return ReadingLogSession.fromJson(data);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ReadingLogService] Error updating progress: $e');
    }
    return null;
  }

  /// Mark a reading session as completed.
  /// PUT /api/reading-logs/{id}/complete
  static Future<ReadingLogSession?> completeReadingSession({
    required String readingLogId,
    String? token,
  }) async {
    if (!AppConfig.isValidUuid(readingLogId)) {
      if (kDebugMode) {
        debugPrint('[ReadingLogService] readingLogId khong phai UUID hop le: $readingLogId');
      }
      return null;
    }

    final url = Uri.parse(AppConfig.readingLogCompleteUrl(readingLogId));

    try {
      if (kDebugMode) debugPrint('[ReadingLogService] PUT $url');
      final response = await _client
          .put(url, headers: _jsonHeaders(token))
          .timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint('[ReadingLogService] Complete session response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.trim().isEmpty) {
          return const ReadingLogSession(isCompleted: true);
        }
        try {
          final decoded = jsonDecode(response.body);
          final data = (decoded is Map<String, dynamic> && decoded.containsKey('data'))
              ? decoded['data']
              : decoded;
          if (data is Map<String, dynamic>) {
            return ReadingLogSession.fromJson(data);
          }
        } catch (_) {}
        return const ReadingLogSession(isCompleted: true);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ReadingLogService] Error completing session: $e');
    }
    return null;
  }

  /// Fetch list of completed stories for a child profile from Backend.
  /// GET /api/reading-logs/child-profiles/{childProfileId}/completed
  static Future<List<CompletedReadingLog>> fetchCompletedStories({
    required String childProfileId,
    String? token,
  }) async {
    if (!AppConfig.isValidUuid(childProfileId)) {
      if (kDebugMode) {
        debugPrint('[ReadingLogService] childProfileId khong phai UUID hop le: $childProfileId');
      }
      return const [];
    }

    final url = Uri.parse(AppConfig.childCompletedStoriesUrl(childProfileId));

    try {
      if (kDebugMode) debugPrint('[ReadingLogService] GET $url');
      final response = await _client
          .get(url, headers: _jsonHeaders(token))
          .timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint('[ReadingLogService] Completed stories response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.trim().isEmpty) return const [];
        final decoded = jsonDecode(response.body);
        final list = (decoded is Map<String, dynamic> && decoded['data'] is List)
            ? decoded['data'] as List
            : (decoded is List ? decoded : null);
        if (list != null) {
          return list
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

