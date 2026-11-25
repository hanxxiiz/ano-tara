import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_icon.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../trips/data/trip_repository.dart';
import '../widgets/itinerary_widgets.dart';

enum EntryAddedAction { viewItinerary, addAnother }

/// "Added to Itinerary!" confirmation after saving a new entry.
/// Pops with an [EntryAddedAction]; the back gesture means View Itinerary.
class EntryAddedScreen extends StatelessWidget {
  final ItineraryItemModel item;
  final DateTime? date;

  const EntryAddedScreen({super.key, required this.item, this.date});

  @override
  Widget build(BuildContext context) {
    void finish(EntryAddedAction action) => Navigator.of(context).pop(action);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) finish(EntryAddedAction.viewItinerary);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const AppIcon(
                          Iconsax.verify5,
                          size: 150,
                          color: AppColors.primaryOrange,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Added to Itinerary!',
                          textAlign: TextAlign.center,
                          style: AppTypography.h2.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Your entry was added to Day ${item.dayNumber}'
                          '${date == null ? '' : ', ${formatItineraryDate(date!)}'}.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.secondaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 28),
                        ItineraryEntryCard(
                          category: item.category,
                          title: item.title,
                          location: item.location,
                          timeRange: item.timeRange,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(27, 0, 27, 24),
                child: Column(
                  children: [
                    AppButton(
                      text: 'View Itinerary',
                      customHeight: 51,
                      borderRadius: 16,
                      onPressed: () => finish(EntryAddedAction.viewItinerary),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'Add Another',
                      variant: AppButtonVariant.secondary,
                      customHeight: 51,
                      borderRadius: 16,
                      iconLeading: const Icon(
                        Iconsax.add,
                        size: 20,
                        color: AppColors.secondaryDark,
                      ),
                      onPressed: () => finish(EntryAddedAction.addAnother),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
