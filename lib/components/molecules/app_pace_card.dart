import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// Horizontal pace option card molecule for Onboarding Step 5 matching Figma.
/// Features a 2px Dark Ink (#0F0331) border, hard drop shadow (0, 4), and vibrant orange icon container.
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFDECE8) : AppColors.white,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: isSelected ? AppColors.primaryOrange : AppColors.secondaryDark,
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Orange Left Badge
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange,
                  borderRadius: BorderRadius.circular(14.0),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: AppColors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.urbanist(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.openSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.carla,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Right Arrow Chevron
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.secondaryDark,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
