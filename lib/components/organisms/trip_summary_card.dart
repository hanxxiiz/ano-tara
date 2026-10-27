import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_typography.dart';
import '../atoms/app_avatar.dart';
import '../atoms/app_badge.dart';

/// Trip Summary Card organism matching Figma "Card #4.pdf".
/// Displays Type, Location, Start - Finish, Title, Amount, Paid by.
/// Fully accepts data as parameters for reusability across any screen.
class TripSummaryCard extends StatelessWidget {
  final String title;
  final String location;
  final String dateRange;
  final String type;
  final double amount;
  final String paidByName;
  final String? paidByAvatarUrl;
  final VoidCallback? onTap;
  final bool isLoading;

  const TripSummaryCard({
    super.key,
    required this.title,
    required this.location,
    required this.dateRange,
    required this.type,
    required this.amount,
    required this.paidByName,
    this.paidByAvatarUrl,
    this.onTap,
    this.isLoading = false,
  });

  String get formattedAmount {
    return '₱ ${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildSkeleton();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.radiusLg,
        border: Border.all(color: AppColors.borderLight, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.chucky.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.radiusLg,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: Type Badge and Location
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppBadge(
                      label: type,
                      variant: AppBadgeVariant.primaryNavy,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Iconsax.location,
                          size: 14,
                          color: AppColors.primaryOrange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          location,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.carla,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  title,
                  style: AppTypography.titleLarge.copyWith(color: AppColors.chucky),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Date Range [Start - Finish]
                Row(
                  children: [
                    const Icon(
                      Iconsax.calendar_1,
                      size: 14,
                      color: AppColors.shayne,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateRange,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.shayne),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Footer row: Amount and Paid by
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amount:',
                          style: AppTypography.caption.copyWith(color: AppColors.shayne),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formattedAmount,
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.primaryNavy,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Paid by:',
                              style: AppTypography.caption.copyWith(color: AppColors.shayne),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              paidByName,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.chucky,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        AppAvatar(
                          name: paidByName,
                          imageUrl: paidByAvatarUrl,
                          size: 32,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: AppRadii.radiusLg,
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 80, height: 24, decoration: BoxDecoration(color: AppColors.ann.withValues(alpha: 0.3), borderRadius: AppRadii.radiusPill)),
              Container(width: 70, height: 16, decoration: BoxDecoration(color: AppColors.ann.withValues(alpha: 0.3), borderRadius: AppRadii.radiusSm)),
            ],
          ),
          const SizedBox(height: 16),
          Container(width: 180, height: 20, decoration: BoxDecoration(color: AppColors.ann.withValues(alpha: 0.3), borderRadius: AppRadii.radiusSm)),
          const SizedBox(height: 8),
          Container(width: 120, height: 14, decoration: BoxDecoration(color: AppColors.ann.withValues(alpha: 0.3), borderRadius: AppRadii.radiusSm)),
          const Spacer(),
          Container(width: double.infinity, height: 28, decoration: BoxDecoration(color: AppColors.ann.withValues(alpha: 0.2), borderRadius: AppRadii.radiusSm)),
        ],
      ),
    );
  }
}
