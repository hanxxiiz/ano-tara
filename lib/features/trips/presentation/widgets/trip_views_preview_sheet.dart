import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_icon.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/trip_view_models.dart';
import '../screens/trip_map_screen.dart';
import '../screens/trip_overview_screen.dart';

/// Temporary navigation launcher to jump directly into the newly built
/// Trip Map, Completed Trip Overview, and Cancelled Trip Overview screens.
void showTripViewsPreviewSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: AppColors.secondaryDark, width: 2.0),
            left: BorderSide(color: AppColors.secondaryDark, width: 2.0),
            right: BorderSide(color: AppColors.secondaryDark, width: 2.0),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryDark,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Trip Views Preview (Temp)',
                style: AppTypography.h4.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Direct shortcuts to Trip Map, Completed Trip, and Cancelled Trip flows.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.carla,
                ),
              ),
              const SizedBox(height: 18),
              AppButton(
                text: 'Trip Map (Live Sharing)',
                variant: AppButtonVariant.primaryNavy,
                iconLeading: const AppIcon(
                  Iconsax.map_15,
                  color: AppColors.white,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TripMapScreen(
                        trip: TripDetailData.activeMapSample(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'Completed Trip Overview',
                variant: AppButtonVariant.secondary,
                iconLeading: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primaryNavy,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TripOverviewScreen(
                        trip: TripDetailData.completedSample(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'Cancelled Trip Overview',
                variant: AppButtonVariant.primaryOrange,
                iconLeading: const Icon(
                  Icons.cancel_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TripOverviewScreen(
                        trip: TripDetailData.cancelledSample(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
