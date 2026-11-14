import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// 🎨 COLLECTION SCREEN STYLESHEET (Tương đương collection.module.css)
class CollectionStyles {
  // ==========================================
  // 1. CARDS & CONTAINERS
  // ==========================================
  /// Khung hồ sơ Hero Header của bé
  static final heroHeaderDecoration = BoxDecoration(
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

  /// Khung bọc thanh chuyển Segment
  static final segmentContainerDecoration = BoxDecoration(
    color: AppColors.surfaceContainerHigh,
    borderRadius: BorderRadius.circular(9999),
  );

  /// Card nhân vật 3D
  static BoxDecoration characterCardDecoration({required bool isApproved}) {
    return BoxDecoration(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isApproved ? AppColors.outlineVariant : const Color(0xFFFCD34D),
        width: isApproved ? 1.0 : 1.5,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A000000),
          offset: Offset(0, 3),
          blurRadius: 8,
        ),
      ],
    );
  }

  /// Khung card thống kê thành tích
  static final statCardDecoration = BoxDecoration(
    color: AppColors.surfaceContainerLow,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: AppColors.outlineVariant, width: 1),
  );

  // ==========================================
  // 2. BADGES
  // ==========================================
  static final pendingBadgeDecoration = BoxDecoration(
    color: const Color(0xFFFEF3C7),
    borderRadius: BorderRadius.circular(9999),
    border: Border.all(color: const Color(0xFFFCD34D), width: 0.8),
  );

  static const pendingBadgeText = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: Color(0xFF92400E),
  );
}

