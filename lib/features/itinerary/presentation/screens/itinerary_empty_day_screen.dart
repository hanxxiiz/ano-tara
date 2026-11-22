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

/// 07.11 · Itinerary — empty day from trip.
class ItineraryEmptyDayScreen extends StatefulWidget {
  final String? tripId;
  final String destination;

  /// Calendar dates for Day 1…N. Must not be empty.
  final List<DateTime> tripDays;
  final int initialDay;
  final List<ItineraryItemModel> existingItems;

  /// Opens the manual "Add itinerary" flow for the given day.
  final ValueChanged<int>? onAddManually;

  /// Called after AI suggestions were saved.
  final ValueChanged<AiItineraryFlowResult>? onAiItemsAdded;
  final AiItineraryService? aiService;

  const ItineraryEmptyDayScreen({
    super.key,
    this.tripId,
    required this.destination,
    required this.tripDays,
    this.initialDay = 1,
    this.existingItems = const [],
    this.onAddManually,
    this.onAiItemsAdded,
    this.aiService,
  });

  @override
  State<ItineraryEmptyDayScreen> createState() =>
      _ItineraryEmptyDayScreenState();
}

class _ItineraryEmptyDayScreenState extends State<ItineraryEmptyDayScreen> {
  late int _day = widget.initialDay.clamp(1, widget.tripDays.length);

  Future<void> _generateWithAi() async {
    final result = await startAiItineraryFlow(
      context: context,
      tripId: widget.tripId,
      destination: widget.destination,
      tripDays: widget.tripDays,
      selectedDay: _day,
      existingItems: widget.existingItems,
      service: widget.aiService,
    );
    if (result != null) widget.onAiItemsAdded?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    final dayCount = widget.tripDays.length;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: AppColors.secondaryDark),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'View Itinerary',
          style: AppTypography.h3.copyWith(color: AppColors.secondaryDark),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppColors.secondaryDark),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 18, 13, 0),
              child: ItineraryDayHeader(
                dayNumber: _day,
                dayCount: dayCount,
                date: widget.tripDays[_day - 1],
                onPrevious: _day > 1 ? () => setState(() => _day--) : null,
                onNext:
                    _day < dayCount ? () => setState(() => _day++) : null,
              ),
            ),
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
                        'Plan Day $_day yourself, or let AI draft it from '
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
                    onPressed: _generateWithAi,
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
                    onPressed: widget.onAddManually == null
                        ? null
                        : () => widget.onAddManually!(_day),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
