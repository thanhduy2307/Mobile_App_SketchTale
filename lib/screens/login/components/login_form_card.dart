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
    final cardPadding = const EdgeInsets.symmetric(horizontal: 4, vertical: 2);
    final buttonHeight = Responsive.value<double>(
      context,
      mobile: 52.0,
      tablet: 66.0,
      desktop: 68.0,
    );

    return Container(
      width: double.infinity,
      padding: cardPadding,
      decoration: LoginStyles.authCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Username input
          Text(
            'Tên tài khoản của bé',
            style: TextStyle(
              fontSize: isMobile ? 14.0 : 16.5,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1E293B),
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            style: TextStyle(
              fontSize: isMobile ? 15.0 : 17.5,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Nhập tên tài khoản',
              hintStyle: TextStyle(
                fontSize: isMobile ? 14.0 : 16.0,
                color: AppColors.onSurfaceVariant,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: isMobile ? 13 : 18,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: Color(0xFFE2D6C0),
                  width: 1.8,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2.2,
                ),
              ),
            ),
          ),

          SizedBox(height: isMobile ? 16 : 24),

          // Password input
          Text(
            'Mật khẩu của bé',
            style: TextStyle(
              fontSize: isMobile ? 14.0 : 16.5,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1E293B),
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: passwordController,
            obscureText: obscurePassword,
            style: TextStyle(
              fontSize: isMobile ? 15.0 : 17.5,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Nhập mật khẩu...',
              hintStyle: TextStyle(
                fontSize: isMobile ? 14.0 : 16.0,
                color: AppColors.onSurfaceVariant,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: const Color(0xFF48BCFC),
                  size: isMobile ? 22 : 26,
                ),
                onPressed: onToggleObscure,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: isMobile ? 13 : 18,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: Color(0xFFE2D6C0),
                  width: 1.8,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2.2,
                ),
              ),
            ),
          ),

          SizedBox(height: isMobile ? 22 : 34),

          // Big 3D Squishy Enter Game Button
          Squishy3DButton.primary(
            onPressed: isLoading ? () {} : onSubmit,
            height: buttonHeight,
            depth: 6.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'VÀO THẾ GIỚI KỲ DIỆU',
                  style: TextStyle(
                    fontSize: isMobile ? 15.5 : 18.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
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
