import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';
import '../utils/sketch_dragon_painter.dart';
import 'drawing_toolbar.dart';

/// 🎨 Khu vực khung vẽ cảm ứng (Canvas Area) với RepaintBoundary & CustomPaint
class DrawingCanvasArea extends StatelessWidget {
  final GlobalKey canvasKey;
  final double canvasHeight;
  final DrawingTool currentTool;
  final List<List<DrawingPoint>> strokeLines;
  final ui.Image? fillImage;
  final void Function(Offset localPos, Size size) onBucketTap;
  final void Function(Offset localPos, Size size) onPanStart;
  final void Function(Offset localPos, Size size) onPanUpdate;

  const DrawingCanvasArea({
    super.key,
    required this.canvasKey,
    required this.canvasHeight,
    required this.currentTool,
    required this.strokeLines,
    required this.fillImage,
    required this.onBucketTap,
    required this.onPanStart,
    required this.onPanUpdate,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppColors.outlineVariant.withValues(alpha: 0.4);
    if (currentTool == DrawingTool.bucket) {
      borderColor = AppColors.secondary.withValues(alpha: 0.6);
    } else if (currentTool == DrawingTool.eraser) {
      borderColor = const Color(0xFFF43F5E).withValues(alpha: 0.6);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: canvasHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

            return Stack(
              children: [
                ClipRect(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) {
                      if (currentTool == DrawingTool.bucket) {
                        onBucketTap(details.localPosition, canvasSize);
                      }
                    },
                    onPanStart: (details) {
                      if (currentTool != DrawingTool.bucket) {
                        onPanStart(details.localPosition, canvasSize);
                      }
                    },
                    onPanUpdate: (details) {
                      if (currentTool != DrawingTool.bucket) {
                        onPanUpdate(details.localPosition, canvasSize);
                      }
                    },
                    child: RepaintBoundary(
                      key: canvasKey,
                      child: CustomPaint(
                        painter: SketchDragonPainter(
                          strokeLines,
                          fillImage: fillImage,
                        ),
                        size: canvasSize,
                      ),
                    ),
                  ),
                ),

                // Tool state floating badge at bottom-left
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest.withValues(
                          alpha: 0.95,
                        ),
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            currentTool == DrawingTool.bucket
                                ? Icons.format_color_fill_rounded
                                : (currentTool == DrawingTool.eraser
                                    ? Icons.auto_fix_normal_rounded
                                    : Icons.edit_rounded),
                            size: 14,
                            color: currentTool == DrawingTool.bucket
                                ? AppColors.secondary
                                : (currentTool == DrawingTool.eraser
                                    ? const Color(0xFFF43F5E)
                                    : AppColors.primary),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            currentTool == DrawingTool.bucket
                                ? 'Chạm để Đổ Màu'
                                : (currentTool == DrawingTool.eraser
                                    ? 'Vuốt để Xóa Nét'
                                    : 'Đang vẽ nét (${strokeLines.length} nét)'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: currentTool == DrawingTool.bucket
                                  ? AppColors.secondary
                                  : (currentTool == DrawingTool.eraser
                                      ? const Color(0xFFF43F5E)
                                      : AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

