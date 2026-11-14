import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Official SketchTale animated mascot loading asset matching FE Web (`/images/SketchTale_Mascot_Loading.webp`).
const String kAppLoadingMascotAsset = 'assets/images/SketchTale_Mascot_Loading.webp';

/// Official SketchTale app logo widget used as fallback.
const String kAppLoadingLogoAsset = 'assets/images/sketchtale-widget.png';

/// Official SketchTale full brand mark (book + pencil + SketchTale wordmark).
const String kAppLoadingBrandMarkAsset = 'assets/images/sketchtale-mark.png';

/// Gently floating SketchTale mascot / app logo shown whenever anything is loading
/// (matches FE Web's .workspace-loading-mascot and LoadingState).
class AppLoadingLogo extends StatefulWidget {
  final double size;

  /// Optional caption displayed under the logo.
  final String? label;
  final Color? labelColor;

  /// Whether to render the official animated Mascot WebP (default true).
  final bool useMascot;

  /// Whether to render the full brand mark (icon + wordmark) for large splash/modal states.
  final bool useFullBrandMark;

  const AppLoadingLogo({
    super.key,
    this.size = 80,
    this.label,
    this.labelColor,
    this.useMascot = true,
    this.useFullBrandMark = false,
  });

  @override
  State<AppLoadingLogo> createState() => _AppLoadingLogoState();
}

class _AppLoadingLogoState extends State<AppLoadingLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assetPath = widget.useMascot
        ? kAppLoadingMascotAsset
        : (widget.useFullBrandMark ? kAppLoadingBrandMarkAsset : kAppLoadingLogoAsset);

    final mascot = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Transform.translate(
          offset: Offset(0, -6.0 * t),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color(0x18363325),
                  offset: Offset(0, 7.0 + 3.0 * t),
                  blurRadius: 8.0 + 4.0 * t,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: Image.asset(
        assetPath,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Image.asset(
          kAppLoadingLogoAsset,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => Icon(
            Icons.auto_stories_rounded,
            size: widget.size,
            color: AppColors.primary,
          ),
        ),
      ),
    );

    if (widget.label == null) {
      return Semantics(label: 'Đang tải', child: mascot);
    }

    return Semantics(
      label: 'Đang tải',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          mascot,
          SizedBox(height: math.max(8, widget.size * 0.12)),
          Text(
            widget.label!,
            textAlign: TextAlign.center,
            style: AppTypography.bodySm(
              color: widget.labelColor ?? AppColors.onSurfaceVariant,
            ).copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen loading page matching FE Web's .workspace-state-full (152px mascot).
class AppLoadingScreen extends StatelessWidget {
  final String? label;

  const AppLoadingScreen({super.key, this.label = 'Đang mở trang truyện...'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: AppLoadingLogo(
          size: 152, // Exact FE full page mascot size
          useMascot: true,
          label: label,
        ),
      ),
    );
  }
}

/// Reusable loading overlay that displays the FE Mascot Card on top of `child`.
class AppLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String? label;
  final Widget child;

  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: AbsorbPointer(
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.22),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.outline, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22001050),
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: AppLoadingLogo(
                    size: 104, // Exact FE workspace-loading-mascot size (104px)
                    useMascot: true,
                    label: label ?? 'Đang tải...',
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Drop-in `Image.network(loadingBuilder: ...)` that shows the pulsing app logo
/// (sized to the available space) until the network image has finished loading.
Widget appImageLoadingBuilder(
  BuildContext context,
  Widget child,
  ImageChunkEvent? loadingProgress,
) {
  if (loadingProgress == null) return child;
  return LayoutBuilder(
    builder: (context, constraints) {
      final shortest = math.min(
        constraints.maxWidth.isFinite ? constraints.maxWidth : 120.0,
        constraints.maxHeight.isFinite ? constraints.maxHeight : 120.0,
      );
      final size = (shortest * 0.44).clamp(18.0, 72.0);
      return Center(child: AppLoadingLogo(size: size));
    },
  );
}

/// Web-aligned Empty State card matching FE's .workspace-state-empty
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    this.icon = Icons.info_outline_rounded,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 180),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outline,
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 38, color: AppColors.primaryDark),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.headlineSm(color: AppColors.onSurface),
          ),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            Squishy3DButton.primary(
              height: 44,
              depth: 3.5,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Web-aligned Error State card matching FE's .workspace-state-error
class AppErrorState extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onRetry;

  const AppErrorState({
    super.key,
    this.title = 'Không thể tải dữ liệu',
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFCDD2), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 32,
            color: Color(0xFFB03A4D),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.headlineSm(color: const Color(0xFF27303D)),
                ),
                const SizedBox(height: 4),
                Text(
                  message ?? 'Vui lòng thử lại sau ít phút.',
                  style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 12),
                  Squishy3DButton.quiet(
                    height: 38,
                    depth: 2.5,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    onPressed: onRetry,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded, size: 18, color: AppColors.onSurface),
                        SizedBox(width: 6),
                        Text(
                          'Thử lại',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
