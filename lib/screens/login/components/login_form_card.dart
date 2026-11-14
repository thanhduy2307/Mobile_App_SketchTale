import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../login_styles.dart';

/// 📝 Form nhập tên & mật khẩu kèm nút Đăng Nhập 3D
class LoginFormCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  const LoginFormCard({
    super.key,
    required this.nameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: LoginStyles.authCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Username input
          Text(
            'Tên tài khoản của bé',
            style: AppTypography.headlineSm(color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            style: AppTypography.headlineSm(color: AppColors.onSurface),
            decoration: InputDecoration(
              hintText: 'Nhập tên tài khoản',
              hintStyle: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
              filled: true,
              fillColor: const Color(0xFFFFFDF7),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE9E9EF), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Password input
          Text(
            'Mật khẩu của bé',
            style: AppTypography.headlineSm(color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: passwordController,
            obscureText: obscurePassword,
            style: AppTypography.headlineSm(color: AppColors.onSurface),
            decoration: InputDecoration(
              hintText: 'Nhập mật khẩu...',
              hintStyle: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: const Color(0xFF48BCFC),
                ),
                onPressed: onToggleObscure,
              ),
              filled: true,
              fillColor: const Color(0xFFFFFDF7),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE9E9EF), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Big 3D Squishy Enter Game Button
          Squishy3DButton.primary(
            onPressed: isLoading ? () {} : onSubmit,
            height: 56,
            depth: 5.0,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'VÀO THẾ GIỚI KỲ DIỆU',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

