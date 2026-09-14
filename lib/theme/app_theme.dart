import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Palette - Sunny Honey
  static const Color primary = Color(0xFF7E5700);
  static const Color primaryContainer = Color(0xFFFFB300);
  static const Color onPrimaryContainer = Color(0xFF6B4900);
  static const Color primaryFixed = Color(0xFFFFDEAC);
  static const Color onPrimaryFixed = Color(0xFF281900);
  static const Color primaryFixedDim = Color(0xFFFFBA38);

  // Secondary Palette - Coral Orange
  static const Color secondary = Color(0xFFAC3509);
  static const Color secondaryContainer = Color(0xFFFE6F42);
  static const Color onSecondaryContainer = Color(0xFF631800);
  static const Color secondaryFixed = Color(0xFFFFDBD0);
  static const Color onSecondaryFixed = Color(0xFF3A0A00);
  static const Color onSecondaryFixedVariant = Color(0xFF852300);
  static const Color secondaryFixedDim = Color(0xFFFFB59F);

  // Tertiary Palette - Cheerful Sky Blue
  static const Color tertiary = Color(0xFF006688);
  static const Color tertiaryContainer = Color(0xFF64CDFF);
  static const Color onTertiaryContainer = Color(0xFF005673);
  static const Color tertiaryFixed = Color(0xFFC2E8FF);
  static const Color onTertiaryFixed = Color(0xFF001E2B);
  static const Color tertiaryFixedDim = Color(0xFF75D1FF);

  // Accents
  static const Color accentMint = Color(0xFF52C174);
  static const Color accentMintDark = Color(0xFF2B8A4A);
  static const Color accentLilac = Color(0xFFAF75FF);
  static const Color accentLilacDark = Color(0xFF753FD4);

  // Neutrals & Surface - Warm Cloud Cream
  static const Color surface = Color(0xFFFBF9F3);
  static const Color surfaceDim = Color(0xFFDBDAD4);
  static const Color surfaceBright = Color(0xFFFBF9F3);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF5F3EE);
  static const Color surfaceContainer = Color(0xFFF0EEE8);
  static const Color surfaceContainerHigh = Color(0xFFEAE8E2);
  static const Color surfaceContainerHighest = Color(0xFFE4E2DD);

  // Text ink colors
  static const Color onSurface = Color(0xFF1B1C19);
  static const Color onSurfaceVariant = Color(0xFF514532);
  static const Color outline = Color(0xFF847560);
  static const Color outlineVariant = Color(0xFFD6C4AC);

  // Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
}

class AppTypography {
  // Headings with Quicksand
  static TextStyle headlineXl({Color color = AppColors.onSurface}) =>
      GoogleFonts.quicksand(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: color,
        letterSpacing: -0.5,
      );

  static TextStyle headlineLg({Color color = AppColors.onSurface}) =>
      GoogleFonts.quicksand(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: color,
      );

  static TextStyle headlineMd({Color color = AppColors.onSurface}) =>
      GoogleFonts.quicksand(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: color,
      );

  // Body with Plus Jakarta Sans
  static TextStyle bodyXl({Color color = AppColors.onSurface}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: color,
      );

  static TextStyle bodyLg({Color color = AppColors.onSurface}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: color,
      );

  static TextStyle bodyMd({Color color = AppColors.onSurfaceVariant}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: color,
      );

  // Labels with Quicksand
  static TextStyle labelLg({Color color = AppColors.onSurface}) =>
      GoogleFonts.quicksand(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: 0.2,
        color: color,
      );

  static TextStyle labelMd({Color color = AppColors.onSurface}) =>
      GoogleFonts.quicksand(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: 0.2,
        color: color,
      );

  static TextStyle labelSm({Color color = AppColors.onSurfaceVariant}) =>
      GoogleFonts.quicksand(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: 0.3,
        color: color,
      );
}

/// 3D Tactile Button inspired by Stitch AI Toy Box design tokens
class ChunkyButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final Color foregroundColor;
  final double height;
  final double? width;
  final double borderDepth;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  const ChunkyButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor = AppColors.primaryContainer,
    this.borderColor = const Color(0xFFD99800),
    this.foregroundColor = AppColors.onPrimaryContainer,
    this.height = 54.0,
    this.width,
    this.borderDepth = 5.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(9999)),
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  });

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double currentDepth = _isPressed ? 1.0 : widget.borderDepth;
    final double offsetDown = _isPressed ? (widget.borderDepth - 1.0) : 0.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        width: widget.width,
        height: widget.height,
        margin: EdgeInsets.only(top: offsetDown),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: widget.borderRadius,
          border: Border.all(
            color: widget.borderColor.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            if (!_isPressed)
              BoxShadow(
                color: widget.borderColor,
                offset: Offset(0, currentDepth),
                blurRadius: 0,
              ),
          ],
        ),
        child: Center(
          child: DefaultTextStyle(
            style: AppTypography.labelLg(color: widget.foregroundColor),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Chunky Icon Button for rounded tools
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
    this.borderColor = AppColors.outlineVariant,
    this.size = 48.0,
    this.borderDepth = 4.0,
  });

  @override
  State<ChunkyIconButton> createState() => _ChunkyIconButtonState();
}

class _ChunkyIconButtonState extends State<ChunkyIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double currentDepth = _isPressed ? 1.0 : widget.borderDepth;
    final double offsetDown = _isPressed ? (widget.borderDepth - 1.0) : 0.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        width: widget.size,
        height: widget.size,
        margin: EdgeInsets.only(top: offsetDown),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: widget.borderColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            if (!_isPressed)
              BoxShadow(
                color: widget.borderColor,
                offset: Offset(0, currentDepth),
                blurRadius: 0,
              ),
          ],
        ),
        child: Center(child: widget.icon),
      ),
    );
  }
}
