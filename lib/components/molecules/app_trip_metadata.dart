import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../atoms/app_icon.dart';

/// M08 Trip metadata molecule:
/// Recipe: A02 Location / Calendar icons + A01 Detail text.
class AppTripMetadata extends StatelessWidget {
  final String location;
  final String dateRange;
  final String? groupName;

  const AppTripMetadata({
    super.key,
    required this.location,
    required this.dateRange,
    this.groupName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const AppIcon(Iconsax.location5, size: 15, color: AppColors.primaryNavy),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                location,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        if (groupName != null) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              const AppIcon(Iconsax.profile_2user5, size: 15, color: AppColors.primaryNavy),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  groupName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 5),
        Row(
          children: [
            const AppIcon(Iconsax.calendar5, size: 14, color: AppColors.primaryNavy),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                dateRange,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
