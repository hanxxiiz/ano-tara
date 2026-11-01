import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import 'app_pressable.dart';

enum AppCheckboxSize {
  standard,
  mini,
}

/// Checkbox atom matching the Atomic Design specification (Atoms.png):
/// - Clean white rounded square with 2.0px Ink border
/// - Checked state shows a bold Ink checkmark with smooth pop/fade animation
/// - Supports Standard (28x28) and Mini (20x20) visual sizes while ensuring >= 44x44px touch target
/// - Smooth tactile press feedback via AppPressable
class AppCheckbox extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isMini = size == AppCheckboxSize.mini;
    final double boxSize = isMini ? 20.0 : 28.0;
    final double borderWidth = 2.0;
    final double borderRadius = isMini ? 5.5 : 8.0;
    final double checkIconSize = isMini ? 15.0 : 20.0;

    final Color borderColor = isEnabled
        ? activeBorderColor
        : AppColors.shayne;

    final box = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: AppColors.white,
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
        child: value
            ? Center(
                key: const ValueKey('checked'),
                child: Icon(
                  Icons.check_rounded,
                  size: checkIconSize,
                  color: isEnabled ? checkColor : AppColors.shayne,
                ),
              )
            : const SizedBox.shrink(key: ValueKey('unchecked')),
      ),
    );

    if (label != null) {
      return AppPressable(
        onTap: isEnabled ? () => onChanged?.call(!value) : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            box,
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label!,
                style: AppTypography.bodySmall.copyWith(
                  color: isEnabled ? AppColors.secondaryDark : AppColors.shayne,
                  fontWeight: FontWeight.w600,
                  fontSize: isMini ? 12.0 : 13.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AppPressable(
      onTap: isEnabled ? () => onChanged?.call(!value) : null,
      child: Center(child: box),
    );
  }
}
