import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography configuration using Urbanist (Primary font for headings & titles)
/// and Open Sans (Secondary font for body, captions, labels, inputs).
class AppTypography {
  AppTypography._();

  // Headings & Titles (Urbanist)
  static TextStyle get h1 => GoogleFonts.urbanist(
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
        color: AppColors.chucky,
        height: 1.25,
      );

  static TextStyle get h2 => GoogleFonts.urbanist(
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
        color: AppColors.chucky,
        height: 1.3,
      );

  static TextStyle get h3 => GoogleFonts.urbanist(
        fontSize: 20.0,
        fontWeight: FontWeight.w700,
        color: AppColors.chucky,
        height: 1.3,
      );

  static TextStyle get h4 => GoogleFonts.urbanist(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: AppColors.chucky,
        height: 1.35,
      );

  static TextStyle get titleLarge => GoogleFonts.urbanist(
        fontSize: 16.0,
        fontWeight: FontWeight.w700,
        color: AppColors.chucky,
        height: 1.4,
      );

  static TextStyle get titleMedium => GoogleFonts.urbanist(
        fontSize: 15.0,
        fontWeight: FontWeight.w600,
        color: AppColors.chucky,
        height: 1.4,
      );

  // Body & Content (Open Sans)
  static TextStyle get bodyLarge => GoogleFonts.openSans(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        color: AppColors.chucky,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.openSans(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: AppColors.carla,
        height: 1.45,
      );

  static TextStyle get bodySmall => GoogleFonts.openSans(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        color: AppColors.shayne,
        height: 1.4,
      );

  // Input & Form Text (Open Sans)
  static TextStyle get inputLabel => GoogleFonts.openSans(
        fontSize: 13.0,
        fontWeight: FontWeight.w600,
        color: AppColors.chucky,
      );

  static TextStyle get inputText => GoogleFonts.openSans(
        fontSize: 15.0,
        fontWeight: FontWeight.w400,
        color: AppColors.chucky,
      );

  static TextStyle get inputHint => GoogleFonts.openSans(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: AppColors.shayne,
      );

  // Buttons & Badges
  static TextStyle get buttonLarge => GoogleFonts.urbanist(
        fontSize: 16.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      );

  static TextStyle get buttonMedium => GoogleFonts.urbanist(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );

  static TextStyle get badge => GoogleFonts.urbanist(
        fontSize: 12.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      );

  static TextStyle get caption => GoogleFonts.openSans(
        fontSize: 11.0,
        fontWeight: FontWeight.w500,
        color: AppColors.shayne,
      );
}
