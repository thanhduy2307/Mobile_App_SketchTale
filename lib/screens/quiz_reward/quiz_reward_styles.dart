import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// 🎨 Stylesheet cho Màn hình Câu Đố & Phần Thưởng
class QuizRewardStyles {
  QuizRewardStyles._();

  static BoxDecoration scoreBannerDecoration = BoxDecoration(
    color: AppColors.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(22),
    border: Border.all(color: const Color(0xFFFCD34D), width: 1.5),
    boxShadow: const [
      BoxShadow(
        color: Color(0x14001050),
        offset: Offset(0, 4),
        blurRadius: 10,
      ),
    ],
  );

  static BoxDecoration questionCardDecoration = BoxDecoration(
    color: AppColors.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColors.outline, width: 1.2),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0C001050),
        offset: Offset(0, 4),
        blurRadius: 14,
      ),
    ],
  );

  static BoxDecoration optionDecoration({required bool isSelected}) {
    return BoxDecoration(
      color: isSelected ? const Color(0xFFFFFBEB) : AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isSelected ? AppColors.primaryContainer : AppColors.outline,
        width: isSelected ? 2.5 : 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: isSelected ? const Color(0x22F59E0B) : const Color(0x08000000),
          offset: const Offset(0, 3),
          blurRadius: isSelected ? 8 : 4,
        ),
      ],
    );
  }

  static BoxDecoration hintCardDecoration = BoxDecoration(
    color: const Color(0xFFF0F9FF),
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: const Color(0xFFBAE6FD)),
  );
}

