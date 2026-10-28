import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../atoms/app_icon.dart';

/// M02 Search & filter molecule:
/// Recipe: A02 Search icon + A04 Input + A08 Filter action.
/// Built from shared atoms and supports hiding the filter button when used in O05 Member panel.
class AppSearchFilterBar extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final bool showFilterButton;

  const AppSearchFilterBar({
    super.key,
    this.hintText = 'Search trips...',
    this.controller,
    this.onChanged,
    this.onFilterTap,
    this.showFilterButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search Input
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.secondaryLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.secondaryDark, width: 2.0),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.secondaryDark,
                  offset: Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const Icon(
                  Iconsax.search_normal,
                  color: AppColors.secondaryDark,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.secondaryDark),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: const TextStyle(color: AppColors.carla, fontSize: 14),
                      isDense: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showFilterButton) ...[
          const SizedBox(width: 14),
          // Filter Button (min 44x44px tap target)
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.semanticYellow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.secondaryDark, width: 2.0),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.secondaryDark,
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Center(
                child: AppIcon(
                  Iconsax.filter5,
                  color: AppColors.secondaryDark,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
