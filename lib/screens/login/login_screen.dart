import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_loading.dart';
import 'components/login_form_card.dart';
import 'components/login_header_brand.dart';
import 'components/login_security_note.dart';
import 'dialogs/login_error_dialog.dart';
import 'dialogs/login_time_limit_dialog.dart';
import 'login_controller.dart';

export 'login_controller.dart';
export 'login_styles.dart';

/// Man hinh Dang Nhap Cua Be (LoginScreen)
/// Da tai cau truc theo mo hinh Component hoa tinh gon:
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
    final isMobile = Responsive.isMobile(context);
    final outerPadding = Responsive.value<EdgeInsets>(
      context,
      mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      tablet: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      desktop: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
    );
    final formMaxWidth = Responsive.value<double>(
      context,
      mobile: 390.0,
      tablet: 450.0,
      desktop: 470.0,
    );
    final verticalSpacing = Responsive.value<double>(
      context,
      mobile: 16.0,
      tablet: 22.0,
    );
    final bgImagePath = isMobile
        ? 'assets/images/login-bg-mobile.png'
        : 'assets/images/login-bg.png';

    return Scaffold(
      backgroundColor: AppColors.surface,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Anh nen trang dang nhap: Tu dong chon anh doc cho Dien thoai hoac anh ngang cho iPad
          Positioned.fill(
            child: Image.asset(
              bgImagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Image.asset(
                'assets/images/login-bg.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),

          // 2. Noi dung Dang nhap can giua linh hoat
          AppLoadingOverlay(
            isLoading: _controller.isLoading,
            label: 'Đang mở cổng kỳ diệu...',
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, viewportConstraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: outerPadding,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: (viewportConstraints.maxHeight - (isMobile ? 28 : 48))
                            .clamp(0.0, double.infinity),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: formMaxWidth),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 1. Logo & Thuong hieu (Tu dong co gian theo man hinh)
                              const LoginHeaderBrand(),

                              SizedBox(height: verticalSpacing),

                              // 2. Form nhap & Nut vao the gioi ky dieu
                              LoginFormCard(
                                nameController: _controller.nameController,
                                passwordController: _controller.passwordController,
                                obscurePassword: _controller.obscurePassword,
                                isLoading: _controller.isLoading,
                                onToggleObscure: _controller.toggleObscurePassword,
                                onSubmit: _handleLogin,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
