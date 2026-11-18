import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/models.dart';
import '../utils/app_config.dart';
import 'api_client.dart';

/// Result wrapper for Drawing AI operations
class DrawingAiResult<T> {
  final bool isSuccess;
  final T? data;
  final String? errorMessage;

  const DrawingAiResult({
    required this.isSuccess,
    this.data,
    this.errorMessage,
  });

  factory DrawingAiResult.success(T data) => DrawingAiResult(
        isSuccess: true,
        data: data,
      );

  factory DrawingAiResult.failure(String message) => DrawingAiResult(
        isSuccess: false,
        data: null,
        errorMessage: message,
      );
}

/// Service implementing 2-Stage AI Character Creation Workflow:
/// Stage 1: Analyze & Recognize Drawing (POST /api/drawings/analyze)
/// Stage 2: Generate 3D Character (POST /api/drawings/generate-character)
/// Credit Logs: GET /api/credit-transaction-logs
class DrawingAiService {
  static final http.Client _client = ApiClient.instance;

  // ==========================================
  // GIAI ĐOẠN 1: QUÉT & NHẬN DIỆN TRANH VẼ
  // POST /api/drawings/analyze (multipart/form-data)
  // ==========================================
  static Future<DrawingAiResult<AnalyzeDrawingResponse>> analyzeDrawing({
    required Uint8List bytes,
    int drawingType = 0, // 0: Canvas, 1: Uploaded
    String? childProfileId,
    String? token,
    String fileName = 'drawing.png',
  }) async {
    final url = Uri.parse(AppConfig.drawingsAnalyzeUrl);

    try {
      if (kDebugMode) {
        debugPrint('[DrawingAiService] POST $url (DrawingType: $drawingType, bytes: ${bytes.length})');
      }

      final request = http.MultipartRequest('POST', url);
      request.headers['Accept'] = 'application/json';
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['DrawingType'] = drawingType.toString();

      // Resolve valid UUID ChildProfileId from input or JWT token payload
      String? resolvedChildProfileId = childProfileId;
      if (!AppConfig.isValidUuid(resolvedChildProfileId) && token != null) {
        resolvedChildProfileId = AppConfig.extractUserIdFromJwt(token);
      }
      if (resolvedChildProfileId != null && AppConfig.isValidUuid(resolvedChildProfileId)) {
        request.fields['ChildProfileId'] = resolvedChildProfileId;
      }

      final multipartFile = http.MultipartFile.fromBytes(
        'File',
        bytes,
        filename: fileName,
        contentType: MediaType('image', 'png'),
      );
      request.files.add(multipartFile);

      if (kDebugMode) {
        debugPrint('[DrawingAiService] Attached canvas image: "${multipartFile.filename}" (${bytes.length} bytes, ${multipartFile.contentType})');
      }

      final streamedResponse = await _client.send(request).timeout(const Duration(seconds: 45));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 401) {
        if (kDebugMode) {
          debugPrint('[DrawingAiService] 401 Unauthorized. Dang lam moi token va retry analyze...');
        }
        final newToken = await ApiClient.instance.refreshToken();
        if (newToken != null && newToken.isNotEmpty) {
          final retryRequest = http.MultipartRequest('POST', url);
          retryRequest.headers['Accept'] = 'application/json';
          retryRequest.headers['Authorization'] = 'Bearer $newToken';
          retryRequest.fields.addAll(request.fields);
          retryRequest.files.add(
            http.MultipartFile.fromBytes(
              'File',
              bytes,
              filename: fileName,
              contentType: MediaType('image', 'png'),
            ),
          );
          final retryStreamed = await _client.send(retryRequest).timeout(const Duration(seconds: 45));
          response = await http.Response.fromStream(retryStreamed);
        }
      }

      if (kDebugMode) {
        debugPrint('[DrawingAiService] Analyze status: ${response.statusCode}');
        debugPrint('[DrawingAiService] Analyze body: ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final resDto = AnalyzeDrawingResponse.fromJson(decoded);
          return DrawingAiResult.success(resDto);
        }
      }

      // If backend returned error message
      String serverErrorMsg = 'Máy chủ phản hồi mã lỗi ${response.statusCode}';
      try {
        final errJson = jsonDecode(response.body);
        if (errJson is Map && errJson['message'] != null) {
          serverErrorMsg = errJson['message'].toString();
        }
      } catch (_) {}

      if (kDebugMode) {
        debugPrint('[DrawingAiService] Server error: $serverErrorMsg');
      }

      return DrawingAiResult.failure(serverErrorMsg);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DrawingAiService] Exception in analyzeDrawing: $e');
      }
      return DrawingAiResult.failure('Lỗi kết nối hoặc xử lý ảnh: $e');
    }
  }

  // ==========================================
  // GIAI ĐOẠN 2: SINH HÌNH ẢNH NHÂN VẬT PREVIEW
  // POST /api/drawings/generate-character (application/json)
  // ==========================================
  static Future<DrawingAiResult<GenerateCharacterResponse>> generateCharacter({
    required GenerateCharacterRequest request,
    String? token,
  }) async {
    final url = Uri.parse(AppConfig.drawingsGenerateCharacterUrl);

    try {
      final jsonBody = jsonEncode(request.toJson());
      if (kDebugMode) {
        debugPrint('[DrawingAiService] POST $url payload: $jsonBody');
      }

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _client
          .post(url, headers: headers, body: jsonBody)
          .timeout(const Duration(seconds: 45));

      if (kDebugMode) {
        debugPrint('[DrawingAiService] Generate character status: ${response.statusCode}');
        debugPrint('[DrawingAiService] Generate character body: ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final resDto = GenerateCharacterResponse.fromJson(decoded);
          return DrawingAiResult.success(resDto);
        }
      }

      String serverErrorMsg = 'Máy chủ phản hồi mã lỗi ${response.statusCode}';
      try {
        final errJson = jsonDecode(response.body);
        if (errJson is Map && errJson['message'] != null) {
          serverErrorMsg = errJson['message'].toString();
        }
      } catch (_) {}

      if (kDebugMode) {
        debugPrint('[DrawingAiService] Generate error: $serverErrorMsg');
      }

      return DrawingAiResult.failure(serverErrorMsg);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DrawingAiService] Exception in generateCharacter: $e');
      }
      return DrawingAiResult.failure('Lỗi kết nối hoặc tạo nhân vật: $e');
    }
  }

  // ==========================================
  // CREDIT TRANSACTION LOGS
  // GET /api/credit-transaction-logs
  // ==========================================
  static Future<List<CreditTransactionLog>> fetchCreditTransactionLogs({
    String? parentProfileId,
    String? token,
  }) async {
    final urlStr = (parentProfileId != null && parentProfileId.isNotEmpty && AppConfig.isValidUuid(parentProfileId))
        ? AppConfig.creditTransactionLogsByParentUrl(parentProfileId)
        : AppConfig.creditTransactionLogsUrl;
    final url = Uri.parse(urlStr);

    try {
      final headers = <String, String>{'Accept': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _client.get(url, headers: headers).timeout(const Duration(seconds: 15));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .whereType<Map<String, dynamic>>()
              .map((item) => CreditTransactionLog.fromJson(item))
              .toList();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DrawingAiService] Error fetching credit logs: $e');
      }
    }

    return const <CreditTransactionLog>[];
  }
}
