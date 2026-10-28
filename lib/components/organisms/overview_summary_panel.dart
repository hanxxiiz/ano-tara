import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../atoms/app_icon.dart';

class OverviewMetricData {
  final Color badgeColor;
  final IconData badgeIcon;
  final String value;
  final String label;

  const OverviewMetricData({
    required this.badgeColor,
    required this.badgeIcon,
    required this.value,
    required this.label,
  });
}

/// O04 Overview summary panel organism matching Figma "03 Organisms" board:
/// Recipe: A set of metric molecules: icon + value + label.
/// Accepts customizable parameters so it works on different screens.
class OverviewSummaryPanel extends StatelessWidget {
  final String availableToday;
  final String upcomingTrips;
  final String totalExpenses;
  final String destinations;
  final List<OverviewMetricData>? customMetrics;
  final bool isLoading;

  const OverviewSummaryPanel({
    super.key,
    this.availableToday = '5/7',
    this.upcomingTrips = '3',
    this.totalExpenses = 'P50,000',
    this.destinations = '4',
    this.customMetrics,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(color: AppColors.primaryNavy),
        ),
      );
    }

    final metrics = customMetrics ??
        [
          OverviewMetricData(
            badgeColor: AppColors.primaryNavy,
            badgeIcon: Iconsax.calendar_add5,
            value: availableToday,
            label: 'Available Today',
          ),
          OverviewMetricData(
            badgeColor: AppColors.primaryOrange,
            badgeIcon: Iconsax.map5,
            value: upcomingTrips,
            label: 'Upcoming Trips',
          ),
          OverviewMetricData(
            badgeColor: AppColors.semanticYellow,
            badgeIcon: Iconsax.wallet_25,
            value: totalExpenses,
            label: 'Total Expenses',
          ),
          OverviewMetricData(
            badgeColor: const Color(0xFF3B3254),
            badgeIcon: Iconsax.location5,
            value: destinations,
            label: 'Destinations',
          ),
        ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: _buildMetricCard(metrics[0])),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard(metrics[1])),
          ],
        ),
        if (metrics.length >= 4) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMetricCard(metrics[2])),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard(metrics[3])),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMetricCard(OverviewMetricData metric) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: metric.badgeColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: AppIcon(metric.badgeIcon, color: AppColors.white, size: 22),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.value,
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                Text(
                  metric.label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.carla,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
