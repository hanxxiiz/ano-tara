import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_icon.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../trips/data/trip_repository.dart';
import '../../data/ai_itinerary_service.dart';
import 'itinerary_widgets.dart';

/// Opens the "Generate with AI" sheet (07.17 / 07.18).
///
/// Resolves to the chosen [AiPlanScope], or `null` if the sheet was dismissed.
Future<AiPlanScope?> showGenerateWithAiSheet({
  required BuildContext context,
  required int selectedDay,
  required int dayCount,
  List<ItineraryItemModel> existingItems = const [],
  AiPlanScope initialScope = AiPlanScope.thisDay,
}) {
  return showModalBottomSheet<AiPlanScope>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => GenerateWithAiSheet(
      selectedDay: selectedDay,
      dayCount: dayCount,
      existingItems: existingItems,
      initialScope: initialScope,
    ),
  );
}

class GenerateWithAiSheet extends StatefulWidget {
  final int selectedDay;
  final int dayCount;
  final List<ItineraryItemModel> existingItems;
  final AiPlanScope initialScope;

  const GenerateWithAiSheet({
    super.key,
    required this.selectedDay,
    required this.dayCount,
    this.existingItems = const [],
    this.initialScope = AiPlanScope.thisDay,
  });

  @override
  State<GenerateWithAiSheet> createState() => _GenerateWithAiSheetState();
}

class _GenerateWithAiSheetState extends State<GenerateWithAiSheet> {
  late AiPlanScope _scope = widget.initialScope;

  bool get _hasExistingEntries => _scope == AiPlanScope.thisDay
      ? widget.existingItems.any((i) => i.dayNumber == widget.selectedDay)
      : widget.existingItems.isNotEmpty;

  String get _existingEntriesMessage => _scope == AiPlanScope.thisDay
      ? 'Day ${widget.selectedDay} already has planned activities. AI will '
          'only suggest ideas for its free time and won\'t change anything '
          'already on your itinerary.'
      : 'This trip already has some planned activities. AI will only suggest '
          'ideas for the remaining free time and won\'t change what\'s '
          'already on your itinerary.';

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final dayCount = widget.dayCount;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
        border: Border(
          top: BorderSide(color: AppColors.secondaryDark, width: 2),
          left: BorderSide(color: AppColors.secondaryDark, width: 2),
          right: BorderSide(color: AppColors.secondaryDark, width: 2),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.secondaryDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 4,
                height: 27,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCE00),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: AppColors.secondaryDark,
                    width: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Generate with AI',
                  style: AppTypography.h2.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              ItinerarySquareIconButton(
                icon: Icons.close_rounded,
                semanticLabel: 'Close',
                background: AppColors.white,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, thickness: 1, color: Color(0xFFC4BFCF)),
          const SizedBox(height: 18),
          Text(
            'What should AI plan?',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.secondaryDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ScopeOption(
                  title: 'This Day',
                  subtitle: 'Day ${widget.selectedDay} only',
                  selected: _scope == AiPlanScope.thisDay,
                  onTap: () => setState(() => _scope = AiPlanScope.thisDay),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ScopeOption(
                  title: 'Whole Trip',
                  subtitle: dayCount == 1 ? 'All 1 day' : 'All $dayCount days',
                  selected: _scope == AiPlanScope.wholeTrip,
                  onTap: () => setState(() => _scope = AiPlanScope.wholeTrip),
                ),
              ),
            ],
          ),
          if (_hasExistingEntries) ...[
            const SizedBox(height: 24),
            AiNoticeBox(
              title: 'Existing Entries Detected',
              message: _existingEntriesMessage,
            ),
          ],
          const SizedBox(height: 20),
          AppButton(
            text: 'Generate Itinerary',
            customHeight: 60,
            borderRadius: 16,
            iconLeading: const AppIcon(
              Iconsax.magic_star5,
              size: 22,
              color: AppColors.white,
            ),
            onPressed: () => Navigator.of(context).pop(_scope),
          ),
        ],
      ),
    );
  }
}

class _ScopeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ScopeOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.white : AppColors.secondaryDark;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 72,
          decoration: BoxDecoration(
            color: selected ? AppColors.secondaryDark : AppColors.white,
            borderRadius: BorderRadius.circular(9.25),
            border: Border.all(color: AppColors.secondaryDark, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: AppColors.secondaryDark,
                offset: Offset(0, 2),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: AppTypography.h4.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.caption.copyWith(
                  color: selected ? AppColors.secondaryLight : foreground,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
