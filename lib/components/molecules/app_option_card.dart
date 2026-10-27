import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_typography.dart';

/// Selectable option card molecule used in Onboarding (Activities, Dietary Preferences, Allergies).
class AppOptionCard extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Widget? customIcon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final double size;

  const AppOptionCard({
    super.key,
    required this.label,
    this.icon,
    this.customIcon,
    required this.isSelected,
    required this.onTap,
    this.selectedColor = AppColors.primaryNavy,
    this.size = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isSelected ? selectedColor : AppColors.surfaceLight;
    final Color fgColor = isSelected ? AppColors.white : AppColors.chucky;
    final Border border = isSelected
        ? Border.all(color: selectedColor, width: 1.5)
        : Border.all(color: AppColors.borderLight, width: 1.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.radiusLg,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: size,
          height: size,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadii.radiusLg,
            border: border,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: selectedColor.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (customIcon != null)
                customIcon!
              else if (icon != null)
                Icon(
                  icon,
                  size: 28,
                  color: fgColor,
                ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: fgColor,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
