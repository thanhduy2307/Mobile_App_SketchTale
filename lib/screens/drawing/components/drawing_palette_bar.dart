import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../drawing_styles.dart';
import 'drawing_toolbar.dart';

/// 🎨 Thanh chọn màu sắc (14 viên kẹo) và kích thước cọ/tẩy
class DrawingPaletteBar extends StatelessWidget {
  final DrawingTool currentTool;
  final int selectedColorIndex;
  final double brushSize;
  final double eraserSize;
  final ValueChanged<int> onSelectColor;
  final ValueChanged<double> onSelectBrushSize;
  final ValueChanged<double> onSelectEraserSize;

  const DrawingPaletteBar({
    super.key,
    required this.currentTool,
    required this.selectedColorIndex,
    required this.brushSize,
    required this.eraserSize,
    required this.onSelectColor,
    required this.onSelectBrushSize,
    required this.onSelectEraserSize,
  });

  Widget _buildColorCircle(int index) {
    if (index >= DrawingStyles.paletteColors.length) return const SizedBox.shrink();
    final color = DrawingStyles.paletteColors[index];
    final isSelected =
        (currentTool != DrawingTool.eraser && selectedColorIndex == index);

    return GestureDetector(
      onTap: () => onSelectColor(index),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Colors.white, width: 3)
              : Border.all(color: Colors.black12, width: 1.5),
          boxShadow: [
            if (isSelected)
              const BoxShadow(
                color: Colors.black45,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
          ],
        ),
        child: isSelected
            ? const Center(
                child: Icon(Icons.check_rounded, color: Colors.white, size: 18),
              )
            : null,
      ),
    );
  }

  Widget _buildBrushSizeChip(String label, double size) {
    final isSelected = (brushSize == size && currentTool != DrawingTool.eraser);
    return GestureDetector(
      onTap: () => onSelectBrushSize(size),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildEraserSizeChip(String label, double size) {
    final isSelected = (eraserSize == size && currentTool == DrawingTool.eraser);
    return GestureDetector(
      onTap: () => onSelectEraserSize(size),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFF43F5E)
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Danh sách 14 màu kẹo ngọt cuộn ngang
        SizedBox(
          height: 42,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: DrawingStyles.paletteColors.length,
            itemBuilder: (_, idx) => _buildColorCircle(idx),
          ),
        ),

        const SizedBox(height: 8),

        // Chọn độ dày nét bút hoặc kích thước cục tẩy
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              currentTool == DrawingTool.eraser
                  ? 'Kích thước tẩy:'
                  : 'Độ dày nét bút:',
              style: AppTypography.labelSm(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            if (currentTool == DrawingTool.eraser)
              Row(
                children: [
                  _buildEraserSizeChip('Nhỏ', 14.0),
                  const SizedBox(width: 6),
                  _buildEraserSizeChip('Vừa', 28.0),
                  const SizedBox(width: 6),
                  _buildEraserSizeChip('Lớn', 46.0),
                ],
              )
            else
              Row(
                children: [
                  _buildBrushSizeChip('Mảnh', 3.5),
                  const SizedBox(width: 6),
                  _buildBrushSizeChip('Vừa', 6.0),
                  const SizedBox(width: 6),
                  _buildBrushSizeChip('Đậm', 12.0),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

