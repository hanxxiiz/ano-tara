import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../atoms/app_avatar.dart';

/// M09 Availability row molecule:
/// Recipe: A01 Day + A07 Availability badge + A06 Member tokens.
class AppAvailabilityRow extends StatelessWidget {
  final String day;
  final int freeCount;
  final int extraMemberCount;

  const AppAvailabilityRow({
    super.key,
    required this.day,
    this.freeCount = 7,
    this.extraMemberCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.secondaryDark, width: 1.6),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              day,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.secondaryDark,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 3.5),
            decoration: BoxDecoration(
              color: const Color(0xFFC5D1E0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$freeCount free',
              style: AppTypography.caption.copyWith(
                color: AppColors.secondaryDark,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
          const Spacer(),
          AppMemberTokenCluster(extraCount: extraMemberCount, size: 17),
        ],
      ),
    );
  }
}
