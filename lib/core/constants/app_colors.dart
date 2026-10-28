import 'package:flutter/material.dart';

/// App color palette matching the Figma design system specifications.
class AppColors {
  AppColors._();

  // Primary Brand Colors
  /// Warm Red-Orange / Terracotta (#E24B27)
  static const Color primaryOrange = Color(0xFFE24B27);
  static const Color primaryOrangeLight = Color(0xFFFBECE8);
  static const Color primaryOrangeHover = Color(0xFFC73D1C);

  /// Deep Navy Blue (#144885)
  static const Color primaryNavy = Color(0xFF144885);
  static const Color primaryNavyLight = Color(0xFFE8EEF5);
  static const Color primaryNavyHover = Color(0xFF0F3663);

  // Secondary Brand Colors
  /// Light Warm Grey / Off-white (#E8E6E3)
  static const Color secondaryLight = Color(0xFFE8E6E3);

  /// Deep Dark Ink / Dark Violet (#0F0331)
  static const Color secondaryDark = Color(0xFF0F0331);

  // Semantic Colors
  /// Warning / Accent / Tier Yellow (#F9CF09)
  static const Color semanticYellow = Color(0xFFF9CF09);
  static const Color semanticYellowLight = Color(0xFFFFF9E0);
  static const Color creamYellow = Color(0xFFFDE8B3);

  /// Error / Destructive Red (#F50506)
  static const Color semanticRed = Color(0xFFF50506);
  static const Color semanticRedLight = Color(0xFFFDE6E6);

  /// Success Green
  static const Color semanticGreen = Color(0xFF10B981);
  static const Color semanticGreenLight = Color(0xFFE7F8F0);

  // Neutral Colors (named as per Figma assets)
  /// "Chucky" - Deepest Dark Ink (#0F0331)
  static const Color chucky = Color(0xFF0F0331);

  /// "Carla" - Deep Muted Purple-Gray (#4B4265)
  static const Color carla = Color(0xFF4B4265);

  /// "Shayne" - Medium Neutral Gray (#868097)
  static const Color shayne = Color(0xFF868097);

  /// "Ann" - Light Neutral / Borders / Inactive (#C3C0CB)
  static const Color ann = Color(0xFFC3C0CB);

  // Background & Surface Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8F8FA);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF2F2F5);
  static const Color borderLight = Color(0xFFE4E2E9);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}
