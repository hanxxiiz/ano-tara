import 'package:flutter/material.dart';

// ─── Font families ───────────────────────────────────────────────────────────

/// App typography font families.
class AppFonts {
  AppFonts._();

  static const urbanist = 'Urbanist';
  static const openSans = 'OpenSans';
}

// ─── Colors ──────────────────────────────────────────────────────────────────

/// App color palette — merged from home-screen and create-group branches.
class AppColors {
  AppColors._();

  // Core palette (SVG exports)
  static const navy = Color(0xFF144885);
  static const ink = Color(0xFF0F0331);
  static const field = Color(0xFFE8E6E3);
  static const accent = Color(0xFFE24B27);

  // Home Screen Design Specifications
  static const primaryBackground = Color(0xFFFFFFFF);
  static const primaryDarkAccent = Color(0xFF10052F); // borders, hard shadows
  static const primaryBlue = Color(0xFF164D91);       // active states, filled buttons
  static const promotionalBanner = Color(0xFFE9472B); // banner orange-red
  static const groupsTileBg = Color(0xFFFFE98A);      // groups tile yellow bg
  static const secondaryYellow = Color(0xFFFFCA05);   // highlights / avatar fallback
  static const primaryText = Color(0xFF10052F);
  static const secondaryText = Color(0xFF252039);

  // Aliases used by create-group components
  static const primaryDark = primaryDarkAccent;
  static const yellow = secondaryYellow;
  static const orange = promotionalBanner;
  static const cardBg = primaryBackground;
}

// ─── Design tokens ───────────────────────────────────────────────────────────

/// Common visual styling tokens — merged from both branches.
class AppTokens {
  AppTokens._();

  // Home screen tokens
  static const double cardRadius = 18.0;
  static const double borderWidth = 2.0;
  static const Color borderColor = AppColors.primaryDarkAccent;
  static const double pagePaddingHorizontal = 15.0;
  static const double sectionSpacing = 22.0;

  static const List<BoxShadow> hardShadow = [
    BoxShadow(
      color: AppColors.primaryDarkAccent,
      offset: Offset(0, 4),
      blurRadius: 0,
    ),
  ];

  // Create-group tokens
  static const double pagePadding = pagePaddingHorizontal;
  static const double cardBorderWidth = borderWidth;
  static const double cardShadowOffset = 4.0;
  static const double avatarSize = 42.0;
  static const double groupPhotoSize = 72.0;

  static BoxDecoration cardDecoration({Color? bg}) => BoxDecoration(
        color: bg ?? AppColors.cardBg,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: AppColors.primaryDark, width: cardBorderWidth),
        boxShadow: const [
          BoxShadow(
            color: AppColors.primaryDark,
            offset: Offset(0, cardShadowOffset),
            blurRadius: 0,
          ),
        ],
      );
}

// ─── App font family ─────────────────────────────────────────────────────────
const String kAppFontFamily = AppFonts.urbanist;

// ─── Theme builder ───────────────────────────────────────────────────────────
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
    textSelectionTheme:
        const TextSelectionThemeData(cursorColor: AppColors.primaryDarkAccent),
  );
}
