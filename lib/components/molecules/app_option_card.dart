import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// Selectable option card molecule used in Onboarding (Activities, Dietary Preferences, Allergies).
/// Adheres to Ano Tara Atomic Design: 2px solid Dark Ink (#0F0331) border and hard drop shadow (0, 4).
class AppOptionCard extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Widget? customIcon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final double? size;

  const AppOptionCard({
    super.key,
    required this.label,
    this.icon,
    this.customIcon,
    required this.isSelected,
    required this.onTap,
    this.selectedColor = AppColors.primaryNavy,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isSelected ? selectedColor : AppColors.white;
    final Color fgColor = isSelected ? AppColors.white : AppColors.secondaryDark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.0),
        child: Container(
          width: size,
          height: size,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18.0),
            border: Border.all(
              color: AppColors.secondaryDark,
              width: 2.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.secondaryDark,
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
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
                  size: 32,
                  color: fgColor,
                ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.urbanist(
                  color: fgColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
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
