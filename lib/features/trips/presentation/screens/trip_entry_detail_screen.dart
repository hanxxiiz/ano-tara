import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_icon.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/trip_view_models.dart';
import '../widgets/trip_card_widgets.dart';
import 'trip_location_details_screen.dart';

/// Read-only "View Entry" screen matching Figma 11.03 (Completed) & 11.12 (Cancelled).
/// All fields are strictly non-editable.
class TripEntryDetailScreen extends StatelessWidget {
  final TripItineraryEntry entry;
  final TripStatus tripStatus;

  const TripEntryDetailScreen({
    super.key,
    required this.entry,
    required this.tripStatus,
  });

  IconData _iconForType(TripEntryType type) {
    switch (type) {
      case TripEntryType.accommodation:
        return Icons.home_work_rounded;
      case TripEntryType.activity:
        return Iconsax.sun_fog5;
      case TripEntryType.dining:
        return Icons.restaurant_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCancelledStyle = tripStatus == TripStatus.cancelled;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const TripSubTopBar(title: 'View Entry'),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Section (11.03 shows dark pill; 11.12 shows 3 read-only cards)
              Text(
                'Type',
                style: isCancelledStyle
                    ? AppTypography.h4.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      )
                    : AppTypography.inputLabel.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
              ),
              const SizedBox(height: 10),
              if (isCancelledStyle)
                Row(
                  children: [
                    for (int i = 0; i < TripEntryType.values.length; i++) ...[
                      Expanded(
                        child: _ReadOnlyTypeCard(
                          label: TripEntryType.values[i].label,
                          icon: _iconForType(TripEntryType.values[i]),
                          isSelected: entry.type == TripEntryType.values[i],
                        ),
                      ),
                      if (i < TripEntryType.values.length - 1)
                        const SizedBox(width: 10),
                    ],
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon(
                        _iconForType(entry.type),
                        color: AppColors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.type.label,
                        style: AppTypography.buttonMedium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 18),

              // Place Card with "View in Map ->" CTA
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.secondaryDark,
                    width: 2.0,
                  ),
                  boxShadow: kTripHardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.secondaryDark,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.placeName,
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.secondaryDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5,
                            ),
                          ),
                          const SizedBox(height: 5),
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
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.carla,
                                    fontSize: 12.5,
                                  ),
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
                                  color: AppColors.carla,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppButton(
                      text: 'View in Map',
                      size: AppButtonSize.small,
                      borderRadius: 14,
                      iconTrailing: const Icon(
                        Iconsax.arrow_right_1,
                        color: AppColors.white,
                        size: 18,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                TripLocationDetailsScreen(entry: entry),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Read-only Title field
              _ReadOnlyFieldBox(
                label: 'Title',
                value: entry.title,
              ),
              const SizedBox(height: 16),

              // Read-only Start Time / End Time row
              Row(
                children: [
                  Expanded(
                    child: _ReadOnlyFieldBox(
                      label: 'Start Time',
                      value: entry.startTime,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ReadOnlyFieldBox(
                      label: 'End Time',
                      value: entry.endTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Read-only Notes box
              _ReadOnlyFieldBox(
                label: 'Notes',
                value: entry.notes,
                minHeight: 132,
                alignTop: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadOnlyTypeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;

  const _ReadOnlyTypeCard({
    required this.label,
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.secondaryDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondaryDark,
          width: 1.8,
        ),
        boxShadow: isSelected ? null : kTripSmallHardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(
            icon,
            color: isSelected ? AppColors.white : AppColors.secondaryDark,
            size: 26,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: isSelected ? AppColors.white : AppColors.secondaryDark,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyFieldBox extends StatelessWidget {
  final String label;
  final String value;
  final double minHeight;
  final bool alignTop;

  const _ReadOnlyFieldBox({
    required this.label,
    required this.value,
    this.minHeight = 52,
    this.alignTop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.inputLabel.copyWith(
            color: AppColors.secondaryDark,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: minHeight),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          alignment: alignTop ? Alignment.topLeft : Alignment.centerLeft,
          decoration: BoxDecoration(
            color: AppColors.secondaryLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.secondaryDark,
              width: 1.8,
            ),
          ),
          child: Text(
            value,
            style: AppTypography.inputText.copyWith(
              color: AppColors.secondaryDark,
              fontWeight: FontWeight.w600,
              fontSize: 14.5,
            ),
          ),
        ),
      ],
    );
  }
}
