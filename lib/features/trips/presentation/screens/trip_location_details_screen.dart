import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../components/atoms/app_icon.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/trip_view_models.dart';
import '../widgets/styled_map_canvas.dart';
import '../widgets/trip_card_widgets.dart';

/// Read-only Location Details / "View in Map" screen matching Figma 11.04 & 11.13.
class TripLocationDetailsScreen extends StatelessWidget {
  final TripItineraryEntry entry;

  const TripLocationDetailsScreen({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const TripSubTopBar(title: 'View in Map'),
      body: Stack(
        children: [
          // Full-bleed interactive stylized map
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.9,
              maxScale: 2.5,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return StyledMapCanvas(
                    child: Stack(
                      children: [
                        Positioned(
                          left: (constraints.maxWidth * entry.mapPosition.dx) -
                              22,
                          top: (constraints.maxHeight * entry.mapPosition.dy) -
                              38,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.secondaryDark,
                                width: 2.0,
                              ),
                              boxShadow: kTripSmallHardShadow,
                            ),
                            child: const Center(
                              child: AppIcon(
                                Iconsax.location5,
                                color: AppColors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Bottom Location Details Sheet (matches Figma 11.04 & 11.13)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        'Location Details',
                        style: AppTypography.h4.copyWith(
                          color: AppColors.secondaryDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 19,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.secondaryDark,
                            width: 1.8,
                          ),
                          boxShadow: kTripHardShadow,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: AppColors.secondaryDark,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: AppIcon(
                                  Iconsax.routing5,
                                  color: AppColors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.placeName,
                                    style: AppTypography.titleMedium.copyWith(
                                      color: AppColors.secondaryDark,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const AppIcon(
                                        Iconsax.location5,
                                        color: AppColors.primaryOrange,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          entry.location,
                                          style:
                                              AppTypography.bodySmall.copyWith(
                                            color: AppColors.shayne,
                                            fontSize: 12.5,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      const AppIcon(
                                        Iconsax.magic_star5,
                                        color: AppColors.semanticYellow,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${entry.rating.toStringAsFixed(1)} stars',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.shayne,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
