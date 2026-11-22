import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../components/atoms/app_icon.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/ai_itinerary_service.dart';

/// Chip / placeholder blue used on AI suggestion cards and loading checks.
const Color kItineraryMutedBlue = Color(0xFF89A3C1);

/// Notice box background (E8F2FA in Figma).
const Color kItineraryNoticeBlue = Color(0xFFE8F2FA);

const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// "Friday, November 13"
String formatItineraryDate(DateTime date) =>
    '${_weekdays[date.weekday - 1]}, ${_months[date.month - 1]} ${date.day}';

/// 35×34 square button with ink border and hard shadow (day arrows, sheet close).
class ItinerarySquareIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color background;
  final String semanticLabel;

  const ItinerarySquareIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.background = AppColors.secondaryLight,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Padding(
          // Pads the 35×34 visual to a ≥44 tap target.
          padding: const EdgeInsets.all(5),
          child: Opacity(
            opacity: enabled ? 1 : 0.35,
            child: Container(
              width: 35,
              height: 34,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.secondaryDark, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.secondaryDark,
                    offset: Offset(0, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Icon(icon, size: 16, color: AppColors.secondaryDark),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Day 1 of 3" header with prev/next arrows, date and day progress pills.
class ItineraryDayHeader extends StatelessWidget {
  final int dayNumber;
  final int dayCount;
  final DateTime? date;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const ItineraryDayHeader({
    super.key,
    required this.dayNumber,
    required this.dayCount,
    this.date,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ItinerarySquareIconButton(
              icon: Iconsax.arrow_left_2,
              semanticLabel: 'Previous day',
              onPressed: onPrevious,
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Day $dayNumber of $dayCount',
                    style: AppTypography.h3.copyWith(
                      color: AppColors.secondaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (date != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      formatItineraryDate(date!),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.shayne,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ItinerarySquareIconButton(
              icon: Iconsax.arrow_right_3,
              semanticLabel: 'Next day',
              onPressed: onNext,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var d = 1; d <= dayCount; d++)
                Flexible(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 48),
                    height: 9,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: d == dayNumber
                          ? AppColors.secondaryDark
                          : const Color(0xFFE9E6E6),
                      borderRadius: BorderRadius.circular(4.5),
                      border: Border.all(color: AppColors.secondaryDark),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Light blue info box with hexagon-warning icon
/// ("Existing Entries Detected", "AI-generated itinerary").
class AiNoticeBox extends StatelessWidget {
  final String title;
  final String message;

  const AiNoticeBox({super.key, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 14),
      decoration: BoxDecoration(
        color: kItineraryNoticeBlue,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIcon(
                Iconsax.warning_25,
                size: 20,
                color: AppColors.primaryNavy,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.secondaryDark,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _categoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return Iconsax.reserve5;
    case 'place':
    case 'place/check-in':
    case 'accommodation':
      return Iconsax.location5;
    default:
      return Iconsax.map5;
  }
}

/// AI suggestion row on the review screen (08.06) with an orange remove button.
class AiSuggestionCard extends StatelessWidget {
  final AiItinerarySuggestion suggestion;
  final VoidCallback onRemove;

  const AiSuggestionCard({
    super.key,
    required this.suggestion,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 15, 6, 15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.secondaryDark, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.secondaryDark,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 81,
            height: 81,
            decoration: BoxDecoration(
              color: AppColors.primaryNavy,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: AppIcon(
              _categoryIcon(suggestion.category),
              size: 28,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  decoration: BoxDecoration(
                    color: kItineraryMutedBlue,
                    borderRadius: BorderRadius.circular(8.5),
                  ),
                  child: Text(
                    suggestion.category,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  suggestion.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                _MetaRow(icon: Iconsax.location5, text: suggestion.location),
                const SizedBox(height: 4),
                _MetaRow(icon: Iconsax.clock5, text: suggestion.timeRange),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: 'Remove ${suggestion.title}',
            child: InkResponse(
              key: ValueKey('remove-${suggestion.id}'),
              onTap: onRemove,
              radius: 24,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: AppIcon(
                    Iconsax.close_circle5,
                    size: 22,
                    color: AppColors.primaryOrange,
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

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIcon(icon, size: 12, color: AppColors.primaryNavy),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              color: AppColors.secondaryDark,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

/// 173px illustration circle used on the empty, loading, failure screens.
class ItineraryHeroCircle extends StatelessWidget {
  final IconData icon;
  final Color color;

  const ItineraryHeroCircle({
    super.key,
    required this.icon,
    this.color = AppColors.primaryOrange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 173,
      height: 173,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: AppIcon(icon, size: 88, color: AppColors.white),
    );
  }
}
