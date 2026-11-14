import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// 🎨 STORY PLAYER STYLESHEET (Tương đương story_player.module.css trong React)
/// Gom toàn bộ BoxDecoration, TextStyle, ButtonStyle, Spacing ra riêng biệt.
class StoryPlayerStyles {
  // ==========================================
  // 1. BOTTOM SHEET & MODAL DECORATIONS
  // ==========================================
  /// Khung nền cho BottomSheet (Gán vai, Hoạt họa, Từ vựng)
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

  /// Thanh gạt modal ở trên cùng
  static final sheetDragHandle = Container(
    width: 44,
    height: 5,
    decoration: BoxDecoration(
      color: AppColors.outlineVariant,
      borderRadius: BorderRadius.circular(9999),
    ),
  );

  // ==========================================
  // 2. DIALOG DECORATIONS
  // ==========================================
  /// Dialog Chúc mừng hoàn thành truyện
  static final finishedStoryDialog = BoxDecoration(
    color: AppColors.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(28),
    border: Border.all(color: const Color(0xFFF59E0B), width: 2),
    boxShadow: const [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 20,
        offset: Offset(0, 8),
      ),
    ],
  );

  /// Dialog Báo cáo nội dung (Safety Shield)
  static final reportDialogDecoration = BoxDecoration(
    color: AppColors.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(28),
    border: Border.all(color: const Color(0xFFFFCDD2), width: 2),
    boxShadow: const [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 20,
        offset: Offset(0, 8),
      ),
    ],
  );

  /// Card gán vai diễn
  static BoxDecoration roleCardDecoration({required bool isRoleMapped}) {
    return BoxDecoration(
      color: isRoleMapped
          ? AppColors.secondaryFixedDim.withValues(alpha: 0.15)
          : AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isRoleMapped ? AppColors.secondary : AppColors.outlineVariant,
        width: isRoleMapped ? 1.5 : 1,
      ),
    );
  }

  /// Badge vai chính / bạn đồng hành
  static final roleBadgeDecoration = BoxDecoration(
    color: AppColors.secondaryFixedDim.withValues(alpha: 0.5),
    borderRadius: BorderRadius.circular(8),
  );

  // ==========================================
  // 3. TYPOGRAPHY
  // ==========================================
  static const sheetTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurface,
  );

  static const sheetSubtitle = TextStyle(
    fontSize: 12,
    color: AppColors.onSurfaceVariant,
  );

  // ==========================================
  // 4. BUTTON STYLES
  // ==========================================
  static final squishyBtnShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(9999),
  );
}

