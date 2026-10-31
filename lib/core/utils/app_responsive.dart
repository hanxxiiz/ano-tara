import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Responsive breakpoints and layout utilities for phones (compact, standard, large)
/// and tablets (portrait & landscape).
class AppResponsive {
  AppResponsive._();

  static const double compactPhoneMaxWidth = 360.0;
  static const double phoneMaxWidth = 600.0;
  static const double tabletMaxWidth = 960.0;

  static bool isCompactPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compactPhoneMaxWidth;

  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < phoneMaxWidth;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= phoneMaxWidth;

  static EdgeInsets screenHorizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < compactPhoneMaxWidth) {
      return const EdgeInsets.symmetric(horizontal: 14.0);
    }
    if (width >= phoneMaxWidth) {
      return const EdgeInsets.symmetric(horizontal: 28.0);
    }
    return const EdgeInsets.symmetric(horizontal: 20.0);
  }
}

/// Global responsive wrapper applied in [MaterialApp.builder] so every route
/// in Ano Tara adapts cleanly across:
/// - Ultra-compact phones (< 360px wide) via proportional scaling
/// - Standard & large phones (360px - 600px wide)
/// - Portrait & landscape tablets (>= 600px wide) via a centered adaptive canvas
/// - Large OS accessibility font scales via clamped [TextScaler]
class AppResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const AppResponsiveWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    if (screenSize.width == 0 || screenSize.height == 0) {
      return child;
    }

    // Clamp text scaler so oversized system font settings do not overflow fixed cards/buttons
    final currentTextScale = mediaQuery.textScaler.scale(1.0);
    final clampedTextScale = currentTextScale.clamp(0.85, 1.0);

    // 1. Tablet & Foldable / Wide Screen Mode (width >= 600px):
    // Center the app inside a responsive tablet container (max 560px in portrait,
    // 640px in landscape) and update MediaQuery.size so all Scaffolds, AppBars,
    // BottomNavBars, and widths scale naturally to the container.
    if (screenSize.width >= AppResponsive.phoneMaxWidth) {
      final bool isLandscape = screenSize.width > screenSize.height;
      final double targetMaxWidth = isLandscape ? 640.0 : 560.0;
      final double constrainedWidth = math.min(screenSize.width, targetMaxWidth);

      final updatedMediaQuery = mediaQuery.copyWith(
        size: Size(constrainedWidth, screenSize.height),
        textScaler: TextScaler.linear(clampedTextScale),
      );

      return ColoredBox(
        color: const Color(0xFFF3EFEA),
        child: Center(
          child: Container(
            width: constrainedWidth,
            height: screenSize.height,
            decoration: const BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x1F0D0A2C),
                  blurRadius: 24,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: MediaQuery(
              data: updatedMediaQuery,
              child: child,
            ),
          ),
        ),
      );
    }

    // 2. Phones narrower than the 393px Figma canvas (e.g. 320px - 392px devices like 360px Android phones):
    // Proportionally scale from the 393px Figma design width so every card, badge,
    // 5-day calendar strip, 6-box OTP field, and 3-column grid has full 393px breathing room
    // and never overflows horizontally.
    const double figmaDesignWidth = 393.0;
    if (screenSize.width < figmaDesignWidth) {
      final double scale = screenSize.width / figmaDesignWidth;
      final double scaledHeight = screenSize.height / scale;

      final scaledMediaQuery = mediaQuery.copyWith(
        size: Size(figmaDesignWidth, scaledHeight),
        padding: mediaQuery.padding / scale,
        viewPadding: mediaQuery.viewPadding / scale,
        viewInsets: mediaQuery.viewInsets / scale,
        textScaler: TextScaler.linear(clampedTextScale),
      );

      return FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: figmaDesignWidth,
          height: scaledHeight,
          child: MediaQuery(
            data: scaledMediaQuery,
            child: child,
          ),
        ),
      );
    }

    // 3. Standard & Large Phones (360px .. 599px):
    return MediaQuery(
      data: mediaQuery.copyWith(
        textScaler: TextScaler.linear(clampedTextScale),
      ),
      child: child,
    );
  }
}

/// Scrollable viewport-filling container that allows [Spacer] and [Expanded]
/// inside a [Column] to push footer buttons to the bottom on tall screens while
/// scrolling smoothly without overflow on short screens, split-screen, or when
/// the soft keyboard is open.
class AppScrollableFillBody extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppScrollableFillBody({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: math.max(
                0.0,
                constraints.maxHeight -
                    (padding != null ? padding!.vertical : 0.0),
              ),
            ),
            child: IntrinsicHeight(
              child: child,
            ),
          ),
        );
      },
    );
  }
}
