import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable responsive background wrapper for all post-login screens.
/// Uses 'assets/images/main_screen_bg.png' with [BoxFit.cover] to adapt
/// seamlessly to any aspect ratio (mobile 19.5:9, iPad 4:3, desktop 16:9).
class AppScreenBackground extends StatelessWidget {
  final Widget child;
  final bool withOverlay;
  final double overlayAlpha;
  final Alignment alignment;

  const AppScreenBackground({
    super.key,
    required this.child,
    this.withOverlay = false,
    this.overlayAlpha = 0.05,
    this.alignment = Alignment.center,
  });

  static const String assetPath = 'assets/images/main_screen_bg.png';

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Background image with BoxFit.cover ensuring full-bleed coverage on all aspect ratios
        Positioned.fill(
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
            alignment: alignment,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, _, _) => Container(
              color: AppColors.surface,
            ),
          ),
        ),

        // 2. Optional soft protective overlay to guarantee contrast for cards and text
        if (withOverlay)
          Positioned.fill(
            child: Container(
              color: Colors.white.withValues(alpha: overlayAlpha),
            ),
          ),

        // 3. Foreground screen UI
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}
