import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../drawing_types.dart';
export '../drawing_types.dart';

/// 🛠️ Thanh công cụ vẽ tranh (Bút vẽ, Đổ màu, Cục tẩy, Hoàn tác, Xóa bảng)
class DrawingToolbar extends StatelessWidget {
  final DrawingTool currentTool;
  final ValueChanged<DrawingTool> onSelectTool;
  final VoidCallback onUndo;
  final VoidCallback onClear;

  const DrawingToolbar({
    super.key,
    required this.currentTool,
    required this.onSelectTool,
    required this.onUndo,
    required this.onClear,
  });

  Widget _buildToolButton({
    required DrawingTool tool,
    required IconData icon,
    required String label,
  }) {
    final isSelected = (currentTool == tool);
    Color activeBg = AppColors.primaryContainer;
    Color activeBorder = const Color(0xFFD97706);

    if (tool == DrawingTool.bucket) {
      activeBg = AppColors.secondary;
      activeBorder = const Color(0xFF006398);
    } else if (tool == DrawingTool.eraser) {
      activeBg = const Color(0xFFF43F5E);
      activeBorder = const Color(0xFFBE123C);
    }

    return GestureDetector(
      onTap: () => onSelectTool(tool),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeBorder : AppColors.outline,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeBorder.withValues(alpha: 0.25),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Tools: Bút, Đổ Màu, Cục Tẩy
        Row(
          children: [
            _buildToolButton(
              tool: DrawingTool.pen,
              icon: Icons.edit_rounded,
              label: 'Bút vẽ',
            ),
            const SizedBox(width: 6),
            _buildToolButton(
              tool: DrawingTool.bucket,
              icon: Icons.format_color_fill_rounded,
              label: 'Đổ màu',
            ),
            const SizedBox(width: 6),
            _buildToolButton(
              tool: DrawingTool.eraser,
              icon: Icons.auto_fix_normal_rounded,
              label: 'Cục Tẩy',
            ),
          ],
        ),

        // Actions: Undo, Clear
        Row(
          children: [
            ChunkyIconButton(
              onPressed: onUndo,
              size: 34,
              borderDepth: 2,
              backgroundColor: AppColors.surfaceContainer,
              borderColor: AppColors.surfaceDim,
              icon: const Icon(
                Icons.undo_rounded,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 6),
            ChunkyIconButton(
              onPressed: onClear,
              size: 34,
              borderDepth: 2,
              backgroundColor: AppColors.surfaceContainer,
              borderColor: AppColors.surfaceDim,
              icon: const Icon(
                Icons.restart_alt_rounded,
                size: 16,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
