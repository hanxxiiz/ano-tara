import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

/// M05 Segmented tabs molecule:
/// Recipe: A01 Labels + selectable tab controls.
/// Supports variable numbers of items (2, 3, 4, 5+) with a smooth horizontal sliding pill transition.
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
    if (tabs.isEmpty) {
      return const SizedBox.shrink();
    }

    final int count = tabs.length;
    final int rawIndex = tabs.indexOf(selectedTab);
    final int selectedIndex = rawIndex >= 0 ? rawIndex : 0;

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double tabWidth = constraints.maxWidth / count;

          return Stack(
            children: [
              // Sliding active tab indicator pill
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                left: selectedIndex * tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: AppColors.secondaryDark,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              // Interactive tab labels row
              Row(
                children: List.generate(count, (index) {
                  final T tab = tabs[index];
                  final bool isSelected = index == selectedIndex;

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTabChanged(tab),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              style: AppTypography.caption.copyWith(
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.secondaryDark,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                fontSize: 12.5,
                              ),
                              child: Text(
                                labelBuilder(tab),
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
