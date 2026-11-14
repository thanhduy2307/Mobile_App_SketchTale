import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens strictly synchronized with FE Web (tokens.css, fonts.css, global.css)
class AppColors {
  // Web Primary Palette - Sunshine Gold (--color-primary: #f7bd35, --color-primary-dark: #f0b630)
  static const Color primary = Color(0xFFF7BD35);
  static const Color primaryLight = Color(0xFFF9C42A);
  static const Color primaryDark = Color(0xFFF0B630);
  static const Color primaryBevel = Color(0xFFDFA424); // FE solid button bevel
  static const Color onPrimary = Color(0xFF001050);
  static const Color primaryContainer = Color(0xFFF7BD35);
  static const Color onPrimaryContainer = Color(0xFF001050);
  static const Color primaryFixed = Color(0xFFFFF1C3);
  static const Color primaryFixedDim = Color(0xFFFFE082);
  static const Color onPrimaryFixed = Color(0xFF001050);
  static const Color onPrimaryFixedVariant = Color(0xFF6B7280);
  static const Color inversePrimary = Color(0xFFF7BD35);

  // Web Secondary Palette - Cyan & Navy Blue (--color-blue: #46dcf7, --color-blue-dark: #48bcfc)
  static const Color secondary = Color(0xFF001050); // Web primary dark ink
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF46DCF7); // Web Cyan Blue
  static const Color secondaryBevel = Color(0xFF006398); // FE Cyan bevel
  static const Color darkButtonBg = Color(0xFF001050);
  static const Color darkBevel = Color(0xFF0A194E); // FE Dark Navy bevel
  static const Color onSecondaryContainer = Color(0xFF001050);
  static const Color secondaryFixed = Color(0xFFE3EDFF);
  static const Color secondaryFixedDim = Color(0xFFB9D5FF);
  static const Color onSecondaryFixed = Color(0xFF254AB0);
  static const Color onSecondaryFixedVariant = Color(0xFF001050);

  // Web Tertiary Palette - Playful Coral (--color-coral: #fc6c78)
  static const Color tertiary = Color(0xFFFC6C78);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFFFDADC);
  static const Color onTertiaryContainer = Color(0xFF841630);
  static const Color tertiaryFixed = Color(0xFFFFDADC);
  static const Color tertiaryFixedDim = Color(0xFFFFB2B9);
  static const Color onTertiaryFixed = Color(0xFF400010);
  static const Color onTertiaryFixedVariant = Color(0xFF891933);

  // Web Supporting Accents (--color-mint: #44f8e0, --color-yellow-accent: #fcd800)
  static const Color accentMint = Color(0xFF44F8E0);
  static const Color accentMintDark = Color(0xFF059669);
  static const Color accentYellow = Color(0xFFFCD800);
  static const Color accentLavender = Color(0xFFA78BFA);
  static const Color accentLavenderDark = Color(0xFF7C3AED);
  static const Color accentLilac = Color(0xFFA78BFA);
  static const Color accentLilacDark = Color(0xFF7C3AED);

  // Web Surface & Canvas (--color-background: #fff9ec, --color-surface: #ffffff, --color-surface-soft: #fff4fa)
  static const Color surface = Color(0xFFFFF9EC); // Web Warm Cream Background
  static const Color surfaceDim = Color(0xFFE9E9EF);
  static const Color surfaceBright = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF); // Pure White Card
  static const Color surfaceContainerLow = Color(0xFFFFF4FA); // Web Soft Pink Tint
  static const Color surfaceContainer = Color(0xFFFFF1C3); // Web Gold Metric Tint
  static const Color surfaceContainerHigh = Color(0xFFF8F9FB);
  static const Color surfaceContainerHighest = Color(0xFFE9E9EF); // Web Border

  // Web Inks & Neutrals (--color-text-primary: #001050, --color-text-secondary: #6b7280)
  static const Color onSurface = Color(0xFF001050); // Web Midnight Navy Ink
  static const Color onSurfaceVariant = Color(0xFF6B7280); // Web Slate Secondary
  static const Color inverseSurface = Color(0xFF001050);
  static const Color inverseOnSurface = Color(0xFFFFFFFF);
  static const Color outline = Color(0xFFE9E9EF); // Web Border
  static const Color outlineVariant = Color(0xFFD4D4DC);

  // Error & Alerts
  static const Color error = Color(0xFFE53935);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFEBEE);
  static const Color onErrorContainer = Color(0xFFB71C1C);
}

/// Web-matched Typography using Google Fonts Nunito (Nunito Variable on Web)
class AppTypography {
  // Display & Hero
  static TextStyle displayHero({Color color = AppColors.onSurface}) =>
      GoogleFonts.nunito(
        fontSize: 34,
        fontWeight: FontWeight.w900,
        height: 1.2,
        color: color,
        letterSpacing: -1.2,
      );

  // Headings
  static TextStyle headlineLg({Color color = AppColors.onSurface}) =>
      GoogleFonts.nunito(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        height: 1.25,
        color: color,
        letterSpacing: -0.8,
      );

  static TextStyle headlineMd({Color color = AppColors.onSurface}) =>
      GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        height: 1.3,
        color: color,
        letterSpacing: -0.4,
      );

  static TextStyle headlineSm({Color color = AppColors.onSurface}) =>
      GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: color,
      );

  // Body
  static TextStyle bodyLg({Color color = AppColors.onSurface}) =>
      GoogleFonts.nunito(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: color,
      );

  static TextStyle bodyMd({Color color = AppColors.onSurfaceVariant}) =>
      GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.45,
        color: color,
      );

  static TextStyle bodySm({Color color = AppColors.onSurfaceVariant}) =>
      GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color,
      );

  // Labels & Badges
  static TextStyle labelLg({Color color = AppColors.onSurface}) =>
      GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        height: 1.3,
        letterSpacing: 0.3,
        color: color,
      );

  static TextStyle labelMd({Color color = AppColors.onSurface}) =>
      GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: 0.25,
        color: color,
      );

  static TextStyle labelSm({Color color = AppColors.onSurfaceVariant}) =>
      GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: 0.2,
        color: color,
      );
}

/// Tactile Pill / Action Button matching SketchTale web button interactions (.landing-button, .workspace-button)
class Squishy3DButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color backgroundColor;
  final Color bevelColor;
  final Color foregroundColor;
  final double height;
  final double? width;
  final double depth;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final bool showGloss;
  final Gradient? gradient;

  const Squishy3DButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor = AppColors.primary,
    this.bevelColor = AppColors.primaryBevel,
    this.foregroundColor = AppColors.onPrimary,
    this.height = 52.0,
    this.width,
    this.depth = 4.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(9999)),
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    this.showGloss = false,
    this.gradient,
  });

  /// Factory: FE Primary Sunshine Gold button (.landing-button-primary)
  factory Squishy3DButton.primary({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    double height = 54.0,
    double? width,
    double depth = 5.0,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(9999)),
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
  }) =>
      Squishy3DButton(
        key: key,
        onPressed: onPressed,
        backgroundColor: AppColors.primary,
        bevelColor: AppColors.primaryBevel,
        foregroundColor: AppColors.onPrimary,
        height: height,
        width: width,
        depth: depth,
        borderRadius: borderRadius,
        padding: padding,
        child: child,
      );

  /// Factory: FE Dark Navy CTA button (.landing-button-dark)
  factory Squishy3DButton.dark({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    double height = 54.0,
    double? width,
    double depth = 5.0,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(9999)),
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
  }) =>
      Squishy3DButton(
        key: key,
        onPressed: onPressed,
        backgroundColor: AppColors.darkButtonBg,
        bevelColor: AppColors.darkBevel,
        foregroundColor: Colors.white,
        height: height,
        width: width,
        depth: depth,
        borderRadius: borderRadius,
        padding: padding,
        child: child,
      );

  /// Factory: FE Cyan / Secondary Action button (.workspace-button-cyan)
  factory Squishy3DButton.cyan({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    double height = 52.0,
    double? width,
    double depth = 4.0,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(9999)),
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  }) =>
      Squishy3DButton(
        key: key,
        onPressed: onPressed,
        backgroundColor: AppColors.secondaryContainer,
        bevelColor: AppColors.secondaryBevel,
        foregroundColor: AppColors.onSecondaryContainer,
        height: height,
        width: width,
        depth: depth,
        borderRadius: borderRadius,
        padding: padding,
        child: child,
      );

  /// Factory: FE Quiet Outline button (.workspace-button-quiet)
  factory Squishy3DButton.quiet({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    double height = 48.0,
    double? width,
    double depth = 2.0,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(9999)),
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
  }) =>
      Squishy3DButton(
        key: key,
        onPressed: onPressed,
        backgroundColor: Colors.white,
        bevelColor: AppColors.outlineVariant,
        foregroundColor: AppColors.onSurface,
        height: height,
        width: width,
        depth: depth,
        borderRadius: borderRadius,
        padding: padding,
        child: child,
      );

  @override
  State<Squishy3DButton> createState() => _Squishy3DButtonState();
}

class _Squishy3DButtonState extends State<Squishy3DButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveDepth = widget.depth;
    final double offsetDown = _isPressed ? effectiveDepth * 0.65 : 0.0;
    final double remainingBevel = _isPressed ? effectiveDepth * 0.35 : effectiveDepth;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        curve: Curves.easeOutCubic,
        width: widget.width,
        height: widget.height,
        margin: EdgeInsets.only(top: offsetDown, bottom: effectiveDepth - offsetDown),
        decoration: BoxDecoration(
          color: widget.gradient == null ? widget.backgroundColor : null,
          gradient: widget.gradient,
          borderRadius: widget.borderRadius,
          border: Border.all(
            color: widget.bevelColor.withValues(alpha: 0.25),
            width: 1.0,
          ),
          boxShadow: [
            // Solid, crisp 3D bevel matching FE Web: box-shadow: 0 6px 0 #dfa424
            BoxShadow(
              color: widget.bevelColor,
              offset: Offset(0, remainingBevel),
              blurRadius: 0,
            ),
            if (!_isPressed)
              BoxShadow(
                color: widget.bevelColor.withValues(alpha: 0.14),
                offset: Offset(0, effectiveDepth + 3),
                blurRadius: 8.0,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: widget.borderRadius,
          child: Padding(
            padding: widget.padding,
            child: Center(
              child: DefaultTextStyle(
                style: AppTypography.labelLg(color: widget.foregroundColor).copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Backwards-compatible ChunkyButton
class ChunkyButton extends Squishy3DButton {
  const ChunkyButton({
    super.key,
    required super.onPressed,
    required super.child,
    super.backgroundColor,
    Color borderColor = const Color(0xFFD97706),
    super.foregroundColor,
    super.height,
    super.width,
    double borderDepth = 2.0,
    super.borderRadius,
    super.padding,
    super.showGloss,
    super.gradient,
  }) : super(bevelColor: borderColor, depth: borderDepth);
}

/// Tactile Icon Button for circular / pill tools matching web
class ChunkyIconButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final Color backgroundColor;
  final Color borderColor;
  final double size;
  final double borderDepth;

  const ChunkyIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.backgroundColor = AppColors.surfaceContainerLowest,
    this.borderColor = AppColors.outline,
    this.size = 46.0,
    this.borderDepth = 2.0,
  });

  @override
  State<ChunkyIconButton> createState() => _ChunkyIconButtonState();
}

class _ChunkyIconButtonState extends State<ChunkyIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double depth = widget.borderDepth;
    final double offsetDown = _isPressed ? depth * 0.7 : 0.0;
    final double remainingBevel = _isPressed ? depth * 0.3 : depth;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        curve: Curves.easeOutCubic,
        width: widget.size,
        height: widget.size,
        margin: EdgeInsets.only(top: offsetDown, bottom: depth - offsetDown),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: widget.borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: widget.borderColor.withValues(alpha: 0.7),
              offset: Offset(0, remainingBevel),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(child: widget.icon),
      ),
    );
  }
}
