import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../app_loading.dart';
import '../character_cutout_image.dart';

/// 16:9 Story Stage chuan hoa 100% theo Content Manager (CM - StoryPageRenderer.jsx):
/// - Tranh minh hoa 16:9 phu kin toan bo san khau.
/// - Cac slot nhan vat duoc dat dung vi tri (posX, posY), kich thuoc (scale), goc xoay (rotation), do mo (opacity) do CM quy dinh.
/// - Dong bo hoa: Chi hien thi nhan vat va phu de khi tranh nen da load hoan tat (tranh lo lung nhan vat khi chuyen trang).
/// - Hien thi phu de va thuong hieu SKETCHTALE truc tiep tren canvas o phia duoi giong het CM web.
class StoryCanvasView extends StatefulWidget {
  final String imageUrl;
  final String chapterTitle;
  final String category;
  final String? subtitleText;
  final List<StoryStageSlotItem> stageSlots;
  final KidCharacter? heroCharacter;

  const StoryCanvasView({
    super.key,
    required this.imageUrl,
    required this.chapterTitle,
    this.category = '',
    this.subtitleText,
    this.stageSlots = const [],
    this.heroCharacter,
  });

  @override
  State<StoryCanvasView> createState() => _StoryCanvasViewState();
}

class _StoryCanvasViewState extends State<StoryCanvasView> {
  bool _isBackgroundReady = false;

  @override
  void initState() {
    super.initState();
    _checkInitialAssetBackground();
  }

  @override
  void didUpdateWidget(covariant StoryCanvasView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _isBackgroundReady = false;
      _checkInitialAssetBackground();
    }
  }

  void _checkInitialAssetBackground() {
    final cleanUrl = widget.imageUrl.trim();
    if (cleanUrl.isEmpty ||
        cleanUrl.toLowerCase() == 'string' ||
        cleanUrl.toLowerCase().endsWith('/string') ||
        cleanUrl.toLowerCase() == 'null' ||
        cleanUrl.startsWith('assets/')) {
      _isBackgroundReady = true;
    }
  }

  void _onBackgroundFrameLoaded() {
    if (!_isBackgroundReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isBackgroundReady) {
          setState(() {
            _isBackgroundReady = true;
          });
        }
      });
    }
  }

  Widget _buildBackgroundArt() {
    final cleanUrl = widget.imageUrl.trim();
    final isInvalid = cleanUrl.isEmpty ||
        cleanUrl.toLowerCase() == 'string' ||
        cleanUrl.toLowerCase().endsWith('/string') ||
        cleanUrl.toLowerCase() == 'null';

    if (isInvalid) {
      return Image.asset(
        'assets/images/Br.png',
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _missingBackgroundFallback(),
      );
    }
    if (cleanUrl.startsWith('assets/')) {
      return Image.asset(
        cleanUrl,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSync) {
          if (wasSync || frame != null) {
            _onBackgroundFrameLoaded();
          }
          return child;
        },
        errorBuilder: (_, _, _) => Image.asset(
          'assets/images/Br.png',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _missingBackgroundFallback(),
        ),
      );
    }
    return Image.network(
      cleanUrl,
      fit: BoxFit.cover,
      loadingBuilder: appImageLoadingBuilder,
      frameBuilder: (context, child, frame, wasSync) {
        if (wasSync || frame != null) {
          _onBackgroundFrameLoaded();
        }
        return child;
      },
      errorBuilder: (_, _, _) => Image.asset(
        'assets/images/Br.png',
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _missingBackgroundFallback(),
      ),
    );
  }

  Widget _missingBackgroundFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDCE8D8), Color(0xFFB8D4C8)],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.auto_stories_rounded,
          color: Colors.white70,
          size: 48,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedSlots = List<StoryStageSlotItem>.from(widget.stageSlots)
      ..sort((a, b) => a.slot.layer.compareTo(b.slot.layer));

    final rawSub = widget.subtitleText?.trim() ?? '';
    final effectiveSubtitle = (rawSub.isNotEmpty &&
            rawSub.toLowerCase() != 'string' &&
            rawSub.toLowerCase() != 'null')
        ? rawSub
        : '';
    final hasSubtitle = effectiveSubtitle.isNotEmpty;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x28000000),
                  offset: Offset(0, 8),
                  blurRadius: 20,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final stageSize = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );

                  return Stack(
                    children: [
                      // 1. Tranh minh hoa 16:9 goc do Content Manager thiet lap
                      Positioned.fill(child: _buildBackgroundArt()),

                      // 2. Character Layer: Chi hien thi khi anh nen da ve xong de khong bi tro lo lung
                      AnimatedOpacity(
                        opacity: _isBackgroundReady ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOut,
                        child: Stack(
                          children: [
                            if (sortedSlots.isNotEmpty)
                              for (final item in sortedSlots)
                                _StageSlotActorWidget(
                                  key: ValueKey('cm-slot-${item.slot.id}'),
                                  item: item,
                                  stageSize: stageSize,
                                )
                            else if (widget.heroCharacter != null &&
                                widget.heroCharacter!.avatarAsset.isNotEmpty)
                              Positioned(
                                left: stageSize.width * 0.5 - 60,
                                top: stageSize.height * 0.5 - 60,
                                width: 120,
                                height: 120,
                                child: CharacterCutoutImage(
                                  imageUrl: widget.heroCharacter!.avatarAsset,
                                  fit: BoxFit.contain,
                                ),
                              ),

                            // 3. Lop phu gradient mem o day canvas de phu de de doc tren moi nen anh
                            if (hasSubtitle)
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                height: stageSize.height * 0.42,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.72),
                                        Colors.black.withValues(alpha: 0.35),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                            // 4. Stage Copy: Thuong hieu SKETCHTALE va Phu de / Loi dan chuyen giong het CM
                            if (hasSubtitle)
                              Positioned(
                                left: 20,
                                right: 20,
                                bottom: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.category.isNotEmpty
                                          ? 'SKETCHTALE · ${widget.category.toUpperCase()}'
                                          : 'SKETCHTALE',
                                      style: const TextStyle(
                                        color: Color(0xFFFFE6A2),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black,
                                            offset: Offset(0, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      effectiveSubtitle,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFFF2F4F1),
                                        fontSize: 13,
                                        height: 1.4,
                                        fontWeight: FontWeight.w500,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black,
                                            offset: Offset(0, 1),
                                            blurRadius: 3,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // 5. Chapter title / Page badge o goc tren ben trai
                            Positioned(
                              top: 10,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.45),
                                  borderRadius: BorderRadius.circular(9999),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFFE6A2),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      widget.chapterTitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Hien thi nhan vat vao dung slot 0..100% cua Content Manager (CM):
/// - Tinh toan vi tri chinh xac theo toa do % cua CM (StoryPageRenderer.jsx)
/// - Ap dung dung scale, anchor, goc xoay va lat ngang (flip)
/// - Hoan toan la phep bien doi 2D sach se, khong lam bien dang 3D perspective
class _StageSlotActorWidget extends StatelessWidget {
  final StoryStageSlotItem item;
  final Size stageSize;

  const _StageSlotActorWidget({
    super.key,
    required this.item,
    required this.stageSize,
  });

  @override
  Widget build(BuildContext context) {
    final rect = item.renderState.computeStageRect(
      stageSize,
      anchor: item.slot.anchor,
      baseWidthPercent: 24.0,
    );

    final rotZ = item.renderState.rotation * math.pi / 180.0;

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: Opacity(
        opacity: item.renderState.opacity.clamp(0.0, 1.0),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(item.flipHorizontal ? -1.0 : 1.0, 1.0),
          child: Transform.rotate(
            angle: rotZ,
            alignment: Alignment.center,
            child: CharacterCutoutImage(
              imageUrl: item.imageUrl,
              fallbackAssetPath: item.fallbackAssetPath,
              fit: BoxFit.contain,
              errorFallbackBuilder: () => const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}
