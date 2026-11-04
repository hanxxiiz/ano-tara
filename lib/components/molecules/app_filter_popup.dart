import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

/// Dropdown-style filter popup matching the Figma "filter pop up" frame:
/// bordered card with a hard shadow, centered options, and the selected
/// option highlighted. Generic so it can be reused for any filter.
class AppFilterPopup<T> extends StatelessWidget {
  final List<T> options;
  final T selected;
  final String Function(T option) labelBuilder;
  final ValueChanged<T> onSelected;
  final double width;

  const AppFilterPopup({
    super.key,
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.onSelected,
    this.width = 132,
  });

  // Selected-row fill from the design; swap for an AppColors token if one exists
  static const Color _selectedFill = Color(0xFF8FA8C8);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.white,
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
      // Clips the selected row's fill to the rounded corners
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in options)
                InkWell(
                  onTap: () => onSelected(option),
                  child: Container(
                    width: double.infinity,
                    height: 44,
                    alignment: Alignment.center,
                    color: option == selected ? _selectedFill : null,
                    child: Text(
                      labelBuilder(option),
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
