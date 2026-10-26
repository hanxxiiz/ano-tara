import 'package:flutter/material.dart';

/// Colors pulled from the Figma SVG exports.
class AppColors {
  AppColors._();

  static const navy = Color(0xFF144885);
  static const ink = Color(0xFF0F0331);
  static const field = Color(0xFFE8E6E3);
  static const accent = Color(0xFFE24B27);
}

/// The SVG exports have their text converted to outlines, so the font name
/// can't be read from them. Set this once the Figma font is confirmed.
const String? kAppFontFamily = null;

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: kAppFontFamily,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      primary: AppColors.navy,
      secondary: AppColors.accent,
      error: AppColors.accent,
    ),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: AppColors.ink),
  );
}
