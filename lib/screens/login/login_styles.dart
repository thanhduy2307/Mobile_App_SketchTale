import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Stylesheet cho Man hinh Dang Nhap
class LoginStyles {
  LoginStyles._();

  static BoxDecoration kickerDecoration = BoxDecoration(
    color: AppColors.primaryFixed,
    borderRadius: BorderRadius.circular(9999),
    border: Border.all(color: const Color(0xFFECDBB5), width: 1.0),
  );

  static BoxDecoration presetCardDecoration = BoxDecoration(
    color: AppColors.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: const Color(0xFFFCD34D), width: 1.5),
    boxShadow: const [
      BoxShadow(
        color: Color(0x14F59E0B),
        offset: Offset(0, 4),
        blurRadius: 12,
      ),
    ],
  );

  static BoxDecoration authCardDecoration = const BoxDecoration(
    color: Colors.transparent,
  );

  static BoxDecoration securityBadgeDecoration = BoxDecoration(
    color: AppColors.surfaceContainerLow,
    borderRadius: BorderRadius.circular(9999),
    border: Border.all(color: AppColors.outline, width: 1.0),
  );
}

