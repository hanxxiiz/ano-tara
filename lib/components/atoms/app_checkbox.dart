import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_typography.dart';

/// Custom Checkbox atom matching Figma specs (Checkbox.pdf and Mini Checkbox.pdf).
/// Guarantees at least 44x44px tap target.
class AppCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final bool isMini;
  final bool isDisabled;
  final Color activeColor;

  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.isMini = false,
    this.isDisabled = false,
    this.activeColor = AppColors.primaryNavy,
  });

  @override
  Widget build(BuildContext context) {
    final double boxSize = isMini ? 18.0 : 22.0;

    final box = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: value
            ? (isDisabled ? AppColors.ann : activeColor)
            : (isDisabled ? AppColors.surfaceLight : Colors.transparent),
        borderRadius: BorderRadius.circular(isMini ? 4.0 : 6.0),
        border: Border.all(
          color: value
              ? (isDisabled ? AppColors.ann : activeColor)
              : (isDisabled ? AppColors.borderLight : AppColors.ann),
          width: 1.5,
        ),
      ),
      child: value
          ? Icon(
              Icons.check,
              size: isMini ? 12.0 : 16.0,
              color: AppColors.white,
            )
          : null,
    );

    return InkWell(
      onTap: isDisabled ? null : () => onChanged?.call(!value),
      borderRadius: AppRadii.radiusSm,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              box,
              if (label != null) ...[
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label!,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDisabled ? AppColors.shayne : AppColors.chucky,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
