import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../state/app_state.dart';
import 'auth_service.dart';

/// Hang doi va Mutex dieu phoi Refresh Token duy nhat (Single-flight queue)
/// Theo dac ta Section 4 trong AUTH_CONTROLLER_README.md:
/// Khi co nhieu request dong thoi gap loi 401, chi goi POST /api/auth/refresh-token
/// dung 1 lan duy nhat. Cac request khac doi ket qua roi dung token moi de retry.
class TokenRefreshQueue {
  Future<String?>? _inFlightRefresh;

  Future<String?> refreshToken() {
    if (_inFlightRefresh != null) {
      if (kDebugMode) {
        debugPrint('[TokenRefreshQueue] Refresh request dang duoc xu ly. Cac request khac doi ket qua...');
      }
      return _inFlightRefresh!;
    }
    _inFlightRefresh = _performRefresh();
    return _inFlightRefresh!;
  }

  Future<String?> _performRefresh() async {
    try {
      final appState = AppState.current;
      String? currentToken = appState?.authToken ?? ApiClient.instance.cachedToken;
      String? currentRefreshToken = appState?.refreshToken;

      // Doc tu SharedPreferences neu bo nho RAM chua kip nap
      if (currentToken == null || currentRefreshToken == null) {
        try {
          final prefs = await SharedPreferences.getInstance();
          currentToken ??= prefs.getString('sketchtale_auth_token');
          currentRefreshToken ??= prefs.getString('sketchtale_refresh_token');
        } catch (_) {}
      }

      if (currentToken == null && currentRefreshToken == null) {
        if (kDebugMode) {
          debugPrint('[TokenRefreshQueue] Khong tim thay token hoac refreshToken de lam moi.');
        }
        return null;
      }

      if (kDebugMode) {
        debugPrint('[TokenRefreshQueue] Bat dau lam moi token (Refresh Token Rotation)...');
      }

      final result = await AuthService.refreshToken(
        token: currentToken,
        refreshToken: currentRefreshToken,
      );

      if (result.isSuccess && result.token != null && result.token!.isNotEmpty) {
        final newToken = result.token!;
        final newRefreshToken = result.refreshToken;
        final newRole = result.role;

        if (kDebugMode) {
          debugPrint('[TokenRefreshQueue] Lam moi token thanh cong! Luu cap token moi theo Rotation vao Storage.');
        }

        // 1. Cap nhat vao ApiClient cache
        ApiClient.instance.updateToken(newToken);

        // 2. Cap nhat vao AppState
        if (appState != null) {
          appState.authToken = newToken;
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            appState.refreshToken = newRefreshToken;
          }
          if (newRole != null && newRole.isNotEmpty) {
            appState.userRole = newRole;
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            appState.notifyListeners();
          });
        }

        // 3. Luu de ca 2 token moi vao SharedPreferences (Bat buoc theo Rotation)
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('sketchtale_auth_token', newToken);
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await prefs.setString('sketchtale_refresh_token', newRefreshToken);
          }
          if (newRole != null && newRole.isNotEmpty) {
            await prefs.setString('sketchtale_role', newRole);
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[TokenRefreshQueue] Loi luu token vao SharedPreferences: $e');
          }
        }

        return newToken;
      } else {
        if (kDebugMode) {
          debugPrint('[TokenRefreshQueue] Refresh token that bai hoac phien 7 ngay da het han: ${result.message}');
        }
        // Phien 7 ngay het han: xoa token va dieu huong ve dang nhap
        ApiClient.instance.updateToken(null);
        if (appState != null) {
          await appState.logout();
        } else {
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('sketchtale_logged_in', false);
            await prefs.remove('sketchtale_auth_token');
            await prefs.remove('sketchtale_refresh_token');
          } catch (_) {}
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[TokenRefreshQueue] Exception khi refresh token: $e');
      }
      return null;
    } finally {
      _inFlightRefresh = null;
    }
  }
}

/// Client HTTP tap trung quan ly xac thuc, Refresh Token Rotation va Auto-Retry
/// Tuan thu chat che AUTH_CONTROLLER_README.md (v2.2):
/// - Tu dong gan header Authorization: Bearer <token>
/// - Tu dong chan loi 401 cua moi API can xac thuc
/// - Hang doi don nhat (single-flight) de chi refresh dung 1 lan
/// - Tu dong thu lai (retry) request voi token moi
/// - Xoa session va logout khi token 7 ngay het han
class ApiClient extends http.BaseClient {
  static final ApiClient instance = ApiClient._internal();
  factory ApiClient() => instance;

  ApiClient._internal();

  final http.Client _inner = http.Client();
  final TokenRefreshQueue _queue = TokenRefreshQueue();

  String? _cachedToken;
  String? get cachedToken => _cachedToken;
  String? get currentToken => _cachedToken ?? AppState.current?.authToken;

  void updateToken(String? token) {
    _cachedToken = token;
  }

  /// Kiem tra endpoint co thuoc dien can chan 401 de refresh hay khong
  bool _shouldIntercept(Uri url) {
    final path = url.path.toLowerCase();
    if (path.contains('/api/auth/login') ||
        path.contains('/api/auth/refresh-token') ||
        path.contains('/api/auth/register') ||
        path.contains('/api/auth/forgot-password') ||
        path.contains('/api/auth/reset-password') ||
        path.contains('/api/auth/confirm-email') ||
        path.contains('/api/auth/resend-confirmation-email') ||
        path.contains('/api/auth/logout')) {
      return false;
    }
    return true;
  }

  /// Chuan bi headers: tu dong dien token moi nhat neu thieu hoac neu token dang gui da loi thoi
  Map<String, String> _prepareHeaders(Map<String, String>? headers) {
    final result = Map<String, String>.from(headers ?? {});
    final activeToken = currentToken;

    if (activeToken != null && activeToken.isNotEmpty) {
      final authHeader = result['Authorization'];
      if (authHeader == null || authHeader.isEmpty) {
        result['Authorization'] = 'Bearer $activeToken';
      } else if (authHeader.startsWith('Bearer ')) {
        final tokenInHeader = authHeader.substring(7).trim();
        // Neu token trong header khac voi token moi nhat cua AppState, nang cap len token moi nhat
        if (tokenInHeader != activeToken) {
          result['Authorization'] = 'Bearer $activeToken';
        }
      }
    }
    return result;
  }

  /// Bo boc gui request va retry neu gap 401
  Future<http.Response> _sendWithRetry(
    Future<http.Response> Function(Map<String, String> headers) sendRequest, {
    required Uri url,
    Map<String, String>? originalHeaders,
  }) async {
    final effectiveHeaders = _prepareHeaders(originalHeaders);
    final response = await sendRequest(effectiveHeaders);

    if (response.statusCode == 401 && _shouldIntercept(url)) {
      if (kDebugMode) {
        debugPrint('[ApiClient] 401 Unauthorized tai $url. Chan loi ngam va lam moi token...');
      }

      final newToken = await _queue.refreshToken();
      if (newToken != null && newToken.isNotEmpty) {
        _cachedToken = newToken;
        if (kDebugMode) {
          debugPrint('[ApiClient] Lam moi token thanh cong. Tien hanh retry request $url...');
        }
        final retryHeaders = Map<String, String>.from(originalHeaders ?? {});
        retryHeaders['Authorization'] = 'Bearer $newToken';
        return await sendRequest(retryHeaders);
      } else {
        if (kDebugMode) {
          debugPrint('[ApiClient] Khong the lam moi token cho $url. Phien dang nhap da ket thuc.');
        }
      }
    }

    return response;
  }

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
    return _sendWithRetry(
      (h) => _inner.get(url, headers: h),
      url: url,
      originalHeaders: headers,
    );
  }

  @override
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return _sendWithRetry(
      (h) => _inner.post(url, headers: h, body: body, encoding: encoding),
      url: url,
      originalHeaders: headers,
    );
  }

  @override
  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return _sendWithRetry(
      (h) => _inner.put(url, headers: h, body: body, encoding: encoding),
      url: url,
      originalHeaders: headers,
    );
  }

  @override
  Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return _sendWithRetry(
      (h) => _inner.patch(url, headers: h, body: body, encoding: encoding),
      url: url,
      originalHeaders: headers,
    );
  }

  @override
  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return _sendWithRetry(
      (h) => _inner.delete(url, headers: h, body: body, encoding: encoding),
      url: url,
      originalHeaders: headers,
    );
  }

  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) {
    return _sendWithRetry(
      (h) => _inner.head(url, headers: h),
      url: url,
      originalHeaders: headers,
    );
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request is http.Request && _shouldIntercept(request.url)) {
      final bodyBytes = request.bodyBytes;
      final originalHeaders = Map<String, String>.from(request.headers);
      final effectiveHeaders = _prepareHeaders(originalHeaders);

      final initialReq = http.Request(request.method, request.url)
        ..headers.addAll(effectiveHeaders)
        ..bodyBytes = bodyBytes;

      final streamedResponse = await _inner.send(initialReq);
      if (streamedResponse.statusCode == 401) {
        if (kDebugMode) {
          debugPrint('[ApiClient] Streamed send 401 tai ${request.url}. Dang lam moi token...');
        }
        final newToken = await _queue.refreshToken();
        if (newToken != null && newToken.isNotEmpty) {
          _cachedToken = newToken;
          final retryReq = http.Request(request.method, request.url)
            ..headers.addAll(originalHeaders)
            ..headers['Authorization'] = 'Bearer $newToken'
            ..bodyBytes = bodyBytes;
          return await _inner.send(retryReq);
        }
      }
      return streamedResponse;
    }

    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
  }

  /// Goi chu dong lam moi token tu bat ky dau trong ung dung
  Future<String?> refreshToken() => _queue.refreshToken();
}

