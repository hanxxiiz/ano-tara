import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_icon.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../trips/data/trip_repository.dart';
import '../../data/ai_itinerary_service.dart';
import '../widgets/generate_with_ai_sheet.dart';
import '../widgets/itinerary_widgets.dart';
import 'ai_itinerary_flow_screen.dart';

/// Opens the Generate with AI sheet and, if the user confirms, runs the full
/// AI flow. Resolves to `null` when the user cancels at any point.
Future<AiItineraryFlowResult?> startAiItineraryFlow({
  required BuildContext context,
  String? tripId,
  required String destination,
  required List<DateTime> tripDays,
  required int selectedDay,
  List<ItineraryItemModel> existingItems = const [],
  AiItineraryService? service,
}) async {
  final scope = await showGenerateWithAiSheet(
    context: context,
    selectedDay: selectedDay,
    dayCount: tripDays.length,
    existingItems: existingItems,
  );
  if (scope == null || !context.mounted) return null;

  return Navigator.of(context).push<AiItineraryFlowResult>(
    MaterialPageRoute(
      builder: (_) => AiItineraryFlowScreen(
        service: service,
        tripDays: tripDays,
        request: AiItineraryRequest(
          tripId: tripId,
          destination: destination,
          dayCount: tripDays.length,
          selectedDay: selectedDay,
          scope: scope,
          existingItems: existingItems,
        ),
      ),
    ),
  );
}

/// 07.11 · Itinerary — empty day: hero, copy, "Generate with AI" and
/// "Add Manually". Shown by the itinerary screen when a day has no entries.
class ItineraryEmptyDayBody extends StatelessWidget {
  final int dayNumber;
  final VoidCallback onGenerateWithAi;
  final VoidCallback onAddManually;

  const ItineraryEmptyDayBody({
    super.key,
    required this.dayNumber,
    required this.onGenerateWithAi,
    required this.onAddManually,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const ItineraryHeroCircle(icon: Iconsax.routing5),
                  const SizedBox(height: 20),
                  Text(
                    'No itinerary yet',
                    style: AppTypography.h3.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Plan Day $dayNumber yourself, or let AI draft it from '
                    'your group\'s preferences.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.secondaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(27, 0, 32, 24),
          child: Column(
            children: [
              AppButton(
                text: 'Generate with AI',
                customHeight: 47,
                borderRadius: 16,
                iconLeading: const AppIcon(
                  Iconsax.magic_star5,
                  size: 20,
                  color: AppColors.white,
                ),
                onPressed: onGenerateWithAi,
              ),
              const SizedBox(height: 18),
              AppButton(
                text: 'Add Manually',
                variant: AppButtonVariant.secondary,
                customHeight: 47,
                borderRadius: 16,
                iconLeading: const Icon(
                  Iconsax.add,
                  size: 20,
                  color: AppColors.secondaryDark,
                ),
                onPressed: onAddManually,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
