import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../utils/app_config.dart';

/// Service handling Character Types from /api/char-types (Used in AI classification)
class CharTypeService {
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

  /// GET /api/char-types
  static Future<List<CharType>> fetchCharTypes({String? token}) async {
    final url = Uri.parse(AppConfig.charTypesUrl);
    final headers = _buildHeaders(token);

    try {
      if (kDebugMode) debugPrint('[CharTypeService] GET $url');
      final response = await _client.get(url, headers: headers).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          final list = decoded
              .map((item) => CharType.fromJson(item as Map<String, dynamic>))
              .where((c) => c.status == CommonStatus.active)
              .toList();
          return list;
        } else if (decoded is Map<String, dynamic> && decoded['data'] is List) {
          final list = (decoded['data'] as List)
              .map((item) => CharType.fromJson(item as Map<String, dynamic>))
              .where((c) => c.status == CommonStatus.active)
              .toList();
          return list;
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[CharTypeService] Error fetchCharTypes: $e');
    }

    return const <CharType>[];
  }
}
