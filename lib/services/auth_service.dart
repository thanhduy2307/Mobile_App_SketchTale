import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/auth_models.dart';
import '../utils/app_config.dart';

/// Result object for authentication actions
class LoginResult {
  final bool isSuccess;
  final String? token;
  final String? refreshToken;
  final String? username;
  final String? nickName;
  final String? email;
  final String? role;
  final String message;
  final AuthTokenData? tokenData;

  const LoginResult({
    required this.isSuccess,
    this.token,
    this.refreshToken,
    this.username,
    this.nickName,
    this.email,
    this.role,
    required this.message,
    this.tokenData,
  });

  factory LoginResult.success({
    String? token,
    String? refreshToken,
    String? username,
    String? nickName,
    String? email,
    String? role,
    String? message,
    AuthTokenData? tokenData,
  }) =>
      LoginResult(
        isSuccess: true,
        token: token,
        refreshToken: refreshToken,
        username: username,
        nickName: nickName,
        email: email,
        role: role,
        message: message ?? 'Đăng nhập thành công',
        tokenData: tokenData,
      );

  factory LoginResult.failure(String message) => LoginResult(
        isSuccess: false,
        message: message,
      );
}

/// Service handling all 14 AuthController endpoints according to AUTH_CONTROLLER_README.md (v2.2)
class AuthService {
  static final http.Client _client = http.Client();

  // Helper method for error extraction
  static String _extractErrorMessage(String responseBody, String defaultMessage) {
    if (responseBody.isEmpty) return defaultMessage;
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        if (decoded['message'] != null) {
          return decoded['message'].toString();
        } else if (decoded['title'] != null) {
          return decoded['title'].toString();
        } else if (decoded['error'] != null) {
          return decoded['error'].toString();
        }
      }
    } catch (_) {}
    return defaultMessage;
  }

  // ==========================================
  // 2.4. ĐĂNG NHẬP RIÊNG CHO TRẺ EM (CHILD)
  // POST /api/auth/login/child
  // ==========================================
  static Future<LoginResult> loginChild({
    required String username,
    required String password,
  }) async {
    final trimmedUsername = username.trim();
    final trimmedPassword = password.trim();

    if (trimmedUsername.isEmpty) {
      return LoginResult.failure('Bé ơi, hãy điền tên đăng nhập nhé.');
    }
    if (trimmedPassword.isEmpty) {
      return LoginResult.failure('Bé ơi, hãy nhập mật khẩu nữa nhé.');
    }

    final url = Uri.parse(AppConfig.authLoginChildUrl);
    final payload = jsonEncode({
      'username': trimmedUsername,
      'password': trimmedPassword,
    });

    try {
      if (kDebugMode) {
        debugPrint('[AuthService] POST $url payload: $payload');
      }

      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: payload,
          )
          .timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        debugPrint('[AuthService] Child login response status: ${response.statusCode}');
        debugPrint('[AuthService] Child login response body: ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        String? token;
        String? refreshToken;
        String? role = 'Child';
        String? email;
        String? nickName;
        String message = 'Bé đăng nhập thành công';
        AuthTokenData? tokenData;

        if (response.body.isNotEmpty) {
          try {
            final decoded = jsonDecode(response.body);
            if (decoded is Map<String, dynamic>) {
              if (decoded['message'] != null) {
                message = decoded['message'].toString();
              }
              final data = decoded['data'];
              if (data is Map<String, dynamic>) {
                tokenData = AuthTokenData.fromJson(data);
                token = tokenData.token;
                refreshToken = tokenData.refreshToken;
                role = tokenData.role;
                email = tokenData.email;
              } else {
                token = decoded['token'] as String? ??
                    decoded['accessToken'] as String?;
                refreshToken = decoded['refreshToken'] as String?;
              }
              nickName = decoded['nickName'] as String? ??
                  decoded['nickname'] as String? ??
                  trimmedUsername;
            }
          } catch (_) {}
        }

        return LoginResult.success(
          token: token,
          refreshToken: refreshToken,
          username: trimmedUsername,
          nickName: nickName ?? trimmedUsername,
          email: email,
          role: role,
          message: message,
          tokenData: tokenData,
        );
      } else {
        final errorMessage = _extractErrorMessage(
          response.body,
          'Tên đăng nhập hoặc mật khẩu không chính xác!',
        );
        return LoginResult.failure(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AuthService] loginChild exception: $e');
      }
      return LoginResult.failure(
        'Không thể kết nối máy chủ. Hãy kiểm tra kết nối mạng nhé! ($e)',
      );
    }
  }

  // ==========================================
  // 2.3. ĐĂNG NHẬP CHUNG (PARENT, ADMIN, CONTENTMANAGER)
  // POST /api/auth/login
  // ==========================================
  static Future<LoginResult> loginGeneral({
    required String identifier,
    required String password,
  }) async {
    final trimmedIdentifier = identifier.trim();
    final trimmedPassword = password.trim();

    if (trimmedIdentifier.isEmpty) {
      return LoginResult.failure('Vui lòng nhập Email hoặc Tên đăng nhập!');
    }
    if (trimmedPassword.isEmpty) {
      return LoginResult.failure('Vui lòng nhập mật khẩu!');
    }

    final url = Uri.parse(AppConfig.authLoginUrl);
    final payload = jsonEncode({
      'identifier': trimmedIdentifier,
      'password': trimmedPassword,
    });

    try {
      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: payload,
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        String? token;
        String? refreshToken;
        String? username;
        String? email;
        String? role;
        String message = 'Đăng nhập thành công!';
        AuthTokenData? tokenData;

        if (response.body.isNotEmpty) {
          try {
            final decoded = jsonDecode(response.body);
            if (decoded is Map<String, dynamic>) {
              if (decoded['message'] != null) {
                message = decoded['message'].toString();
              }
              final data = decoded['data'];
              if (data is Map<String, dynamic>) {
                tokenData = AuthTokenData.fromJson(data);
                token = tokenData.token;
                refreshToken = tokenData.refreshToken;
                username = tokenData.username;
                email = tokenData.email;
                role = tokenData.role;
              }
            }
          } catch (_) {}
        }

        return LoginResult.success(
          token: token,
          refreshToken: refreshToken,
          username: username ?? trimmedIdentifier,
          email: email,
          role: role ?? 'Parent',
          message: message,
          tokenData: tokenData,
        );
      } else {
        final errorMessage = _extractErrorMessage(
          response.body,
          'Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin!',
        );
        return LoginResult.failure(errorMessage);
      }
    } catch (e) {
      return LoginResult.failure('Lỗi kết nối máy chủ: $e');
    }
  }

  // ==========================================
  // 2.12. ĐĂNG XUẤT (LOGOUT & JWT BLACKLIST TỨC THÌ)
  // POST /api/auth/logout (No parameters)
  // Header: Authorization: Bearer <access_token>
  // ==========================================
  static Future<bool> logout({required String? token}) async {
    if (token == null || token.isEmpty) return true;

    final url = Uri.parse(AppConfig.authLogoutUrl);
    try {
      if (kDebugMode) {
        debugPrint('[AuthService] POST $url (Logout & JWT Blacklist)');
      }

      final response = await _client.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        debugPrint('[AuthService] Logout status: ${response.statusCode}');
        debugPrint('[AuthService] Logout body: ${response.body}');
      }
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AuthService] Logout exception (handled gracefully): $e');
      }
      return false;
    }
  }

  // ==========================================
  // 2.13. CẤP MỚI TOKEN (REFRESH TOKEN ROTATION)
  // POST /api/auth/refresh-token
  // Header: Authorization: Bearer <access_token>
  // Body (optional): {"refreshToken": "<refresh_token>"}
  // ==========================================
  static Future<LoginResult> refreshToken({
    String? token,
    String? refreshToken,
  }) async {
    final url = Uri.parse(AppConfig.authRefreshTokenUrl);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final body = refreshToken != null && refreshToken.isNotEmpty
        ? jsonEncode({'refreshToken': refreshToken})
        : null;

    try {
      if (kDebugMode) {
        debugPrint('[AuthService] POST $url (Refresh Token Rotation)');
      }

      final response = await _client
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['data'] is Map<String, dynamic>) {
          final tokenData = AuthTokenData.fromJson(decoded['data'] as Map<String, dynamic>);
          return LoginResult.success(
            token: tokenData.token,
            refreshToken: tokenData.refreshToken,
            username: tokenData.username,
            email: tokenData.email,
            role: tokenData.role,
            message: decoded['message']?.toString() ?? 'Làm mới token thành công!',
            tokenData: tokenData,
          );
        }
        return LoginResult.failure('Dữ liệu token trả về không đúng định dạng!');
      } else {
        final error = _extractErrorMessage(response.body, 'Phiên đăng nhập đã hết hạn.');
        return LoginResult.failure(error);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AuthService] refreshToken exception: $e');
      }
      return LoginResult.failure('Không thể làm mới phiên đăng nhập: $e');
    }
  }

  // ==========================================
  // 2.14. LẤY ROLE HIỆN TẠI CỦA NGƯỜI DÙNG
  // GET /api/auth/current-role
  // Header: Authorization: Bearer <access_token>
  // ==========================================
  static Future<String?> getCurrentRole({required String token}) async {
    if (token.isEmpty) return null;
    final url = Uri.parse(AppConfig.authCurrentRoleUrl);

    try {
      final response = await _client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['data'] != null) {
          return decoded['data'].toString();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AuthService] getCurrentRole exception: $e');
      }
    }
    return null;
  }

  // ==========================================
  // 2.8. LẤY THÔNG TIN CÁ NHÂN (PROFILE)
  // GET /api/auth/profile
  // Header: Authorization: Bearer <access_token>
  // ==========================================
  static Future<UserProfile?> getProfile({required String token}) async {
    if (token.isEmpty) return null;
    final url = Uri.parse(AppConfig.authProfileUrl);

    try {
      final response = await _client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['data'] is Map<String, dynamic>) {
          return UserProfile.fromJson(decoded['data'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AuthService] getProfile exception: $e');
      }
    }
    return null;
  }

  // ==========================================
  // 2.1. ĐĂNG KÝ PHỤ HUYNH
  // POST /api/auth/register/parent
  // ==========================================
  static Future<String?> registerParent({
    required String username,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(AppConfig.authRegisterParentUrl);
    final payload = jsonEncode({
      'username': username.trim(),
      'email': email.trim(),
      'password': password.trim(),
    });

    try {
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: payload,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        return decoded['message']?.toString() ?? 'Đăng ký tài khoản thành công!';
      } else {
        return _extractErrorMessage(response.body, 'Đăng ký tài khoản thất bại.');
      }
    } catch (e) {
      return 'Lỗi kết nối: $e';
    }
  }

  // ==========================================
  // 2.2. PHỤ HUYNH TẠO TÀI KHOẢN CHO CON (CHILD)
  // POST /api/auth/register/child
  // Header: Authorization: Bearer <parent_token>
  // ==========================================
  static Future<String?> registerChild({
    required String parentToken,
    required String username,
    required String password,
    required String nickName,
  }) async {
    final url = Uri.parse(AppConfig.authRegisterChildUrl);
    final payload = jsonEncode({
      'username': username.trim(),
      'password': password.trim(),
      'nickName': nickName.trim(),
    });

    try {
      final response = await _client.post(
        url,
        headers: {
          'Authorization': 'Bearer $parentToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: payload,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        return decoded['message']?.toString() ?? 'Tạo tài khoản cho bé thành công!';
      } else {
        return _extractErrorMessage(response.body, 'Tạo tài khoản cho bé thất bại.');
      }
    } catch (e) {
      return 'Lỗi kết nối: $e';
    }
  }

  // ==========================================
  // 2.5. QUÊN MẬT KHẨU
  // POST /api/auth/forgot-password
  // ==========================================
  static Future<String?> forgotPassword({required String email}) async {
    final url = Uri.parse(AppConfig.authForgotPasswordUrl);
    final payload = jsonEncode({'email': email.trim()});

    try {
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: payload,
      ).timeout(const Duration(seconds: 15));

      final decoded = jsonDecode(response.body);
      return decoded['message']?.toString() ??
          'Nếu email tồn tại, hướng dẫn đặt lại mật khẩu đã được gửi.';
    } catch (e) {
      return 'Lỗi kết nối: $e';
    }
  }

  // ==========================================
  // 2.7. ĐỔI MẬT KHẨU
  // POST /api/auth/change-password
  // Header: Authorization: Bearer <access_token>
  // ==========================================
  static Future<String?> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    final url = Uri.parse(AppConfig.authChangePasswordUrl);
    final payload = jsonEncode({
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });

    try {
      final response = await _client.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: payload,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        return decoded['message']?.toString() ?? 'Đổi mật khẩu thành công!';
      } else {
        return _extractErrorMessage(response.body, 'Đổi mật khẩu thất bại.');
      }
    } catch (e) {
      return 'Lỗi kết nối: $e';
    }
  }
}
