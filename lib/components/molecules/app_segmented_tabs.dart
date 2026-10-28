import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

/// M05 Segmented tabs molecule:
/// Recipe: A01 Labels + selectable tab controls.
class AppSegmentedTabs<T> extends StatelessWidget {
  final List<T> tabs;
  final T selectedTab;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onTabChanged;

  const AppSegmentedTabs({
    super.key,
    required this.tabs,
    required this.selectedTab,
    required this.labelBuilder,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondaryDark, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.secondaryDark,
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = tab == selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryNavy : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  border: isSelected
                      ? Border.all(color: AppColors.secondaryDark, width: 1.5)
                      : null,
                ),
                child: Center(
                  child: Text(
                    labelBuilder(tab),
                    style: AppTypography.caption.copyWith(
                      color: isSelected ? AppColors.white : AppColors.secondaryDark,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
