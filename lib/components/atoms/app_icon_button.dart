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
/// Supports default, pressed (scale + 2px translation + shadow reduction + color transition),
/// disabled, and loading states with >= 44x44px tap target.
class AppIconButton extends StatefulWidget {
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
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool _isPressed = false;

  bool get _effectivelyDisabled =>
      widget.isDisabled || widget.isLoading || widget.onPressed == null;

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
    await Future<void>.delayed(const Duration(milliseconds: 110));
    if (mounted) {
      setState(() => _isPressed = false);
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bool effectivelyDisabled =
        widget.isDisabled || widget.isLoading || widget.onPressed == null;
    Color backgroundColor;
    Color iconColor;

    switch (widget.variant) {
      case AppIconButtonVariant.primary:
        if (effectivelyDisabled) {
          backgroundColor = const Color(0xFF8B9CB2);
        } else if (_isPressed) {
          backgroundColor = const Color(0xFF7D99BA);
        } else {
          backgroundColor = AppColors.primaryNavy;
        }
        iconColor = AppColors.white;
        break;
      case AppIconButtonVariant.secondary:
        if (effectivelyDisabled) {
          backgroundColor = const Color(0xFFDCDAD5);
        } else if (_isPressed) {
          backgroundColor = const Color(0xFFC5D1E0);
        } else {
          backgroundColor = AppColors.secondaryLight;
        }
        iconColor = AppColors.secondaryDark;
        break;
      case AppIconButtonVariant.destructive:
        if (effectivelyDisabled) {
          backgroundColor = const Color(0xFFEAA697);
        } else if (_isPressed) {
          backgroundColor = const Color(0xFFEAA697);
        } else {
          backgroundColor = AppColors.primaryOrange;
        }
        iconColor = AppColors.white;
        break;
    }

    final circleButton = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: effectivelyDisabled ? null : _handleTapDown,
      onTapUp: effectivelyDisabled ? null : _handleTapUp,
      onTapCancel: effectivelyDisabled ? null : _handleTapCancel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
        child: AnimatedScale(
          scale: _isPressed ? 0.93 : 1.0,
          duration: Duration(milliseconds: _isPressed ? 90 : 240),
          curve: _isPressed ? Curves.easeOutQuad : Curves.elasticOut,
          child: AnimatedContainer(
            duration: Duration(milliseconds: _isPressed ? 80 : 200),
            curve: Curves.easeOutBack,
            transform: Matrix4.translationValues(0, _isPressed ? 2.0 : 0.0, 0),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondaryDark, width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondaryDark,
                  offset: Offset(0, _isPressed ? 1 : 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: widget.iconSize,
                      height: widget.iconSize,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: iconColor,
                      ),
                    )
                  : Icon(
                      widget.icon,
                      color: iconColor,
                      size: widget.iconSize,
                    ),
            ),
          ),
        ),
      ),
    );

    if (widget.label != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          circleButton,
          const SizedBox(height: 6),
          Text(
            widget.label!,
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
