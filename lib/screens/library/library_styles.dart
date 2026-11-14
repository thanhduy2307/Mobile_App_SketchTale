import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// 🎨 LIBRARY SCREEN STYLESHEET (Tương đương library.module.css)
class LibraryStyles {
  // ==========================================
  // 1. CARDS & CONTAINERS
  // ==========================================
  static final headerCardDecoration = BoxDecoration(
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

  static final storyCardDecoration = BoxDecoration(
    color: AppColors.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: AppColors.outlineVariant.withValues(alpha: 0.3),
      width: 1.0,
    ),
    boxShadow: const [
      BoxShadow(
        color: Color(0xFFE4E2DD),
        offset: Offset(0, 3),
        blurRadius: 4,
      ),
    ],
  );

  static const bottomSheetDecoration = BoxDecoration(
    color: AppColors.surfaceContainerLowest,
    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 25,
        offset: Offset(0, -5),
      ),
    ],
  );

  // ==========================================
  // 2. THEME COLOR HELPER
  // ==========================================
  static Color getThemeColor(String? themeName) {
    if (themeName == null) return const Color(0xFFF59E0B);
    final lower = themeName.toLowerCase();
    if (lower.contains('khoa học') || lower.contains('vũ trụ')) {
      return const Color(0xFF3B82F6);
    }
    if (lower.contains('thiên nhiên') || lower.contains('môi trường')) {
      return const Color(0xFF10B981);
    }
    if (lower.contains('cảm xúc') || lower.contains('tình bạn')) {
      return const Color(0xFFEC4899);
    }
    if (lower.contains('phiêu lưu') || lower.contains('kỳ ảo')) {
      return const Color(0xFF8B5CF6);
    }
    if (lower.contains('đạo đức') || lower.contains('gia đình')) {
      return const Color(0xFFF59E0B);
    }
    return const Color(0xFFF59E0B);
  }
}

