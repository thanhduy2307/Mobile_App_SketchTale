import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../utils/responsive.dart';
import '../login_styles.dart';

/// Form nhap ten & mat khau kem nut Dang Nhap 3D (Thich ung Dien thoai & iPad)
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
    final isMobile = Responsive.isMobile(context);
    final cardPadding = Responsive.value<EdgeInsets>(
      context,
      mobile: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      tablet: const EdgeInsets.all(24),
      desktop: const EdgeInsets.all(28),
    );
    final buttonHeight = Responsive.value<double>(
      context,
      mobile: 52.0,
      tablet: 56.0,
      desktop: 58.0,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Container(
          width: double.infinity,
          padding: cardPadding,
          decoration: LoginStyles.authCardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username input
              Text(
                'Tên tài khoản của bé',
                style: isMobile
                    ? AppTypography.headlineSm(color: AppColors.onSurface).copyWith(fontSize: 15)
                    : AppTypography.headlineSm(color: AppColors.onSurface),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                style: AppTypography.headlineSm(color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Nhập tên tài khoản',
                  hintStyle: AppTypography.bodySm(
                    color: AppColors.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFFFFDF7),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isMobile ? 12 : 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFE9E9EF),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Password input
              Text(
                'Mật khẩu của bé',
                style: isMobile
                    ? AppTypography.headlineSm(color: AppColors.onSurface).copyWith(fontSize: 15)
                    : AppTypography.headlineSm(color: AppColors.onSurface),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                style: AppTypography.headlineSm(color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Nhập mật khẩu...',
                  hintStyle: AppTypography.bodySm(
                    color: AppColors.onSurfaceVariant,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: const Color(0xFF48BCFC),
                    ),
                    onPressed: onToggleObscure,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFFFFDF7),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isMobile ? 12 : 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFE9E9EF),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Big 3D Squishy Enter Game Button
              Squishy3DButton.primary(
                onPressed: isLoading ? () {} : onSubmit,
                height: buttonHeight,
                depth: 5.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'VÀO THẾ GIỚI KỲ DIỆU',
                      style: TextStyle(
                        fontSize: isMobile ? 15 : 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
