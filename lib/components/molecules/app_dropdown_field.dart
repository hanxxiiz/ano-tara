import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

/// M03 Dropdown field molecule:
/// Recipe: A01 Label + A04 Input + A02 Dropdown icon.
class AppDropdownField extends StatelessWidget {
  final String label;
  final String hintText;
  final String? selectedValue;
  final List<String> items;
  final ValueChanged<String?>? onChanged;

  const AppDropdownField({
    super.key,
    required this.label,
    this.hintText = 'Choose expense type',
    this.selectedValue,
    this.items = const ['Food & Drinks', 'Transportation', 'Accommodation', 'Activities', 'Miscellaneous'],
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.secondaryDark,
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.secondaryLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.secondaryDark, width: 2.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              hint: Text(
                hintText,
                style: const TextStyle(color: AppColors.shayne, fontSize: 14),
              ),
              icon: const Icon(
                Iconsax.arrow_down_1,
                color: AppColors.secondaryDark,
                size: 20,
              ),
              isExpanded: true,
              dropdownColor: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              style: AppTypography.inputText.copyWith(color: AppColors.secondaryDark),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
