import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_loading.dart';
import 'components/login_form_card.dart';
import 'components/login_header_brand.dart';
import 'components/login_security_note.dart';
import 'dialogs/login_error_dialog.dart';
import 'dialogs/login_time_limit_dialog.dart';
import 'login_controller.dart';

export 'login_controller.dart';
export 'login_styles.dart';

/// 🔐 Màn hình Đăng Nhập Của Bé (LoginScreen)
/// Đã tái cấu trúc theo mô hình Component hóa siêu tinh gọn:
/// - Controller: [LoginController]
/// - Stylesheet: [LoginStyles]
/// - Components: [LoginHeaderBrand], [LoginFormCard], [LoginSecurityNote]
/// - Dialogs: [LoginErrorDialog], [LoginTimeLimitDialog]
class LoginScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.appState,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LoginController();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.star_rounded, color: AppColors.primaryContainer, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: AppTypography.labelMd(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: AppColors.onSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
        duration: const Duration(milliseconds: 2200),
      ),
    );
  }

  void _handleLogin() {
    _controller.login(
      appState: widget.appState,
      onSuccess: () {
        _showToast('Đăng nhập thành công! Chúc bé đọc truyện vui vẻ.');
        widget.onLoginSuccess();
      },
      onError: (msg) {
        if (msg.contains('Bé ơi')) {
          _showToast(msg);
        } else {
          LoginErrorDialog.show(context, msg);
        }
      },
      onTimeLimit: () {
        LoginTimeLimitDialog.show(context, onAcknowledge: widget.onLoginSuccess);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: AppLoadingOverlay(
        isLoading: _controller.isLoading,
        label: 'Đang mở cổng kỳ diệu...',
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),

                // 1. Logo & Thương hiệu
                const LoginHeaderBrand(),

                const SizedBox(height: 20),

                // 2. Form nhập & Nút vào thế giới kỳ diệu
                LoginFormCard(
                  nameController: _controller.nameController,
                  passwordController: _controller.passwordController,
                  obscurePassword: _controller.obscurePassword,
                  isLoading: _controller.isLoading,
                  onToggleObscure: _controller.toggleObscurePassword,
                  onSubmit: _handleLogin,
                ),

                const SizedBox(height: 16),

                // 4. Ghi chú bảo mật an toàn cho bé
                const LoginSecurityNote(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
