import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

enum AppButtonVariant {
  primaryNavy,
  secondary,
  primaryOrange,
  outline,
  ghost,
  destructive,
  google,
}

enum AppButtonSize {
  small, // 44px
  medium, // 52px
}

/// A comprehensive button atom adhering to the Ano Tara Atomic Design specifications:
/// Outlines (2px Ink #0F0331) & Hard Shadows (offset: 0, 4, blur: 0, #0F0331).
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
      iconLeading: const Icon(
        Icons.person,
        size: 22,
        color: AppColors.secondaryDark,
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
    final double height = size == AppButtonSize.small ? 44.0 : 52.0;

    Color backgroundColor;
    Color foregroundColor;
    Border? border = Border.all(color: AppColors.secondaryDark, width: 2.0);
    List<BoxShadow> boxShadow = const [
      BoxShadow(
        color: AppColors.secondaryDark,
        offset: Offset(0, 4),
        blurRadius: 0,
      ),
    ];

    switch (variant) {
      case AppButtonVariant.primaryNavy:
        backgroundColor = effectivelyDisabled
            ? const Color(0xFF8B9CB2)
            : AppColors.primaryNavy;
        foregroundColor = AppColors.white;
        break;

      case AppButtonVariant.secondary:
      case AppButtonVariant.outline:
        backgroundColor = effectivelyDisabled
            ? const Color(0xFFDCDAD5)
            : AppColors.secondaryLight;
        foregroundColor = AppColors.secondaryDark;
        break;

      case AppButtonVariant.primaryOrange:
      case AppButtonVariant.destructive:
        backgroundColor = effectivelyDisabled
            ? const Color(0xFFEAA697)
            : AppColors.primaryOrange;
        foregroundColor = AppColors.white;
        break;

      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = effectivelyDisabled ? AppColors.ann : AppColors.primaryNavy;
        border = null;
        boxShadow = const [];
        break;

      case AppButtonVariant.google:
        backgroundColor = AppColors.secondaryLight;
        foregroundColor = effectivelyDisabled ? AppColors.shayne : AppColors.secondaryDark;
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
                  .copyWith(color: foregroundColor, fontWeight: FontWeight.w700),
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
        borderRadius: BorderRadius.circular(20.0),
        border: border,
        boxShadow: boxShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18.0),
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
