import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../state/app_state.dart';

/// 🧠 Login Controller quản lý trạng thái đăng nhập của bé
class LoginController extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;
  bool isLoading = false;
  String selectedKidPreset = '';
  String? selectedAvatarPath;

  LoginController({String initialKidName = ''}) {
    nameController.text = initialKidName;
    passwordController.text = '';
  }

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void selectKidPreset(String name, String password, [String? assetPath]) {
    selectedKidPreset = name;
    nameController.text = name;
    passwordController.text = password;
    if (assetPath != null && assetPath.isNotEmpty) {
      selectedAvatarPath = assetPath;
    }
    notifyListeners();
  }

  Future<void> login({
    required AppState appState,
    required VoidCallback onSuccess,
    required void Function(String message) onError,
    required VoidCallback onTimeLimit,
  }) async {
    if (isLoading) return;

    final username = nameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty) {
      onError('Bé ơi, hãy điền tên đăng nhập nhé.');
      return;
    }
    if (password.isEmpty) {
      onError('Bé ơi, hãy nhập mật khẩu nhé.');
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      LoginResult result = await AuthService.loginChild(
        username: username,
        password: password,
      );

      // Nếu không thành công hoặc là tài khoản email/phụ huynh, thử đăng nhập qua cổng chung
      if (!result.isSuccess && (username.contains('@') || result.message.contains('không chính xác') || result.message.contains('không tìm thấy'))) {
        final generalResult = await AuthService.loginGeneral(
          identifier: username,
          password: password,
        );
        if (generalResult.isSuccess) {
          result = generalResult;
        }
      }

      isLoading = false;
      notifyListeners();

      if (result.isSuccess) {
        appState.login(
          result.nickName ?? result.username ?? username,
          token: result.token,
          refreshToken: result.refreshToken,
          username: result.username ?? username,
          role: result.role ?? 'Child',
          avatarPath: selectedAvatarPath,
        );

        if (!appState.hasRemainingScreenTime) {
          onTimeLimit();
        } else {
          onSuccess();
        }
      } else {
        onError(result.message);
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      onError('Đã có lỗi xảy ra khi đăng nhập: $e');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

