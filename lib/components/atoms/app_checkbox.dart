import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

enum AppCheckboxSize {
  standard,
  mini,
}

/// Checkbox atom matching the Atomic Design specification (Atoms.png):
/// - Clean white rounded square with 2.0px Ink (#0F0331) border
/// - Checked state shows an Iconsax tick icon with smooth pop/fade animation
/// - Supports Standard (28x28) and Mini (20x20) visual sizes while ensuring >= 44x44px touch target
/// - Smooth tactile press feedback
class AppCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final bool isEnabled;
  final AppCheckboxSize size;
  final Color activeBorderColor;
  final Color checkColor;

  const AppCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.isEnabled = true,
    this.size = AppCheckboxSize.standard,
    this.activeBorderColor = AppColors.secondaryDark,
    this.checkColor = AppColors.secondaryDark,
  });

  @override
  State<AppCheckbox> createState() => _AppCheckboxState();
}

class _AppCheckboxState extends State<AppCheckbox> {
  bool _isPressed = false;

  bool get _canInteract => widget.isEnabled && widget.onChanged != null;

  void _handleTapDown(TapDownDetails details) {
    if (!_canInteract) return;
    setState(() => _isPressed = true);
  }

  void _handleTapCancel() {
    if (!_isPressed) return;
    setState(() => _isPressed = false);
  }

  Future<void> _handleTapUp(TapUpDetails details) async {
    if (!_canInteract) return;
    if (!_isPressed) {
      setState(() => _isPressed = true);
    }
    await Future<void>.delayed(const Duration(milliseconds: 90));
    if (mounted) {
      setState(() => _isPressed = false);
    }
    widget.onChanged?.call(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final isMini = widget.size == AppCheckboxSize.mini;
    final double boxSize = isMini ? 20.0 : 28.0;
    const double borderWidth = 2.0;
    final double borderRadius = isMini ? 5.5 : 8.0;
    final double checkIconSize = isMini ? 14.0 : 18.0;

    final Color borderColor =
        widget.isEnabled ? widget.activeBorderColor : AppColors.shayne;

    final box = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: _isPressed ? const Color(0xFFE8EEF5) : AppColors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: widget.value
            ? Center(
                key: const ValueKey('checked'),
                child: Icon(
                  Iconsax.tick_square,
                  size: checkIconSize,
                  color: widget.isEnabled ? widget.checkColor : AppColors.shayne,
                ),
              )
            : const SizedBox.shrink(key: ValueKey('unchecked')),
      ),
    );

    final Widget content = widget.label != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              box,
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  widget.label!,
                  style: AppTypography.bodySmall.copyWith(
                    color: widget.isEnabled
                        ? AppColors.secondaryDark
                        : AppColors.shayne,
                    fontWeight: FontWeight.w600,
                    fontSize: isMini ? 12.0 : 13.5,
                  ),
                ),
              ),
            ],
          )
        : Center(child: box);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _canInteract ? _handleTapDown : null,
      onTapUp: _canInteract ? _handleTapUp : null,
      onTapCancel: _canInteract ? _handleTapCancel : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
        child: AnimatedScale(
          scale: _isPressed ? 0.94 : 1.0,
          duration: Duration(milliseconds: _isPressed ? 80 : 180),
          curve: _isPressed ? Curves.easeOutQuad : Curves.easeOutBack,
          child: content,
        ),
      ),
    );
  }
}
