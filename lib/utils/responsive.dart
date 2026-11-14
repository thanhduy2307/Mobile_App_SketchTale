import 'package:flutter/material.dart';

/// Breakpoints and responsive utility for SketchTale (Optimized for Phones, Tablets, and iPads)
class Responsive {
  static const double kTabletBreakpoint = 650.0;
  static const double kDesktopBreakpoint = 1100.0;
  static const double kMaxContentWidth = 1120.0;

  /// Returns true if screen width is smaller than 650px (typical phones)
  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < kTabletBreakpoint;
  }

  /// Returns true if screen width is between 650px and 1100px (iPad Mini, 10.2", 11", Android tablets)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= kTabletBreakpoint && width < kDesktopBreakpoint;
  }

  /// Returns true if screen width is 1100px or wider (iPad Pro 12.9" landscape, desktop)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
  }

  /// Returns true for any tablet or larger screen
  static bool isTabletOrDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= kTabletBreakpoint;
  }

  /// Returns true if device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.orientationOf(context) == Orientation.landscape;
  }

  /// Returns responsive value based on current device screen width
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= kDesktopBreakpoint && desktop != null) {
      return desktop;
    }
    if (width >= kTabletBreakpoint && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// Recommended horizontal padding based on screen size
  static double horizontalPadding(BuildContext context) {
    return value<double>(
      context,
      mobile: 16.0,
      tablet: 32.0,
      desktop: 48.0,
    );
  }

  /// Recommended full page padding based on screen size
  static EdgeInsets pagePadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: horizontalPadding(context),
      vertical: 16.0,
    );
  }

  /// Grid column count helper for cards
  static int gridColumns(BuildContext context, {int mobile = 1, int tablet = 2, int desktop = 3}) {
    return value<int>(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

/// A wrapper that constrains the maximum width of content on large tablet/iPad screens
/// and centers it cleanly with comfortable gutters.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = Responsive.kMaxContentWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPadding = EdgeInsets.symmetric(
      horizontal: Responsive.horizontalPadding(context),
      vertical: 16.0,
    );

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? defaultPadding,
          child: child,
        ),
      ),
    );
  }
}
