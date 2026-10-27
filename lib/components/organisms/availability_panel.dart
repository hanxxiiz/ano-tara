import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_typography.dart';
import '../atoms/app_avatar.dart';
import '../atoms/app_badge.dart';

/// Group Availability Panel organism matching Figma "Group 1848.pdf".
/// Displays "7 free", week day availability pills, and member avatars with "+3" badge.
class AvailabilityPanel extends StatelessWidget {
  final int freeCount;
  final String title;
  final List<String> memberNames;
  final Map<String, int> dailyFreeCounts;
  final ValueChanged<String>? onDaySelected;

  const AvailabilityPanel({
    super.key,
    this.freeCount = 7,
    this.title = 'Group Availability',
    this.memberNames = const ['Louie', 'Carla', 'Ann', 'Shayne', 'Chucky', 'Miguel'],
    this.dailyFreeCounts = const {
      'Mon': 7,
      'Tue': 5,
      'Wed': 6,
      'Thu': 4,
      'Fri': 7,
      'Sat': 6,
      'Sun': 7,
    },
    this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.radiusXl,
        border: Border.all(color: AppColors.borderLight, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.chucky.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with count badge and member avatars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AppBadge(
                    label: '$freeCount free',
                    variant: AppBadgeVariant.primaryOrange,
                    icon: const Icon(
                      Iconsax.calendar_tick,
                      size: 14,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(color: AppColors.chucky),
                  ),
                ],
              ),
              AppAvatarGroup(
                names: memberNames,
                maxVisible: 3,
                avatarSize: 28,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Days of the week row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: dailyFreeCounts.entries.map((entry) {
                final bool isHigh = entry.value >= freeCount - 1;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onDaySelected?.call(entry.key),
                      borderRadius: AppRadii.radiusMd,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isHigh
                              ? AppColors.primaryNavyLight
                              : AppColors.surfaceMuted,
                          borderRadius: AppRadii.radiusMd,
                          border: Border.all(
                            color: isHigh ? AppColors.primaryNavy : AppColors.borderLight,
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              entry.key,
                              style: AppTypography.caption.copyWith(
                                color: isHigh ? AppColors.primaryNavy : AppColors.carla,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${entry.value} free',
                              style: AppTypography.caption.copyWith(
                                color: isHigh ? AppColors.primaryNavy : AppColors.shayne,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
