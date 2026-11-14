import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../models/models.dart';

/// 🎨 Custom painter vẽ các nét vẽ tay và mảng màu đổ (flood fill) của bé
class SketchDragonPainter extends CustomPainter {
  final List<List<DrawingPoint>> strokeLines;
  final ui.Image? fillImage;

  SketchDragonPainter(this.strokeLines, {this.fillImage});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);

    if (fillImage != null) {
      canvas.drawImage(fillImage!, Offset.zero, Paint());
    }

    for (final line in strokeLines) {
      if (line.isEmpty) continue;
      if (line.length == 1) {
        canvas.drawCircle(
          line[0].offset,
          line[0].paint.strokeWidth / 2,
          Paint()
            ..color = line[0].paint.color
            ..style = PaintingStyle.fill,
        );
      } else {
        for (int i = 0; i < line.length - 1; i++) {
          canvas.drawLine(line[i].offset, line[i + 1].offset, line[i].paint);
        }
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SketchDragonPainter oldDelegate) => true;
}

