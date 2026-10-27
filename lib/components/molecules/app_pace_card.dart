import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_typography.dart';

/// Horizontal pace option card molecule for Onboarding Step 5.
class AppPaceCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;

  const AppPaceCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.activeColor = AppColors.primaryOrange,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isSelected ? activeColor : AppColors.surfaceLight;
    final Color titleColor = isSelected ? AppColors.white : AppColors.chucky;
    final Color descColor = isSelected ? AppColors.white.withValues(alpha: 0.9) : AppColors.carla;
    final Color iconColor = isSelected ? AppColors.white : activeColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.radiusLg,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(minHeight: 72),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadii.radiusLg,
            border: Border.all(
              color: isSelected ? activeColor : AppColors.borderLight,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.white.withValues(alpha: 0.2) : activeColor.withValues(alpha: 0.1),
                  borderRadius: AppRadii.radiusMd,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleLarge.copyWith(color: titleColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTypography.bodySmall.copyWith(color: descColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Iconsax.arrow_right_3,
                color: isSelected ? AppColors.white : AppColors.shayne,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
