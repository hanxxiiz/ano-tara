import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../components/atoms/app_icon.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/trip_view_models.dart';
import '../widgets/trip_card_widgets.dart';
import 'trip_entry_detail_screen.dart';

/// Read-only "View Itinerary" screen matching Figma 11.02 (Completed) & 11.11 (Cancelled).
class TripItineraryReadOnlyScreen extends StatefulWidget {
  final TripDetailData trip;
  final int initialDay;

  const TripItineraryReadOnlyScreen({
    super.key,
    required this.trip,
    this.initialDay = 1,
  });

  @override
  State<TripItineraryReadOnlyScreen> createState() =>
      _TripItineraryReadOnlyScreenState();
}

class _TripItineraryReadOnlyScreenState
    extends State<TripItineraryReadOnlyScreen> {
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDay.clamp(1, widget.trip.totalDays);
  }

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
    final daySubtitle = (_selectedDay - 1) < widget.trip.fullDayDates.length
        ? widget.trip.fullDayDates[_selectedDay - 1]
        : 'Day $_selectedDay';

    final entries = widget.trip.itineraryEntries
        .where((e) => e.dayNumber == _selectedDay)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const TripSubTopBar(title: 'View Itinerary'),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: [
            TripDayStepperHeader(
              currentDay: _selectedDay,
              totalDays: widget.trip.totalDays,
              dateSubtitle: daySubtitle,
              onDayChanged: (day) => setState(() => _selectedDay = day),
            ),
            const SizedBox(height: 22),
            Text(
              'Entries',
              style: AppTypography.h4.copyWith(
                color: AppColors.secondaryDark,
                fontWeight: FontWeight.w800,
                fontSize: 19,
              ),
            ),
            const SizedBox(height: 14),
            if (entries.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.secondaryDark,
                    width: 1.8,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Iconsax.calendar_remove,
                      size: 32,
                      color: AppColors.shayne,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No entries recorded for Day $_selectedDay',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.carla,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ItineraryReadOnlyCard(
                    entry: entry,
                    icon: _iconForType(entry.type),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TripEntryDetailScreen(
                            entry: entry,
                            tripStatus: widget.trip.status,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ItineraryReadOnlyCard extends StatelessWidget {
  final TripItineraryEntry entry;
  final IconData icon;
  final VoidCallback onTap;

  const _ItineraryReadOnlyCard({
    required this.entry,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: AppIcon(
                  icon,
                  color: AppColors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8EA2BC),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      entry.categoryLabel,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    entry.title,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.secondaryDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 15.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const AppIcon(
                        Iconsax.location5,
                        color: AppColors.primaryNavy,
                        size: 13,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          entry.location,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.carla,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const AppIcon(
                        Iconsax.timer_15,
                        color: AppColors.primaryNavy,
                        size: 13,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        entry.timeRange,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.carla,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.secondaryDark,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
