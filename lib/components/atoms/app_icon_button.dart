import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

enum AppIconButtonVariant {
  primary,
  secondary,
  destructive,
}

/// Icon button atom matching Figma "Icon buttons" specification:
/// Circular button with 2.0px Dark Ink (#0F0331) outline and (0, 3) hard shadow.
/// Variants: Primary (Deep Navy), Secondary (Neutral), Destructive (Orange).
/// Supports default, disabled, and loading states with >= 44x44px tap target.
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final AppIconButtonVariant variant;
  final double size;
  final double iconSize;
  final bool isDisabled;
  final bool isLoading;
  final String? label;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = AppIconButtonVariant.primary,
    this.size = 48.0,
    this.iconSize = 22.0,
    this.isDisabled = false,
    this.isLoading = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final bool effectivelyDisabled = isDisabled || isLoading;
    Color backgroundColor;
    Color iconColor;

    switch (variant) {
      case AppIconButtonVariant.primary:
        backgroundColor = effectivelyDisabled
            ? const Color(0xFF8B9CB2)
            : AppColors.primaryNavy;
        iconColor = AppColors.white;
        break;
      case AppIconButtonVariant.secondary:
        backgroundColor = effectivelyDisabled
            ? const Color(0xFFDCDAD5)
            : AppColors.secondaryLight;
        iconColor = AppColors.secondaryDark;
        break;
      case AppIconButtonVariant.destructive:
        backgroundColor = effectivelyDisabled
            ? const Color(0xFFEAA697)
            : AppColors.primaryOrange;
        iconColor = AppColors.white;
        break;
    }

    final circleButton = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: effectivelyDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondaryDark, width: 2.0),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.secondaryDark,
                  offset: Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: iconSize,
                      height: iconSize,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: iconColor,
                      ),
                    )
                  : Icon(
                      icon,
                      color: iconColor,
                      size: iconSize,
                    ),
            ),
          ),
        ),
      ),
    );

    if (label != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          circleButton,
          const SizedBox(height: 6),
          Text(
            label!,
            style: AppTypography.caption.copyWith(
              color: AppColors.secondaryDark,
              fontSize: 10.5,
            ),
          ),
        ],
      );
    }

    return circleButton;
  }
}
