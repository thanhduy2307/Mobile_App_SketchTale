import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// 🎨 DRAWING SCREEN STYLESHEET (Tương đương drawing.module.css trong React)
/// Gom toàn bộ BoxDecoration, TextStyle, ButtonStyle, Spacing ra riêng biệt.
class DrawingStyles {
  // ==========================================
  // 1. BẢNG MÀU KẸO NGỌT (14 CURATED COLORS)
  // ==========================================
  static const List<Color> paletteColors = [
    Color(0xFFE11D48), // 0: Đỏ hoa hồng
    Color(0xFFF97316), // 1: Cam cà rốt
    Color(0xFFFBBF24), // 2: Vàng nắng
    Color(0xFF22C55E), // 3: Xanh lá tươi
    Color(0xFF14B8A6), // 4: Xanh ngọc
    Color(0xFF0EA5E9), // 5: Xanh da trời
    Color(0xFF3B82F6), // 6: Xanh hoàng gia
    Color(0xFF8B5CF6), // 7: Tím violet
    Color(0xFFEC4899), // 8: Hồng kẹo ngọt
    Color(0xFFFFB5A7), // 9: Hồng phấn pastel
    Color(0xFFFCD5CE), // 10: Màu kem da
    Color(0xFF78350F), // 11: Nâu socola
    Color(0xFF64748B), // 12: Xám than chì
    Color(0xFF111C2D), // 13: Đen mực vẽ
  ];

  static const List<String> suggestedNames = [
    'Rồng Cam Bibo',
    'Dũng Sĩ Hạt Dẻ',
    'Khủng Long Tí Nị',
    'Mèo Con Phép Thuật',
    'Gấu Trúc Dũng Cảm',
    'Thỏ Trắng Tinh Nghịch',
    'Sư Tử Lửa Siêu Quậy',
  ];

  // ==========================================
  // 2. KHUNG VÀ BOX DECORATIONS (CONTAINERS)
  // ==========================================
  /// Khung nền cho toàn bộ các Dialog / Pop-up
  static final dialogCardDecoration = BoxDecoration(
    color: AppColors.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(28),
    boxShadow: const [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 20,
        offset: Offset(0, 10),
      ),
    ],
  );

  /// Khung viền canvas vẽ tranh của bé
  static final canvasCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryContainer.withValues(alpha: 0.15),
        blurRadius: 18,
        offset: const Offset(0, 6),
      ),
    ],
  );

  /// Viền preview ảnh 3D
  static final mascotPreviewBoxDecoration = BoxDecoration(
    color: AppColors.surfaceContainerLow,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: AppColors.secondaryFixed,
      width: 2,
    ),
  );

  /// Nút nghe giọng 3D
  static final voiceBtnDecoration = BoxDecoration(
    color: AppColors.secondary,
    borderRadius: BorderRadius.circular(9999),
    boxShadow: const [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 4,
      ),
    ],
  );

  /// Huy hiệu trạng thái Chờ duyệt (Amber/Gold badge)
  static final pendingBadgeDecoration = BoxDecoration(
    color: const Color(0xFFFEF3C7),
    borderRadius: BorderRadius.circular(9999),
    border: Border.all(
      color: const Color(0xFFFCD34D),
      width: 1,
    ),
  );

  /// Huy hiệu số dư credits
  static final creditsBadgeDecoration = BoxDecoration(
    color: AppColors.secondaryFixed.withValues(alpha: 0.35),
    borderRadius: BorderRadius.circular(9999),
  );

  /// Top pill badge (Bạn 3D của bé đã xuất hiện)
  static final topPillBadgeDecoration = BoxDecoration(
    color: AppColors.primaryFixed,
    borderRadius: BorderRadius.circular(9999),
  );

  // ==========================================
  // 3. PADDING & SPACING CONSTANTS
  // ==========================================
  static const dialogPadding = EdgeInsets.all(20);
  static const dialogInnerSpacing = SizedBox(height: 14);
  static const dialogSmallSpacing = SizedBox(height: 8);

  // ==========================================
  // 4. TYPOGRAPHY (TEXT STYLES)
  // ==========================================
  static const pendingBadgeText = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: Color(0xFF92400E),
  );

  static const creditsBadgeText = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.secondary,
  );

  static const voiceBtnText = TextStyle(
    color: Colors.white,
    fontSize: 11,
    fontWeight: FontWeight.bold,
  );

  // ==========================================
  // 5. BUTTON STYLES
  // ==========================================
  /// Nút chính bo tròn viên kẹo (Primary squishy)
  static final primaryRoundedBtn = FilledButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.onPrimary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(9999),
    ),
    padding: const EdgeInsets.symmetric(vertical: 10),
  );

  /// Nút phụ viền xám / cam (Outlined squishy)
  static final outlineRoundedBtn = OutlinedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(9999),
    ),
    padding: const EdgeInsets.symmetric(vertical: 10),
    side: const BorderSide(
      color: AppColors.outline,
      width: 1.5,
    ),
  );

  /// Nút Tạo Lại màu cam viền nổi
  static final regenerateBtn = OutlinedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(9999),
    ),
    padding: const EdgeInsets.symmetric(vertical: 10),
    side: const BorderSide(
      color: Color(0xFFF59E0B),
      width: 1.5,
    ),
  );
}

