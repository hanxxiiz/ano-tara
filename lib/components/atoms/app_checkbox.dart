import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

enum AppCheckboxSize {
  standard,
  mini,
}

/// Checkbox atom matching Figma "Checkboxes" board:
/// Supports Standard (24x24) and Mini (18x18) visual sizes while guaranteeing a >= 44x44px tap target.
class AppCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final bool isEnabled;
  final AppCheckboxSize size;
  final Color activeColor;

  const AppCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.isEnabled = true,
    this.size = AppCheckboxSize.standard,
    this.activeColor = AppColors.secondaryDark,
  });

  @override
  Widget build(BuildContext context) {
    final isMini = size == AppCheckboxSize.mini;
    final boxSize = isMini ? 18.0 : 28.0;
    final borderWidth = isMini ? 1.8 : (value ? 2.4 : 2.2);
    final borderRadius = isMini ? 5.0 : 7.0;
    final checkIconSize = isMini ? 13.0 : 18.0;

    final Color borderColor;
    if (!isEnabled) {
      borderColor = AppColors.shayne;
    } else if (isMini) {
      borderColor = AppColors.secondaryDark;
    } else {
      borderColor = value ? AppColors.secondaryDark : const Color(0xFF8A8894);
    }

    final box = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
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
      child: value
          ? Center(
              child: Icon(
                Icons.check_rounded,
                size: checkIconSize,
                color: isEnabled ? AppColors.secondaryDark : AppColors.shayne,
              ),
            )
          : null,
    );

    if (label != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isEnabled ? () => onChanged?.call(!value) : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
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
                    fontSize: isMini ? 11.5 : 13.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isEnabled ? () => onChanged?.call(!value) : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
        child: Center(child: box),
      ),
    );
  }
}
