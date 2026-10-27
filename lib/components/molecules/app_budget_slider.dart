import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_typography.dart';

/// Budget selector molecule featuring a prominent value card and step slider.
class AppBudgetSlider extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  static const List<int> budgetSteps = [500, 1000, 2000, 5000, 10000];
  static const List<String> budgetLabels = ['500', '1,000', '2,000', '5,000', '10,000+'];

  const AppBudgetSlider({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  String get formattedValue {
    if (selectedIndex >= budgetSteps.length - 1) {
      return '₱ 10,000+';
    }
    return '₱ ${budgetSteps[selectedIndex].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Highlighted Display Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: AppRadii.radiusXl,
            border: Border.all(color: AppColors.borderLight, width: 1.5),
          ),
          child: Center(
            child: Text(
              formattedValue,
              style: AppTypography.h1.copyWith(
                color: AppColors.chucky,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Custom Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6.0,
            activeTrackColor: AppColors.primaryNavy,
            inactiveTrackColor: AppColors.ann,
            thumbColor: AppColors.primaryNavy,
            overlayColor: AppColors.primaryNavy.withValues(alpha: 0.15),
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 14.0,
              elevation: 4,
            ),
            tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 4.0),
            activeTickMarkColor: AppColors.white,
            inactiveTickMarkColor: AppColors.shayne,
          ),
          child: Slider(
            value: selectedIndex.toDouble(),
            min: 0,
            max: (budgetSteps.length - 1).toDouble(),
            divisions: budgetSteps.length - 1,
            onChanged: (val) => onIndexChanged(val.round()),
          ),
        ),
        const SizedBox(height: 8),

        // Step Labels Below
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(budgetLabels.length, (index) {
              final isCurrent = index == selectedIndex;
              return Text(
                budgetLabels[index],
                style: AppTypography.caption.copyWith(
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  color: isCurrent ? AppColors.primaryNavy : AppColors.shayne,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
