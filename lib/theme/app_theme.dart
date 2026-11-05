import 'package:flutter/material.dart';

/// App typography font families.
class AppFonts {
  AppFonts._();

  static const urbanist = 'Urbanist';
  static const openSans = 'OpenSans';
}

/// App color palette and design tokens.
class AppColors {
  AppColors._();

  // Legacy colors from SVG exports
  static const navy = Color(0xFF144885);
  static const ink = Color(0xFF0F0331);
  static const field = Color(0xFFE8E6E3);
  static const accent = Color(0xFFE24B27);

  // Home Screen Design Specifications
  static const primaryBackground = Color(0xFFFFFFFF);
  static const primaryDarkAccent = Color(0xFF10052F);
  static const primaryBlue = Color(0xFF164D91);
  static const promotionalBanner = Color(0xFFE9472B);
  static const groupsTileBg = Color(0xFFFFE98A);
  static const secondaryYellow = Color(0xFFFFCA05);
  static const primaryText = Color(0xFF10052F);
  static const secondaryText = Color(0xFF252039);
}

/// Common visual styling tokens
class AppTokens {
  AppTokens._();

  static const double cardRadius = 18.0;
  static const double borderWidth = 2.0;
  static const Color borderColor = AppColors.primaryDarkAccent;

  static const List<BoxShadow> hardShadow = [
    BoxShadow(
      color: AppColors.primaryDarkAccent,
      offset: Offset(0, 4),
      blurRadius: 0,
    ),
  ];

  static const double pagePaddingHorizontal = 15.0;
  static const double sectionSpacing = 22.0;
}

const String? kAppFontFamily = AppFonts.urbanist;

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: kAppFontFamily,
    scaffoldBackgroundColor: AppColors.primaryBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryBlue,
      primary: AppColors.primaryBlue,
      secondary: AppColors.promotionalBanner,
      error: AppColors.promotionalBanner,
    ),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: AppColors.primaryDarkAccent),
  );
}
