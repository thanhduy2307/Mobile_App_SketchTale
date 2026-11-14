import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../app_loading.dart';
import '../squash_stretch_character.dart';
import 'story_firefly_painter.dart';

/// Interactive 16:9 Story Stage matching Content Manager Web Studio (`StoryPageRenderer.jsx`):
/// - Percentage-based CM slot placement (`posX: 0..100%`, `posY: 0..100%`, `width: 24% * scale`, `anchor: center`)
/// - Smooth evaluation of CM animation clips (`appear`, `move`, `jump`, `spin`, `walk`, `keyframes`, `path`)
/// - Fallback to single `SquashStretchCharacter` for legacy local playground stories without CM slots
class StoryCanvasView extends StatelessWidget {
  final double screenShakeOffset;
  final String imageUrl;
  final List<FireflyParticle> particles;
  final String chapterTitle;
  final KidCharacter? heroCharacter;
  final String? activeRoleName;
  final String? characterSpeech;
  final Offset characterPosition;
  final bool flipHorizontal;
  final double characterScale;
  final AnimationMode animationMode;
  final CharacterAction characterAction;
  final CharacterAction? manualToyAction;
  final List<StoryStageSlotItem> stageSlots;
  final bool isPlayingTimeline;
  final VoidCallback onScreenShake;
  final ValueChanged<Offset> onPositionChanged;
  final ValueChanged<Offset> onDragEndPosition;
  final void Function(String slotId, Offset newPercentPos)?
  onSlotPercentChanged;
  final ValueChanged<CharacterAction> onActionChanged;
  final VoidCallback onTapSparkles;
  final VoidCallback? onOpenAnimationControls;
  final VoidCallback? onReplayMotion;

  /// Ẩn nhóm badge theo yêu cầu (Ảnh 2)
  static const bool showCanvasBadges = false;

  const StoryCanvasView({
    super.key,
    required this.screenShakeOffset,
    required this.imageUrl,
    required this.particles,
    required this.chapterTitle,
    this.heroCharacter,
    this.activeRoleName,
    this.characterSpeech,
    required this.characterPosition,
    required this.flipHorizontal,
    required this.characterScale,
    required this.animationMode,
    required this.characterAction,
    this.manualToyAction,
    this.stageSlots = const [],
    this.isPlayingTimeline = false,
    required this.onScreenShake,
    required this.onPositionChanged,
    required this.onDragEndPosition,
    this.onSlotPercentChanged,
    required this.onActionChanged,
    required this.onTapSparkles,
    this.onOpenAnimationControls,
    this.onReplayMotion,
  });

  Widget _buildBackgroundArt() {
    if (imageUrl.isEmpty) {
      return _missingBackgroundFallback();
    }
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _missingBackgroundFallback(),
      );
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: appImageLoadingBuilder,
      errorBuilder: (_, _, _) => _missingBackgroundFallback(),
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
    final sortedSlots = List<StoryStageSlotItem>.from(stageSlots)
      ..sort((a, b) => a.slot.layer.compareTo(b.slot.layer));

    final badgeCharacterName =
        activeRoleName ??
        (sortedSlots.isNotEmpty ? sortedSlots.first.displayName : null) ??
        heroCharacter?.name ??
        'Bạn Nhỏ';

    return Transform.translate(
      offset: Offset(screenShakeOffset, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFDCE8D8),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x28006398),
                    offset: Offset(0, 8),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final stageSize = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );

                    return Stack(
                      children: [
                        // 1. Story 16:9 background art
                        Positioned.fill(child: _buildBackgroundArt()),

                        // 2. Subtle ambient vignette matching Web Studio stage
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.14),
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.34),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 3. Flying firefly particles
                        IgnorePointer(
                          child: CustomPaint(
                            painter: FireflyCanvasPainter(particles),
                            size: Size.infinite,
                          ),
                        ),

                        // 4. Character Layer: CM Percentage Slots OR Legacy Playground Character
                        if (sortedSlots.isNotEmpty)
                          for (final item in sortedSlots)
                            _StageSlotActorWidget(
                              key: ValueKey('cm-slot-${item.slot.id}'),
                              item: item,
                              stageSize: stageSize,
                              isPlayingTimeline: isPlayingTimeline,
                              manualToyAction: manualToyAction,
                              animationMode: animationMode,
                              onScreenShake: onScreenShake,
                              onTapSparkles: onTapSparkles,
                              onDoubleTapReplay: onReplayMotion,
                              onPercentChanged: onSlotPercentChanged != null
                                  ? (pos) =>
                                        onSlotPercentChanged!(item.slot.id, pos)
                                  : null,
                            )
                        else if (heroCharacter != null &&
                            heroCharacter!.avatar3dUrl.isNotEmpty)
                          SquashStretchCharacter(
                            imagePath: heroCharacter!.avatar3dUrl,
                            characterName: badgeCharacterName,
                            initialPhrase:
                                characterSpeech ??
                                heroCharacter?.voicePhrase ??
                                'Chào bé! Tớ đang dạo chơi trong truyện nè!',
                            size: 110,
                            enableDrag: true,
                            initialOffset: characterPosition,
                            flipHorizontal: flipHorizontal,
                            scale: characterScale,
                            mode: animationMode,
                            currentAction: characterAction,
                            onScreenShake: onScreenShake,
                            onPositionChanged: onPositionChanged,
                            onDragEndPosition: onDragEndPosition,
                            onActionChanged: onActionChanged,
                          ),

                        // 5. Top row: Chapter banner, Replay CM Motion & Character badge
                        Positioned(
                          top: 10,
                          left: 12,
                          right: 12,
                          child: Row(
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLowest
                                        .withValues(alpha: 0.92),
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.secondaryContainer,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          chapterTitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.labelSm(
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (showCanvasBadges) ...[
                                const SizedBox(width: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (onReplayMotion != null &&
                                          sortedSlots.isNotEmpty) ...[
                                        GestureDetector(
                                          onTap: onReplayMotion,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 9,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isPlayingTimeline
                                                  ? const Color(0xFF059669)
                                                  : const Color(0xFF0284C7),
                                              borderRadius: BorderRadius.circular(
                                                9999,
                                              ),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Color(0x30000000),
                                                  offset: Offset(0, 2),
                                                  blurRadius: 6,
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  isPlayingTimeline
                                                      ? Icons.directions_run_rounded
                                                      : Icons.replay_rounded,
                                                  size: 13,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  isPlayingTimeline
                                                      ? 'Đang di chuyển'
                                                      : 'Xem lại',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                      if (onOpenAnimationControls != null) ...[
                                        GestureDetector(
                                          onTap: onOpenAnimationControls,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF8B5CF6),
                                                  Color(0xFFC084FC),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(
                                                9999,
                                              ),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Color(0x358B5CF6),
                                                  offset: Offset(0, 2),
                                                  blurRadius: 6,
                                                ),
                                              ],
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.theater_comedy_rounded,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Animation',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                      if (sortedSlots.isNotEmpty ||
                                          (heroCharacter != null &&
                                              heroCharacter!.avatar3dUrl.isNotEmpty))
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryFixed.withValues(
                                              alpha: 0.95,
                                            ),
                                            borderRadius: BorderRadius.circular(9999),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.star_rounded,
                                                size: 14,
                                                color: Color(0xFFD97706),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                badgeCharacterName,
                                                style: AppTypography.labelSm(
                                                  color: AppColors.onPrimaryFixed,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                            ],
                          ),
                        ),

                        // 6. Discreet hint pill at bottom (chỉ hiện khi có nhân vật)
                        if (sortedSlots.isNotEmpty ||
                            (heroCharacter != null &&
                                heroCharacter!.avatar3dUrl.isNotEmpty))
                          Positioned(
                            bottom: 8,
                            left: 12,
                            right: 12,
                          child: Center(
                            child: GestureDetector(
                              onTap:
                                  onReplayMotion ??
                                  onOpenAnimationControls ??
                                  onTapSparkles,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLowest
                                      .withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(9999),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x20000000),
                                      offset: Offset(0, 2),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.touch_app_rounded,
                                      size: 14,
                                      color: AppColors.secondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        sortedSlots.isNotEmpty
                                            ? 'Chạm để nhảy • Nhấp đúp hoặc bấm Xem lại'
                                            : 'Chạm nhảy • Nhấp đúp đổi chiêu • Animation',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.labelSm(
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
      ),
    );
  }
}

/// Renders a single CM character slot in exact 0..100% stage space (`width: 24% * scale`, `anchor: center`)
/// with Web FE timeline transforms (`x`, `y`, `scale`, `rotation`, `opacity`, `flipHorizontal`)
/// plus playful tap-to-bounce and optional manual playground animations.
class _StageSlotActorWidget extends StatefulWidget {
  final StoryStageSlotItem item;
  final Size stageSize;
  final bool isPlayingTimeline;
  final CharacterAction? manualToyAction;
  final AnimationMode animationMode;
  final VoidCallback onScreenShake;
  final VoidCallback onTapSparkles;
  final VoidCallback? onDoubleTapReplay;
  final ValueChanged<Offset>? onPercentChanged;

  const _StageSlotActorWidget({
    super.key,
    required this.item,
    required this.stageSize,
    required this.isPlayingTimeline,
    this.manualToyAction,
    required this.animationMode,
    required this.onScreenShake,
    required this.onTapSparkles,
    this.onDoubleTapReplay,
    this.onPercentChanged,
  });

  @override
  State<_StageSlotActorWidget> createState() => _StageSlotActorWidgetState();
}

class _StageSlotActorWidgetState extends State<_StageSlotActorWidget>
    with TickerProviderStateMixin {
  late final AnimationController _breathController;
  late final AnimationController _tapJumpController;
  late final AnimationController _toyLoopController;

  bool _showSpeech = false;
  bool _isDragging = false;
  double? _lastRenderX;
  bool _movingLeft = false;
  bool _isWalkingHorizontally = false;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _tapJumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _toyLoopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _syncManualToy(widget.manualToyAction);
  }

  @override
  void didUpdateWidget(covariant _StageSlotActorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.manualToyAction != widget.manualToyAction) {
      _syncManualToy(widget.manualToyAction);
    }
    final currentX = widget.item.renderState.x;
    if (_lastRenderX != null) {
      final dx = currentX - _lastRenderX!;
      // Smooth frame-to-frame horizontal travel (ignores instant loop-reset jumps >= 14%)
      if (dx.abs() > 0.015 && dx.abs() < 14.0) {
        _movingLeft = dx < 0;
        _isWalkingHorizontally = true;
      } else if (dx.abs() <= 0.015) {
        _isWalkingHorizontally = false;
      }
    }
    _lastRenderX = currentX;
  }

  void _syncManualToy(CharacterAction? action) {
    if (action == null || action == CharacterAction.idle) {
      _toyLoopController.stop();
      _toyLoopController.value = 0.0;
    } else if (action == CharacterAction.stomp) {
      _toyLoopController.forward(from: 0.0).then((_) {
        if (mounted) widget.onScreenShake();
      });
    } else {
      _toyLoopController.repeat();
    }
  }

  @override
  void dispose() {
    _breathController.dispose();
    _tapJumpController.dispose();
    _toyLoopController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _tapJumpController.forward(from: 0.0);
    widget.onTapSparkles();
    setState(() => _showSpeech = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showSpeech = false);
    });
  }

  Widget _buildSpriteImage(String primaryUrl, String? fallbackPath) {
    Widget buildSingle(String src, {Widget Function()? onError}) {
      if (src.startsWith('assets/')) {
        return Image.asset(
          src,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) =>
              onError != null ? onError() : _avatarFallback(),
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.network(
          src,
          fit: BoxFit.contain,
          loadingBuilder: appImageLoadingBuilder,
          errorBuilder: (_, _, _) =>
              onError != null ? onError() : _avatarFallback(),
        ),
      );
    }

    if (primaryUrl.isEmpty) {
      if (fallbackPath != null && fallbackPath.isNotEmpty) {
        return buildSingle(fallbackPath);
      }
      return _avatarFallback();
    }

    return buildSingle(
      primaryUrl,
      onError: () {
        if (fallbackPath != null &&
            fallbackPath.isNotEmpty &&
            fallbackPath != primaryUrl) {
          return buildSingle(fallbackPath);
        }
        return _avatarFallback();
      },
    );
  }

  Widget _avatarFallback() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7).withValues(alpha: 0.9),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF59E0B), width: 2),
      ),
      child: Center(
        child: Text(
          widget.item.displayName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF92400E),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rect = widget.item.renderState.computeStageRect(
      widget.stageSize,
      anchor: widget.item.slot.anchor,
    );

    return AnimatedBuilder(
      animation: Listenable.merge([
        _breathController,
        _tapJumpController,
        _toyLoopController,
      ]),
      builder: (context, _) {
        double extraDx = 0.0;
        double extraDy = 0.0;
        double scaleMulX = 1.0;
        double scaleMulY = 1.0;
        double extraRotZ = widget.item.renderState.rotation * math.pi / 180.0;
        double extraRotY = widget.item.flipHorizontal ? math.pi : 0.0;

        // Lively Squash & Stretch step while walking along CM coordinates,
        // and playful 3D bounce while dwelling at CM's target coordinate
        final breath = _breathController.value;
        if (widget.isPlayingTimeline && _isWalkingHorizontally) {
          final stepWave = math.sin(breath * math.pi * 4);
          extraRotZ += stepWave * 0.11;
          scaleMulX = 1.0 + stepWave.abs() * 0.07;
          scaleMulY = 1.0 - stepWave.abs() * 0.06;
          extraRotY = _movingLeft ? math.pi : 0.0;
        } else if (widget.manualToyAction == null ||
            widget.manualToyAction == CharacterAction.idle) {
          if (widget.animationMode == AnimationMode.spineJellyMesh) {
            final jelly = math.sin(breath * math.pi * 2);
            scaleMulX = 1.0 + jelly * 0.08;
            scaleMulY = 1.0 - jelly * 0.08;
            extraDy -= math.sin(breath * math.pi) * (rect.height * 0.06);
          } else {
            final bounce = math.sin(breath * math.pi);
            scaleMulX = 1.0 + (0.5 - bounce) * 0.06;
            scaleMulY = 1.0 - (0.5 - bounce) * 0.06;
            extraRotZ += math.sin(breath * math.pi * 2) * 0.045;
            extraDy -= bounce * (rect.height * 0.065);
          }
        }

        // Optional manual toy override when child explicitly uses Animation sheet
        final toy = widget.manualToyAction;
        final t = _toyLoopController.value;
        if (toy != null && toy != CharacterAction.idle) {
          switch (toy) {
            case CharacterAction.patrol:
              extraDx +=
                  math.sin(t * 2 * math.pi) * (widget.stageSize.width * 0.08);
              extraDy -= (math.sin(t * 8 * math.pi)).abs() * 8.0;
              if (math.cos(t * 2 * math.pi) < 0) extraRotY += math.pi;
              break;
            case CharacterAction.dance:
              extraRotY += t * 2 * math.pi;
              extraDy -= (math.sin(t * 4 * math.pi)).abs() * 14.0;
              break;
            case CharacterAction.fly:
              extraDx +=
                  math.sin(t * 2 * math.pi) * (widget.stageSize.width * 0.06);
              extraDy -= 18.0 + math.sin(t * 4 * math.pi) * 10.0;
              break;
            case CharacterAction.stomp:
              extraDy -= math.sin(t * math.pi) * 42.0;
              break;
            case CharacterAction.sleep:
              extraRotZ += widget.item.flipHorizontal ? 0.35 : -0.35;
              extraDy += 6.0;
              break;
            case CharacterAction.idle:
              break;
          }
        }

        // Tap-to-jump bounce
        if (_tapJumpController.isAnimating) {
          final jumpProgress = _tapJumpController.value;
          final arc = math.sin(jumpProgress * math.pi);
          extraDy -= arc * (rect.height * 0.28);
          scaleMulX *= 1.0 - arc * 0.08;
          scaleMulY *= 1.0 + arc * 0.10;
        }

        return Positioned(
          left: rect.left + extraDx,
          top: rect.top + extraDy,
          width: rect.width,
          height: rect.height,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _handleTap,
            onDoubleTap: widget.onDoubleTapReplay,
            onPanStart: widget.onPercentChanged != null
                ? (_) => setState(() => _isDragging = true)
                : null,
            onPanUpdate: widget.onPercentChanged != null
                ? (details) {
                    if (widget.stageSize.width <= 0 ||
                        widget.stageSize.height <= 0) {
                      return;
                    }
                    final nextX =
                        (widget.item.slot.posX +
                                (details.delta.dx / widget.stageSize.width) *
                                    100.0)
                            .clamp(6.0, 94.0);
                    final nextY =
                        (widget.item.slot.posY +
                                (details.delta.dy / widget.stageSize.height) *
                                    100.0)
                            .clamp(10.0, 92.0);
                    widget.onPercentChanged!(Offset(nextX, nextY));
                  }
                : null,
            onPanEnd: widget.onPercentChanged != null
                ? (_) => setState(() => _isDragging = false)
                : null,
            child: Opacity(
              opacity: widget.item.renderState.opacity.clamp(0.0, 1.0),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Ground contact shadow
                  Positioned(
                    bottom: rect.height * 0.04,
                    child: Container(
                      width: rect.width * 0.56,
                      height: math.max(8.0, rect.height * 0.10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),

                  // Character sprite with flip, rotation, and squash-stretch
                  Positioned.fill(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0015)
                        ..rotateY(extraRotY),
                      child: Transform.rotate(
                        angle: extraRotZ,
                        alignment: Alignment.center,
                        child: Transform.scale(
                          scaleX: scaleMulX,
                          scaleY: scaleMulY,
                          alignment: Alignment.bottomCenter,
                          child: _buildSpriteImage(
                            widget.item.imageUrl,
                            widget.item.fallbackAssetPath,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Speech bubble when tapped by child
                  if (_showSpeech)
                    Positioned(
                      top: -36,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        constraints: const BoxConstraints(maxWidth: 170),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFFF472B6),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          widget.item.speechPhrase,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF831843),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  if (_isDragging)
                    Positioned(
                      bottom: -14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEC4899),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.item.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
