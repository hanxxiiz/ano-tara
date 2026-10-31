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
/// Supports default, pressed (#7D99BA + spring bounce), loading, and disabled states.
/// Tap target is always guaranteed to be >= 44x44.
class AppButton extends StatefulWidget {
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
  final double? customHeight;
  final double borderRadius;

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
    this.customHeight,
    this.borderRadius = 20.0,
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
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (_effectivelyDisabled) return;
    setState(() => _isPressed = true);
  }

  void _handleTapCancel() {
    if (!_isPressed) return;
    setState(() => _isPressed = false);
  }

  Future<void> _handleTapUp(TapUpDetails details) async {
    if (_effectivelyDisabled) return;
    if (!_isPressed) {
      setState(() => _isPressed = true);
    }
    // Brief hold so even a quick tap visibly shows the #7D99BA pressed color + spring bounce
    await Future<void>.delayed(const Duration(milliseconds: 110));
    if (mounted) {
      setState(() => _isPressed = false);
    }
    widget.onPressed?.call();
  }

  bool get _effectivelyDisabled =>
      widget.isDisabled || widget.isLoading || widget.onPressed == null;

  @override
  Widget build(BuildContext context) {
    final bool effectivelyDisabled = _effectivelyDisabled;
    final double height =
        widget.customHeight ?? (widget.size == AppButtonSize.small ? 44.0 : 52.0);

    Color backgroundColor;
    Color foregroundColor;
    Border? border = Border.all(color: AppColors.secondaryDark, width: 2.0);
    List<BoxShadow> boxShadow = [
      BoxShadow(
        color: AppColors.secondaryDark,
        offset: Offset(0, _isPressed ? 2 : 4),
        blurRadius: 0,
      ),
    ];

    switch (widget.variant) {
      case AppButtonVariant.primaryNavy:
        if (effectivelyDisabled) {
          backgroundColor = const Color(0xFF7D99BA);
        } else if (_isPressed) {
          backgroundColor = const Color(0xFF7D99BA);
        } else {
          backgroundColor = AppColors.primaryNavy;
        }
        foregroundColor = AppColors.white;
        break;

      case AppButtonVariant.secondary:
      case AppButtonVariant.outline:
        if (effectivelyDisabled) {
          backgroundColor = const Color(0xFFDCDAD5);
        } else if (_isPressed) {
          backgroundColor = const Color(0xFFC5D1E0);
        } else {
          backgroundColor = AppColors.secondaryLight;
        }
        foregroundColor = AppColors.secondaryDark;
        break;

      case AppButtonVariant.primaryOrange:
      case AppButtonVariant.destructive:
        if (effectivelyDisabled) {
          backgroundColor = const Color(0xFFEAA697);
        } else if (_isPressed) {
          backgroundColor = const Color(0xFFEAA697);
        } else {
          backgroundColor = AppColors.primaryOrange;
        }
        foregroundColor = AppColors.white;
        break;

      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = effectivelyDisabled
            ? AppColors.ann
            : (_isPressed ? const Color(0xFF7D99BA) : AppColors.primaryNavy);
        border = null;
        boxShadow = const [];
        break;

      case AppButtonVariant.google:
        backgroundColor =
            _isPressed ? const Color(0xFFC5D1E0) : AppColors.secondaryLight;
        foregroundColor =
            effectivelyDisabled ? AppColors.shayne : AppColors.secondaryDark;
        break;
    }

    Widget content;
    if (widget.isLoading) {
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

      if (widget.iconLeading != null) {
        children.add(widget.iconLeading!);
        if (widget.text != null && widget.text!.isNotEmpty) {
          children.add(const SizedBox(width: 8));
        }
      }

      if (widget.text != null && widget.text!.isNotEmpty) {
        children.add(
          Flexible(
            child: Text(
              widget.text!,
              style: (widget.size == AppButtonSize.small
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

      if (widget.iconTrailing != null) {
        if (widget.text != null && widget.text!.isNotEmpty) {
          children.add(const SizedBox(width: 8));
        }
        children.add(widget.iconTrailing!);
      }

      content = Row(
        mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: effectivelyDisabled ? null : _handleTapDown,
      onTapUp: effectivelyDisabled ? null : _handleTapUp,
      onTapCancel: effectivelyDisabled ? null : _handleTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.965 : 1.0,
        duration: Duration(milliseconds: _isPressed ? 90 : 260),
        curve: _isPressed ? Curves.easeOutQuad : Curves.elasticOut,
        child: AnimatedContainer(
          duration: Duration(milliseconds: _isPressed ? 80 : 220),
          curve: Curves.easeOutBack,
          transform: Matrix4.translationValues(0, _isPressed ? 2.0 : 0.0, 0),
          height: height,
          width: widget.width ?? (widget.isFullWidth ? double.infinity : null),
          constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: border,
            boxShadow: boxShadow,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: (widget.text == null || widget.text!.isEmpty) ? 12 : 20,
            vertical: 8,
          ),
          child: content,
        ),
      ),
    );
  }
}
