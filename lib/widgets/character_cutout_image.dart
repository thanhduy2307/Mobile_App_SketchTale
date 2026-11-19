import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'app_loading.dart';

/// Widget hien thi nhan vat da duoc tu dong tach nen (Background Removal / Cutout)
/// Su dung thuat toan Flood-Fill tu 4 canh bien ket hop lam mem vien (Edge Feathering)
/// de loai bo nen trang hoac nen don sac/gradient nhe quanh nhan vat ma van giu nguyen
/// cac chi tiet mau trang ben trong co the nhan vat (nhu mat, rang, trang phuc).
class CharacterCutoutImage extends StatefulWidget {
  final String imageUrl;
  final String? fallbackAssetPath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function()? errorFallbackBuilder;

  const CharacterCutoutImage({
    super.key,
    required this.imageUrl,
    this.fallbackAssetPath,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.errorFallbackBuilder,
  });

  /// Bo nho dem luu anh da tach nen theo URL de khong phai tinh toan lai khi chuyen trang hay chay animation
  static final Map<String, ui.Image> _cutoutCache = {};
  static final Map<String, Future<ui.Image?>> _inFlight = {};

  /// Xoa bo nho dem neu can lam moi
  static void clearCache() {
    _cutoutCache.clear();
    _inFlight.clear();
  }

  /// Thuat toan tach nen Flood-Fill tren mang byte RGBA (4 bytes/pixel: R, G, B, A).
  /// Tra ve true neu anh co nen dac va da duoc tach thanh trong suot,
  /// tra ve false neu anh da trong suot san hoac khong can xu ly.
  static bool removeBackgroundFromRgba(
    Uint8List rgba,
    int width,
    int height, {
    int colorTolerance = 48,
    int stepTolerance = 26,
  }) {
    if (width <= 2 || height <= 2 || rgba.length < width * height * 4) {
      return false;
    }

    int alphaAt(int x, int y) => rgba[(y * width + x) * 4 + 3];

    // 1. Kiem tra 4 goc anh: neu ca 4 goc deu da trong suot (alpha < 24) thi anh da duoc tach nen san
    final a00 = alphaAt(0, 0);
    final a10 = alphaAt(width - 1, 0);
    final a01 = alphaAt(0, height - 1);
    final a11 = alphaAt(width - 1, height - 1);
    if (a00 < 24 && a10 < 24 && a01 < 24 && a11 < 24) {
      return false;
    }

    // 2. Thu thap cac mau nen tu 4 goc anh truoc, sau do kiem tra trung diem 4 canh
    final cornerCoords = <List<int>>[
      [0, 0],
      [width - 1, 0],
      [0, height - 1],
      [width - 1, height - 1],
    ];
    final midCoords = <List<int>>[
      [width ~/ 2, 0],
      [width ~/ 2, height - 1],
      [0, height ~/ 2],
      [width - 1, height ~/ 2],
    ];

    final bgSamples = <List<int>>[];
    for (final pt in cornerCoords) {
      final idx = (pt[1] * width + pt[0]) * 4;
      final a = rgba[idx + 3];
      if (a >= 180) {
        bgSamples.add([rgba[idx], rgba[idx + 1], rgba[idx + 2]]);
      }
    }

    // Chi them mau tai trung diem canh neu mau do tuong dong voi it nhat 1 goc
    // (tranh truong hop chan/dau nhan vat cham sat giua khung hinh)
    for (final pt in midCoords) {
      final idx = (pt[1] * width + pt[0]) * 4;
      final a = rgba[idx + 3];
      if (a >= 180) {
        final mr = rgba[idx];
        final mg = rgba[idx + 1];
        final mb = rgba[idx + 2];
        final closeToCorner = bgSamples.any((c) =>
            (mr - c[0]).abs() <= colorTolerance &&
            (mg - c[1]).abs() <= colorTolerance &&
            (mb - c[2]).abs() <= colorTolerance);
        if (closeToCorner) {
          bgSamples.add([mr, mg, mb]);
        }
      }
    }

    if (bgSamples.isEmpty) {
      return false;
    }

    bool matchesBackgroundSample(int r, int g, int b) {
      // Nen trang tinh khiet do AI sinh ra ("isolated on a pure solid white background")
      if (r >= 238 && g >= 238 && b >= 238) {
        return true;
      }
      for (var i = 0; i < bgSamples.length; i++) {
        final s = bgSamples[i];
        final dr = (r - s[0]).abs();
        final dg = (g - s[1]).abs();
        final db = (b - s[2]).abs();
        if (dr <= colorTolerance &&
            dg <= colorTolerance &&
            db <= colorTolerance &&
            (dr + dg + db) <= colorTolerance * 2.2) {
          return true;
        }
      }
      return false;
    }

    final totalPixels = width * height;
    final visited = Uint8List(totalPixels);
    final queue = Int32List(totalPixels);
    var head = 0;
    var tail = 0;

    void tryEnqueueBorder(int x, int y) {
      final pIdx = y * width + x;
      if (visited[pIdx] != 0) return;
      final bIdx = pIdx * 4;
      final a = rgba[bIdx + 3];
      if (a < 25) {
        visited[pIdx] = 1;
        queue[tail++] = pIdx;
        return;
      }
      final r = rgba[bIdx];
      final g = rgba[bIdx + 1];
      final b = rgba[bIdx + 2];
      if (matchesBackgroundSample(r, g, b)) {
        visited[pIdx] = 1;
        queue[tail++] = pIdx;
      }
    }

    // 3. Khoi tao hang doi Flood-Fill tu toan bo 4 canh vien cua anh
    for (var x = 0; x < width; x++) {
      tryEnqueueBorder(x, 0);
      tryEnqueueBorder(x, height - 1);
    }
    for (var y = 1; y < height - 1; y++) {
      tryEnqueueBorder(0, y);
      tryEnqueueBorder(width - 1, y);
    }

    if (tail == 0) {
      return false;
    }

    // 4. Loang (BFS) tu bien vao trong de xoa toan bo vung nen bao quanh nhan vat
    while (head < tail) {
      final pIdx = queue[head++];
      final bIdx = pIdx * 4;
      final curR = rgba[bIdx];
      final curG = rgba[bIdx + 1];
      final curB = rgba[bIdx + 2];

      final x = pIdx % width;
      final y = pIdx ~/ width;

      void checkNeighbor(int nx, int ny) {
        final nIdx = ny * width + nx;
        if (visited[nIdx] != 0) return;
        final nbIdx = nIdx * 4;
        final na = rgba[nbIdx + 3];
        if (na < 25) {
          visited[nIdx] = 1;
          queue[tail++] = nIdx;
          return;
        }
        final nr = rgba[nbIdx];
        final ng = rgba[nbIdx + 1];
        final nb = rgba[nbIdx + 2];

        final stepDiff =
            (nr - curR).abs() + (ng - curG).abs() + (nb - curB).abs();
        if (stepDiff <= stepTolerance * 2 &&
            matchesBackgroundSample(nr, ng, nb)) {
          visited[nIdx] = 1;
          queue[tail++] = nIdx;
        }
      }

      if (x > 0) checkNeighbor(x - 1, y);
      if (x < width - 1) checkNeighbor(x + 1, y);
      if (y > 0) checkNeighbor(x, y - 1);
      if (y < height - 1) checkNeighbor(x, y + 1);
    }

    // 5. Xoa alpha cua tat ca pixel nen da duyet qua
    for (var i = 0; i < totalPixels; i++) {
      if (visited[i] == 1) {
        rgba[i * 4 + 3] = 0;
      }
    }

    // 6. Lam mem vien (Edge Feathering / Anti-Aliasing) cho cac pixel sat ranh gioi nen
    for (var y = 1; y < height - 1; y++) {
      for (var x = 1; x < width - 1; x++) {
        final pIdx = y * width + x;
        if (visited[pIdx] != 0) continue;

        var emptyNeighbors = 0;
        if (visited[pIdx - 1] == 1) emptyNeighbors++;
        if (visited[pIdx + 1] == 1) emptyNeighbors++;
        if (visited[pIdx - width] == 1) emptyNeighbors++;
        if (visited[pIdx + width] == 1) emptyNeighbors++;

        if (emptyNeighbors > 0) {
          final bIdx = pIdx * 4;
          final r = rgba[bIdx];
          final g = rgba[bIdx + 1];
          final b = rgba[bIdx + 2];
          final a = rgba[bIdx + 3];

          // Neu pixel sat bien co mau kha gan mau nen (do anti-aliasing), giam alpha de vien muot ma
          if (matchesBackgroundSample(r, g, b) ||
              (r > 220 && g > 220 && b > 220)) {
            rgba[bIdx + 3] = (a * 0.25).round();
          } else {
            final factor = math.max(0.55, 1.0 - emptyNeighbors * 0.12);
            rgba[bIdx + 3] = (a * factor).round();
          }
        }
      }
    }

    return true;
  }

  @override
  State<CharacterCutoutImage> createState() => _CharacterCutoutImageState();
}

class _CharacterCutoutImageState extends State<CharacterCutoutImage> {
  ui.Image? _cutoutImage;
  bool _failedPrimary = false;
  ImageStream? _activeStream;
  ImageStreamListener? _activeListener;

  String get _effectiveSource {
    if (!_failedPrimary && widget.imageUrl.isNotEmpty) {
      return widget.imageUrl;
    }
    return widget.fallbackAssetPath ?? '';
  }

  @override
  void initState() {
    super.initState();
    _resolveCutout();
  }

  @override
  void didUpdateWidget(covariant CharacterCutoutImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.fallbackAssetPath != widget.fallbackAssetPath) {
      _cleanupStream();
      _failedPrimary = false;
      _cutoutImage = null;
      _resolveCutout();
    }
  }

  @override
  void dispose() {
    _cleanupStream();
    super.dispose();
  }

  void _cleanupStream() {
    if (_activeStream != null && _activeListener != null) {
      _activeStream!.removeListener(_activeListener!);
    }
    _activeStream = null;
    _activeListener = null;
  }

  Future<void> _resolveCutout() async {
    final src = _effectiveSource;
    if (src.isEmpty) return;

    final cached = CharacterCutoutImage._cutoutCache[src];
    if (cached != null) {
      if (mounted) {
        setState(() => _cutoutImage = cached);
      }
      return;
    }

    final future = CharacterCutoutImage._inFlight.putIfAbsent(
      src,
      () => _loadAndCutoutImage(src),
    );

    final result = await future;
    CharacterCutoutImage._inFlight.remove(src);

    if (!mounted) return;
    if (result != null) {
      setState(() => _cutoutImage = result);
    } else if (!_failedPrimary &&
        widget.fallbackAssetPath != null &&
        widget.fallbackAssetPath!.isNotEmpty &&
        widget.fallbackAssetPath != widget.imageUrl) {
      setState(() => _failedPrimary = true);
      _resolveCutout();
    }
  }

  /// Ma tran mau loai bo nen trang tinh/sang mau cua anh AI tren Web khi gap CORS canvas taint
  static const List<double> _removeWhiteColorMatrix = <double>[
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    -3, -3, -3, 0, 2150,
  ];

  Future<ui.Image?> _decodeRawImage(String src) async {
    // Doi voi URL mang (dac biet tren Flutter Web), tai byte truc tiep qua http.get
    // de ui.instantiateImageCodec giai ma trong bo nho Dart, tranh loi CORS canvas taint khi goi toByteData.
    if (src.startsWith('http://') || src.startsWith('https://')) {
      try {
        final response = await http.get(Uri.parse(src));
        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          final codec = await ui.instantiateImageCodec(response.bodyBytes);
          final frame = await codec.getNextFrame();
          return frame.image;
        }
      } catch (_) {
        if (kIsWeb) {
          try {
            final proxy = 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(src)}';
            final proxyRes = await http.get(Uri.parse(proxy));
            if (proxyRes.statusCode == 200 && proxyRes.bodyBytes.isNotEmpty) {
              final codec = await ui.instantiateImageCodec(proxyRes.bodyBytes);
              final frame = await codec.getNextFrame();
              return frame.image;
            }
          } catch (_) {}
        }
      }
    }

    final ImageProvider provider = src.startsWith('assets/')
        ? AssetImage(src)
        : NetworkImage(src) as ImageProvider;

    final completer = Completer<ui.Image>();
    final stream = provider.resolve(ImageConfiguration.empty);
    late ImageStreamListener listener;

    listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        stream.removeListener(listener);
        if (identical(_activeStream, stream)) {
          _activeStream = null;
          _activeListener = null;
        }
        if (!completer.isCompleted) {
          completer.complete(info.image);
        }
      },
      onError: (Object error, StackTrace? stackTrace) {
        stream.removeListener(listener);
        if (identical(_activeStream, stream)) {
          _activeStream = null;
          _activeListener = null;
        }
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      },
    );

    _activeStream = stream;
    _activeListener = listener;
    stream.addListener(listener);
    return completer.future;
  }

  Future<ui.Image?> _loadAndCutoutImage(String src) async {
    try {
      final rawImage = await _decodeRawImage(src);
      if (rawImage == null) return null;

      final byteData = await rawImage.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (byteData == null) {
        CharacterCutoutImage._cutoutCache[src] = rawImage;
        return rawImage;
      }

      final pixels = Uint8List.fromList(byteData.buffer.asUint8List());
      final modified = CharacterCutoutImage.removeBackgroundFromRgba(
        pixels,
        rawImage.width,
        rawImage.height,
      );

      if (!modified) {
        CharacterCutoutImage._cutoutCache[src] = rawImage;
        return rawImage;
      }

      final cutoutCompleter = Completer<ui.Image>();
      ui.decodeImageFromPixels(
        pixels,
        rawImage.width,
        rawImage.height,
        ui.PixelFormat.rgba8888,
        (ui.Image processed) {
          if (!cutoutCompleter.isCompleted) {
            cutoutCompleter.complete(processed);
          }
        },
      );

      final finalImg = await cutoutCompleter.future;
      CharacterCutoutImage._cutoutCache[src] = finalImg;
      return finalImg;
    } catch (_) {
      return null;
    }
  }

  Widget _buildStandardImage(String src, {Widget Function()? onError}) {
    if (src.startsWith('assets/')) {
      return Image.asset(
        src,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (_, _, _) => onError != null
            ? onError()
            : (widget.errorFallbackBuilder?.call() ?? const SizedBox.shrink()),
      );
    }
    return Image.network(
      src,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      // Giu trong suot hoan toan trong luc dang tai anh tu mang, khong hien bat ky khung trang hay loader nao
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const SizedBox.shrink();
      },
      errorBuilder: (_, _, _) => onError != null
          ? onError()
          : (widget.errorFallbackBuilder?.call() ?? const SizedBox.shrink()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cutoutImage != null) {
      return RawImage(
        image: _cutoutImage,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        filterQuality: FilterQuality.medium,
      );
    }

    final primary = widget.imageUrl;
    final fallback = widget.fallbackAssetPath;

    Widget child;
    if (primary.isEmpty) {
      if (fallback != null && fallback.isNotEmpty) {
        child = _buildStandardImage(fallback);
      } else {
        return const SizedBox.shrink();
      }
    } else {
      child = _buildStandardImage(
        primary,
        onError: () {
          if (fallback != null && fallback.isNotEmpty && fallback != primary) {
            return _buildStandardImage(fallback);
          }
          return const SizedBox.shrink();
        },
      );
    }

    return child;
  }
}
