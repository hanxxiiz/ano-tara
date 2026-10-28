import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_radii.dart';

/// Central ThemeData configuring all colors, fonts, spacing, and component styles.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.openSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryNavy,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primaryNavy,
        onPrimary: AppColors.white,
        secondary: AppColors.primaryOrange,
        onSecondary: AppColors.white,
        error: AppColors.semanticRed,
        onError: AppColors.white,
        surface: AppColors.background,
        onSurface: AppColors.chucky,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.chucky,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),

      // Text Theme with Urbanist for titles/headings & Open Sans for body
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.urbanist(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.chucky,
        ),
        displayMedium: GoogleFonts.urbanist(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.chucky,
        ),
        headlineLarge: GoogleFonts.urbanist(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.chucky,
        ),
        headlineMedium: GoogleFonts.urbanist(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.chucky,
        ),
        headlineSmall: GoogleFonts.urbanist(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.chucky,
        ),
        titleLarge: GoogleFonts.urbanist(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.chucky,
        ),
        titleMedium: GoogleFonts.urbanist(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.chucky,
        ),
        bodyLarge: GoogleFonts.openSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.chucky,
        ),
        bodyMedium: GoogleFonts.openSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.carla,
        ),
        bodySmall: GoogleFonts.openSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.shayne,
        ),
        labelLarge: GoogleFonts.urbanist(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.chucky,
        ),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.radiusLg,
          side: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),

      // Input Decoration Theme matching Atomic Design
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.secondaryLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        hintStyle: GoogleFonts.urbanist(
          color: AppColors.shayne,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(color: AppColors.secondaryDark, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(color: AppColors.secondaryDark, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(color: AppColors.secondaryDark, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(color: AppColors.primaryOrange, width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(color: AppColors.primaryOrange, width: 2.0),
        ),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusSm),
        side: const BorderSide(color: AppColors.ann, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryNavy;
          }
          return Colors.transparent;
        }),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 24,
      ),
    );
  }
}
