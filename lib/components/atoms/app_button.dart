import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_typography.dart';

enum AppButtonVariant {
  primaryNavy,
  primaryOrange,
  outline,
  ghost,
  destructive,
  google,
}

enum AppButtonSize {
  small, // 44px
  medium, // 50px
}

/// A comprehensive button atom adhering to Figma specifications.
/// Supports default, loading, and disabled states.
/// Tap target is always guaranteed to be >= 44x44.
class AppButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final bool isFullWidth;
  final Widget? iconLeading;
  final Widget? iconTrailing;
  final double? width;

  const AppButton({
    super.key,
    this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primaryNavy,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = true,
    this.iconLeading,
    this.iconTrailing,
    this.width,
  });

  /// Factory constructor for Google Sign In Button matching Figma.
  factory AppButton.google({
    Key? key,
    required VoidCallback? onPressed,
    String text = 'Continue with Google',
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.google,
      isLoading: isLoading,
      isDisabled: isDisabled,
      iconLeading: Image.network(
        'https://fonts.gstatic.com/s/i/productlogos/googleg/v6/24px.svg',
        width: 20,
        height: 20,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.g_mobiledata,
          size: 24,
          color: AppColors.chucky,
        ),
      ),
    );
  }

  /// Factory constructor for Icon-only button
  factory AppButton.iconOnly({
    Key? key,
    required Widget icon,
    required VoidCallback? onPressed,
    AppButtonVariant variant = AppButtonVariant.primaryNavy,
    AppButtonSize size = AppButtonSize.small,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return AppButton(
      key: key,
      iconLeading: icon,
      onPressed: onPressed,
      variant: variant,
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      isFullWidth: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool effectivelyDisabled = isDisabled || isLoading || onPressed == null;
    final double height = size == AppButtonSize.small ? 44.0 : 50.0;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primaryNavy:
        backgroundColor = effectivelyDisabled
            ? AppColors.ann.withValues(alpha: 0.5)
            : AppColors.primaryNavy;
        foregroundColor = effectivelyDisabled ? AppColors.shayne : AppColors.white;
        break;

      case AppButtonVariant.primaryOrange:
        backgroundColor = effectivelyDisabled
            ? AppColors.ann.withValues(alpha: 0.5)
            : AppColors.primaryOrange;
        foregroundColor = effectivelyDisabled ? AppColors.shayne : AppColors.white;
        break;

      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = effectivelyDisabled ? AppColors.ann : AppColors.primaryNavy;
        borderSide = BorderSide(
          color: effectivelyDisabled ? AppColors.ann : AppColors.primaryNavy,
          width: 1.5,
        );
        break;

      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = effectivelyDisabled ? AppColors.ann : AppColors.primaryNavy;
        break;

      case AppButtonVariant.destructive:
        backgroundColor = effectivelyDisabled
            ? AppColors.ann.withValues(alpha: 0.5)
            : AppColors.semanticRed;
        foregroundColor = effectivelyDisabled ? AppColors.shayne : AppColors.white;
        break;

      case AppButtonVariant.google:
        backgroundColor = AppColors.surfaceLight;
        foregroundColor = effectivelyDisabled ? AppColors.shayne : AppColors.chucky;
        borderSide = const BorderSide(color: AppColors.ann, width: 1.0);
        break;
    }

    Widget content;
    if (isLoading) {
      content = Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
          ),
        ),
      );
    } else {
      final List<Widget> children = [];

      if (iconLeading != null) {
        children.add(iconLeading!);
        if (text != null && text!.isNotEmpty) {
          children.add(const SizedBox(width: 8));
        }
      }

      if (text != null && text!.isNotEmpty) {
        children.add(
          Flexible(
            child: Text(
              text!,
              style: (size == AppButtonSize.small
                      ? AppTypography.buttonMedium
                      : AppTypography.buttonLarge)
                  .copyWith(color: foregroundColor),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }

      if (iconTrailing != null) {
        if (text != null && text!.isNotEmpty) {
          children.add(const SizedBox(width: 8));
        }
        children.add(iconTrailing!);
      }

      content = Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      );
    }

    final buttonWidget = Container(
      height: height,
      width: width ?? (isFullWidth ? double.infinity : null),
      constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadii.radiusMd,
        border: borderSide != BorderSide.none ? Border.fromBorderSide(borderSide) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadii.radiusMd,
          onTap: effectivelyDisabled ? null : onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: (text == null || text!.isEmpty) ? 12 : 20,
              vertical: 8,
            ),
            child: content,
          ),
        ),
      ),
    );

    return buttonWidget;
  }
}
