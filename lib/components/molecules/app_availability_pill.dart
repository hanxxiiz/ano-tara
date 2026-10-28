import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// Availability pill molecule matching Figma Step 6:
/// Wide rounded button with 2px Dark Ink (#0F0331) border and hard drop shadow (0, 4).
/// Selected: solid Orange (#E24B27) with white text.
/// Unselected: peach/coral (#F1A591) with white text.
class AppAvailabilityPill extends StatelessWidget {
  final String day;
  final bool isSelected;
  final VoidCallback onTap;

  const AppAvailabilityPill({
    super.key,
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // When selected: Primary Orange #E24B27
    // When unselected: Soft peach/coral tone #F1A591 (as seen in Figma 6/7)
    final Color bgColor = isSelected ? AppColors.primaryOrange : const Color(0xFFF1A591);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          width: 154.0,
          height: 60.0,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20.0),
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
          alignment: Alignment.center,
          child: Text(
            day,
            style: GoogleFonts.urbanist(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
