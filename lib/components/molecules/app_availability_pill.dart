import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_typography.dart';

/// Availability pill molecule for week days selection.
class AppAvailabilityPill extends StatelessWidget {
  final String day;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;

  const AppAvailabilityPill({
    super.key,
    required this.day,
    required this.isSelected,
    required this.onTap,
    this.activeColor = AppColors.primaryOrange,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.radiusPill,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minHeight: 44.0, minWidth: 100.0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : AppColors.surfaceLight,
            borderRadius: AppRadii.radiusPill,
            border: Border.all(
              color: isSelected ? activeColor : AppColors.borderLight,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              day,
              style: AppTypography.buttonMedium.copyWith(
                color: isSelected ? AppColors.white : AppColors.chucky,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
