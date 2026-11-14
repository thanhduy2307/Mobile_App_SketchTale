import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// 🎨 Stylesheet CSS cho Home Screen
class HomeStyles {
  HomeStyles._();

  static BoxDecoration greetingCardDecoration = BoxDecoration(
    color: AppColors.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColors.outline, width: 1.2),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0A001050),
        offset: Offset(0, 3),
        blurRadius: 10,
      ),
    ],
  );

  static BoxDecoration heroContinueCardDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(26),
    border: Border.all(color: const Color(0xFFFBBF24), width: 1.8),
    boxShadow: const [
      BoxShadow(
        color: Color(0x18F59E0B),
        offset: Offset(0, 4),
        blurRadius: 14,
      ),
    ],
  );

  static BoxDecoration heroCompletedCardDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(26),
    border: Border.all(color: const Color(0xFF34D399), width: 1.8),
    boxShadow: const [
      BoxShadow(
        color: Color(0x1810B981),
        offset: Offset(0, 4),
        blurRadius: 14,
      ),
    ],
  );

  static BoxDecoration gateCardDecoration = BoxDecoration(
    color: AppColors.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColors.outline, width: 1.2),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0C001050),
        offset: Offset(0, 4),
        blurRadius: 12,
      ),
    ],
  );

  static BoxDecoration todayStoryCardDecoration = BoxDecoration(
    color: AppColors.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(22),
    border: Border.all(color: AppColors.outline, width: 1.2),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0C001050),
        offset: Offset(0, 3),
        blurRadius: 10,
      ),
    ],
  );

  static BoxDecoration tipCardDecoration = BoxDecoration(
    color: AppColors.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColors.outline, width: 1.2),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0A001050),
        offset: Offset(0, 3),
        blurRadius: 10,
      ),
    ],
  );
}

