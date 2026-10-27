import 'package:flutter/material.dart';

/// Spacing constants used consistently across the app.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 40.0;
  static const double massive = 48.0;

  // Minimum tap target size compliant with Figma & accessibility guidelines (>= 44x44)
  static const double minTapTarget = 44.0;

  // Common Insets
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0);
  static const EdgeInsets horizontalScreenPadding = EdgeInsets.symmetric(horizontal: 24.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
}
