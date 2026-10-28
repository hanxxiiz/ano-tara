import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../molecules/app_availability_row.dart';

/// O06 Availability panel organism matching Figma "03 Organisms" board:
/// Recipe: Repeated M09 day rows + available counts + member tokens.
/// Accepts data as parameters and supports loading & empty states.
class AvailabilityPanel extends StatelessWidget {
  final int freeCount;
  final String title;
  final List<String> memberNames;
  final Map<String, int> dailyFreeCounts;
  final int extraMemberCount;
  final ValueChanged<String>? onDaySelected;
  final bool isLoading;
  final String emptyMessage;

  const AvailabilityPanel({
    super.key,
    this.freeCount = 7,
    this.title = 'Group Availability',
    this.memberNames = const ['Louie', 'Carla', 'Ann', 'Shayne'],
    this.dailyFreeCounts = const {
      'Monday': 7,
      'Tuesday': 7,
      'Wednesday': 7,
      'Thursday': 7,
      'Friday': 7,
      'Saturday': 7,
      'Sunday': 7,
    },
    this.extraMemberCount = 3,
    this.onDaySelected,
    this.isLoading = false,
    this.emptyMessage = 'No availability data synced yet.',
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryNavy),
        ),
      );
    }

    if (dailyFreeCounts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.secondaryDark, width: 2.0),
        ),
        child: Center(
          child: Text(
            emptyMessage,
            style: AppTypography.bodySmall.copyWith(color: AppColors.carla),
          ),
        ),
      );
    }

    final entries = dailyFreeCounts.entries.toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondaryDark, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.secondaryDark,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top header strip & full-width horizontal divider matching Figma O06 Availability panel
          const SizedBox(height: 36),
          Container(
            height: 1.5,
            width: double.infinity,
            color: AppColors.secondaryDark,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < entries.length; i++) ...[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onDaySelected?.call(entries[i].key),
                    child: AppAvailabilityRow(
                      day: entries[i].key,
                      freeCount: entries[i].value,
                      extraMemberCount: extraMemberCount,
                    ),
                  ),
                  if (i < entries.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
