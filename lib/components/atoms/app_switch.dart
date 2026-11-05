import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';

/// Custom Switch atom matching Figma "Switch.pdf" & "Active Right Option.pdf".
/// Uses #0F0331 (AppColors.secondaryDark) for outline and outer shadow.
/// Minimum tap target >= 44x44.
class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;
  final bool isDisabled;

  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = AppColors.primaryOrange,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled ? null : () => onChanged?.call(!value),
      borderRadius: AppRadii.radiusPill,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 50.0,
            height: 28.0,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              borderRadius: AppRadii.radiusPill,
              color: value
                  ? (isDisabled ? AppColors.ann : activeColor)
                  : (isDisabled ? AppColors.surfaceLight : AppColors.ann),
              border: Border.all(
                color: AppColors.secondaryDark,
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.secondaryDark,
                  offset: Offset(0, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 21.0,
                height: 21.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white,
                  border: Border.all(
                    color: AppColors.secondaryDark,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
