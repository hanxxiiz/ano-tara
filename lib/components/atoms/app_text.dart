import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

enum AppTextVariant {
  h1,
  h2,
  h3,
  titleLarge,
  titleMedium,
  inputLabel,
  bodyMedium,
  bodySmall,
  caption,
  badge,
}

/// A01 Text atom matching Figma "A01 Text" specification:
/// Labels, headings and body text • Urbanist + Open Sans.
class AppText extends StatelessWidget {
  final String text;
  final AppTextVariant variant;
  final Color? color;
  final FontWeight? fontWeight;
  final double? fontSize;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppText(
    this.text, {
    super.key,
    this.variant = AppTextVariant.bodyMedium,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  factory AppText.heading(String text, {Color? color, double? fontSize}) {
    return AppText(
      text,
      variant: AppTextVariant.h3,
      color: color ?? AppColors.secondaryDark,
      fontWeight: FontWeight.w800,
      fontSize: fontSize,
    );
  }

  factory AppText.label(String text, {Color? color}) {
    return AppText(
      text,
      variant: AppTextVariant.inputLabel,
      color: color ?? AppColors.secondaryDark,
    );
  }

  factory AppText.body(String text, {Color? color}) {
    return AppText(
      text,
      variant: AppTextVariant.bodySmall,
      color: color ?? AppColors.secondaryDark,
    );
  }

  @override
  Widget build(BuildContext context) {
    TextStyle baseStyle;
    switch (variant) {
      case AppTextVariant.h1:
        baseStyle = AppTypography.h1;
        break;
      case AppTextVariant.h2:
        baseStyle = AppTypography.h2;
        break;
      case AppTextVariant.h3:
        baseStyle = AppTypography.h3;
        break;
      case AppTextVariant.titleLarge:
        baseStyle = AppTypography.titleLarge;
        break;
      case AppTextVariant.titleMedium:
        baseStyle = AppTypography.titleMedium;
        break;
      case AppTextVariant.inputLabel:
        baseStyle = AppTypography.inputLabel;
        break;
      case AppTextVariant.bodyMedium:
        baseStyle = AppTypography.bodyMedium;
        break;
      case AppTextVariant.bodySmall:
        baseStyle = AppTypography.bodySmall;
        break;
      case AppTextVariant.caption:
        baseStyle = AppTypography.caption;
        break;
      case AppTextVariant.badge:
        baseStyle = AppTypography.badge;
        break;
    }

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: baseStyle.copyWith(
        color: color,
        fontWeight: fontWeight,
        fontSize: fontSize,
      ),
    );
  }
}
