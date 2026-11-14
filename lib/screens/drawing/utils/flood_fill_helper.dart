import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../models/models.dart';

/// 🪣 Thuật toán đổ màu nhanh (BFS Flood Fill Scanline) cho Canvas trẻ em
class FloodFillHelper {
  static Future<ui.Image?> performFloodFill({
    required Offset tapPos,
    required Size size,
    required Color fillColor,
    required List<List<DrawingPoint>> strokeLines,
    ui.Image? currentFillImage,
  }) async {
    final width = size.width.toInt();
    final height = size.height.toInt();
    if (width <= 0 || height <= 0) return null;

    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Nền trắng tinh
      canvas.drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        Paint()..color = const Color(0xFFFFFFFF),
      );

      // Các mảng màu đã đổ trước đó
      if (currentFillImage != null) {
        canvas.drawImage(currentFillImage, Offset.zero, Paint());
      }

      // Các nét vẽ hiện tại
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

      final picture = recorder.endRecording();
      final img = await picture.toImage(width, height);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) return null;

      final uint8List = byteData.buffer.asUint8List();
      final uint32List = byteData.buffer.asUint32List();

      final startX = tapPos.dx.toInt().clamp(0, width - 1);
      final startY = tapPos.dy.toInt().clamp(0, height - 1);
      final startIdx = startY * width + startX;

      final targetPixel = uint32List[startIdx];
      final argb = fillColor.toARGB32();
      final r = (argb >> 16) & 0xFF;
      final g = (argb >> 8) & 0xFF;
      final b = argb & 0xFF;
      final newPixel = (0xFF << 24) | (b << 16) | (g << 8) | r;

      if (targetPixel == newPixel) return null;

      final tr = targetPixel & 0xFF;
      final tg = (targetPixel >> 8) & 0xFF;
      final tb = (targetPixel >> 16) & 0xFF;
      final targetLum = (tr * 299 + tg * 587 + tb * 114) ~/ 1000;

      bool canFill(int pixel) {
        if (pixel == newPixel) return false;
        final pr = pixel & 0xFF;
        final pg = (pixel >> 8) & 0xFF;
        final pb = (pixel >> 16) & 0xFF;
        final lum = (pr * 299 + pg * 587 + pb * 114) ~/ 1000;

        if (targetLum > 160 && lum < 110) return false;
        if (targetLum < 90 && lum > 160) return false;

        final dr = (pr - tr).abs();
        final dg = (pg - tg).abs();
        final db = (pb - tb).abs();
        return (dr + dg + db) < 70;
      }

      final visited = Uint8List(width * height);
      final queue = Int32List(width * height);
      int head = 0;
      int tail = 0;

      queue[tail++] = startIdx;
      visited[startIdx] = 1;

      while (head < tail) {
        final curr = queue[head++];
        uint32List[curr] = newPixel;

        final cx = curr % width;
        final cy = curr ~/ width;

        if (cx > 0) {
          final n = curr - 1;
          if (visited[n] == 0 && canFill(uint32List[n])) {
            visited[n] = 1;
            queue[tail++] = n;
          }
        }
        if (cx < width - 1) {
          final n = curr + 1;
          if (visited[n] == 0 && canFill(uint32List[n])) {
            visited[n] = 1;
            queue[tail++] = n;
          }
        }
        if (cy > 0) {
          final n = curr - width;
          if (visited[n] == 0 && canFill(uint32List[n])) {
            visited[n] = 1;
            queue[tail++] = n;
          }
        }
        if (cy < height - 1) {
          final n = curr + width;
          if (visited[n] == 0 && canFill(uint32List[n])) {
            visited[n] = 1;
            queue[tail++] = n;
          }
        }
      }

      final completer = Completer<ui.Image>();
      ui.decodeImageFromPixels(
        uint8List,
        width,
        height,
        ui.PixelFormat.rgba8888,
        (ui.Image result) => completer.complete(result),
      );
      return completer.future;
    } catch (e) {
      debugPrint('[FloodFillHelper] Lỗi đổ màu: $e');
      return null;
    }
  }
}

