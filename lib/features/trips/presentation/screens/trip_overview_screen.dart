import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../app_routes.dart';
import '../../../../components/organisms/app_bottom_navigation.dart';
import '../../../../components/organisms/app_main_top_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/trip_repository.dart';
import '../widgets/trip_actions_sheet.dart';
import '../widgets/trip_map_banner.dart';
import '../widgets/trip_member_avatars.dart';

/// Organizer Trip Overview screen matching Figma 07.02:
/// - Hero trip card with map banner, status pill, organizer-only actions menu,
///   destination, member avatars, and ABOUT THIS TRIP box
/// - 2x2 quick cards: Itinerary, Expenses, Members, Map
/// - Day X of Y progress card with weather badge, segmented yellow bar, day selector, and date range
/// - Happening Now and Up Next activity cards
class TripOverviewScreen extends StatefulWidget {
  final String tripId;

  const TripOverviewScreen({
    super.key,
    required this.tripId,
  });

  @override
  State<TripOverviewScreen> createState() => _TripOverviewScreenState();
}

class _TripOverviewScreenState extends State<TripOverviewScreen> {
  int? _selectedDay;

  Future<void> _openTripActions(TripModel trip) async {
    if (!trip.isOrganizer) return;

    final choice = await TripActionsSheet.show(context);
    if (!mounted || choice == null) return;

    switch (choice) {
      case TripActionChoice.edit:
        final updated = await EditTripSheet.show(context, trip);
        if (updated != null && mounted) {
          await TripRepository.instance.updateTrip(updated);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trip updated.')),
          );
        }
        break;

      case TripActionChoice.cancel:
        final confirmed = await CancelTripDialog.show(context);
        if (confirmed && mounted) {
          await TripRepository.instance.cancelTrip(trip.id);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trip cancelled. Participants have been notified.'),
            ),
          );
        }
        break;

      case TripActionChoice.delete:
        final confirmed = await DeleteTripDialog.show(context);
        if (confirmed && mounted) {
          await TripRepository.instance.deleteTrip(trip.id);
          if (!mounted) return;
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trip permanently deleted.')),
          );
        }
        break;
    }
  }

  void _showFeaturePlaceholder(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature tapped')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<TripModel>>(
      valueListenable: TripRepository.instance.tripsNotifier,
      builder: (context, trips, _) {
        final trip = TripRepository.instance.getTripById(widget.tripId);
        if (trip == null) {
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppMainTopBar(
              showBackButton: true,
              onBackPressed: () => Navigator.of(context).pop(),
            ),
            body: const Center(child: Text('Trip not found.')),
          );
        }

        final days = trip.days.isNotEmpty
            ? trip.days
            : [
                TripDaySchedule(dayNumber: 1, dateLabel: trip.startDate),
                TripDaySchedule(dayNumber: 2, dateLabel: trip.endDate),
              ];

        final activeDay = (_selectedDay ?? trip.currentDay)
            .clamp(1, days.length);

        final dayItems = trip.itineraryItems
            .where((item) => item.dayNumber == activeDay)
            .toList();
        final fallbackItems =
            dayItems.isNotEmpty ? dayItems : trip.itineraryItems;

        final ItineraryItemModel? happeningNow =
            fallbackItems.isNotEmpty ? fallbackItems.first : null;
        final ItineraryItemModel? upNext =
            fallbackItems.length > 1 ? fallbackItems[1] : null;

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppMainTopBar(
            onNotificationTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.notifications),
          ),
          body: Column(
            children: [
              // Crisp top divider matching Figma 07.02
              Container(
                height: 1.5,
                width: double.infinity,
                color: AppColors.secondaryDark,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. HERO TRIP CARD
                      _HeroTripCard(
                        trip: trip,
                        onActionsTap: trip.isOrganizer
                            ? () => _openTripActions(trip)
                            : null,
                      ),
                      const SizedBox(height: 18),

                      // 2. 2x2 QUICK FEATURE CARDS (Itinerary, Expenses, Members, Map)
                      Row(
                        children: [
                          Expanded(
                            child: _QuickFeatureCard(
                              title: 'Itinerary',
                              subtitle: 'View and\nmanage plans.',
                              icon: Iconsax.calendar_add5,
                              iconBg: AppColors.primaryNavy,
                              cardBg: AppColors.white,
                              onTap: () => _showFeaturePlaceholder('Itinerary'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickFeatureCard(
                              title: 'Expenses',
                              subtitle: 'Track and split\ncosts.',
                              icon: Iconsax.empty_wallet5,
                              iconBg: AppColors.primaryOrange,
                              cardBg: AppColors.white,
                              onTap: () => _showFeaturePlaceholder('Expenses'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _QuickFeatureCard(
                              title: 'Members',
                              subtitle: 'See your\ntravel buddies.',
                              icon: Iconsax.profile_2user5,
                              iconBg: AppColors.semanticYellow,
                              cardBg: AppColors.white,
                              onTap: () => _showFeaturePlaceholder('Members'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickFeatureCard(
                              title: 'Map',
                              subtitle: 'Keep everyone\nin sight.',
                              icon: Iconsax.map_15,
                              iconBg: AppColors.carla,
                              cardBg: AppColors.secondaryLight,
                              titleColor: AppColors.carla,
                              subtitleColor: AppColors.carla,
                              onTap: () => _showFeaturePlaceholder('Map'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 3. DAY X OF Y PROGRESS CARD
                      _DayProgressCard(
                        currentDay: activeDay,
                        days: days,
                        fullDateRange: trip.fullDateRange,
                        onDaySelected: (dayNum) =>
                            setState(() => _selectedDay = dayNum),
                      ),
                      const SizedBox(height: 22),

                      // 4. HAPPENING NOW
                      Text(
                        'Happening Now',
                        style: AppTypography.h3.copyWith(
                          color: AppColors.secondaryDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _ScheduleHighlightCard(
                        item: happeningNow ??
                            const ItineraryItemModel(
                              id: 'default-now',
                              category: 'Activity',
                              placeName: 'Santa Fe, Bantayan',
                              location: 'Santa Fe, Bantayan',
                              title: 'Island Hopping',
                              startTime: '9:00 AM',
                              endTime: '10:00 AM',
                            ),
                        icon: Icons.landscape_rounded,
                        onTap: () => _showFeaturePlaceholder('Happening Now'),
                      ),
                      const SizedBox(height: 20),

                      // 5. UP NEXT
                      Text(
                        'Up Next',
                        style: AppTypography.h3.copyWith(
                          color: AppColors.secondaryDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _ScheduleHighlightCard(
                        item: upNext ??
                            const ItineraryItemModel(
                              id: 'default-next',
                              category: 'Check-in',
                              placeName: 'Kota Beach Resort',
                              location: 'Kota Beach Resort',
                              title: 'Check in at Kota Resort',
                              startTime: '10:00 AM',
                              endTime: '12:00 PM',
                            ),
                        icon: Iconsax.home_25,
                        onTap: () => _showFeaturePlaceholder('Up Next'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: AppBottomNavigation(
            currentIndex: 1,
            onTabSelected: (index) {
              if (index == 1) {
                Navigator.of(context).pop();
                return;
              }
              const labels = [
                'Home',
                'Trips',
                'Create trip',
                'Groups',
                'Profile',
              ];
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${labels[index]} tapped')),
              );
            },
          ),
        );
      },
    );
  }
}

class _HeroTripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback? onActionsTap;

  const _HeroTripCard({
    required this.trip,
    this.onActionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.secondaryDark, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.secondaryDark,
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TripMapBanner(status: trip.status, height: 78),
          Container(
            height: 1.8,
            width: double.infinity,
            color: AppColors.secondaryDark,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Organizer-only 3-dot Trip Actions button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        trip.name,
                        style: AppTypography.h2.copyWith(
                          color: AppColors.secondaryDark,
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                    ),
                    if (onActionsTap != null)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onActionsTap,
                        child: const SizedBox(
                          width: 36,
                          height: 36,
                          child: Center(
                            child: _OutlinedMoreVertIcon(),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                // Location + Overlapping Member Avatars
                Row(
                  children: [
                    const Icon(
                      Iconsax.location,
                      size: 16,
                      color: AppColors.primaryOrange,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        trip.destination,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.carla,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TripMemberAvatars(
                      members: trip.members,
                      maxVisible: 4,
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // ABOUT THIS TRIP box
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 84),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.secondaryDark,
                      width: 1.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ABOUT THIS TRIP',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.shayne,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trip.description.isNotEmpty
                            ? trip.description
                            : 'No trip description added yet.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.secondaryDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                    ],
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

/// Three vertically stacked outlined circles matching Figma 07.02's menu icon.
class _OutlinedMoreVertIcon extends StatelessWidget {
  const _OutlinedMoreVertIcon();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          width: 5,
          height: 5,
          margin: EdgeInsets.only(bottom: index < 2 ? 3 : 0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.secondaryDark,
              width: 1.4,
            ),
          ),
        );
      }),
    );
  }
}

class _QuickFeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color cardBg;
  final Color titleColor;
  final Color subtitleColor;
  final VoidCallback onTap;

  const _QuickFeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.cardBg,
    this.titleColor = AppColors.secondaryDark,
    this.subtitleColor = AppColors.secondaryDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 10, 6, 10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.secondaryDark, width: 2.0),
          boxShadow: const [
            BoxShadow(
              color: AppColors.secondaryDark,
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleMedium.copyWith(
                      color: titleColor,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: subtitleColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.secondaryDark,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _DayProgressCard extends StatelessWidget {
  final int currentDay;
  final List<TripDaySchedule> days;
  final String fullDateRange;
  final ValueChanged<int> onDaySelected;

  const _DayProgressCard({
    required this.currentDay,
    required this.days,
    required this.fullDateRange,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final totalDays = days.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.secondaryDark, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.secondaryDark,
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Day X of Y + Weather dashed circle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Day ',
                          style: AppTypography.h1.copyWith(
                            color: AppColors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextSpan(
                          text: '$currentDay',
                          style: AppTypography.h1.copyWith(
                            color: AppColors.semanticYellow,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextSpan(
                          text: ' of $totalDays',
                          style: AppTypography.h3.copyWith(
                            color: AppColors.white.withValues(alpha: 0.85),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const _DashedWeatherBadge(),
            ],
          ),
          const SizedBox(height: 12),

          // Segmented progress bars
          Row(
            children: List.generate(totalDays, (index) {
              final isFilled = (index + 1) <= currentDay;
              return Expanded(
                child: Container(
                  height: 9,
                  margin: EdgeInsets.only(right: index < totalDays - 1 ? 10 : 0),
                  decoration: BoxDecoration(
                    color: isFilled
                        ? AppColors.semanticYellow
                        : AppColors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: AppColors.secondaryDark,
                      width: 1.4,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),

          // Day selector pills
          Row(
            children: List.generate(days.length, (index) {
              final day = days[index];
              final isSelected = day.dayNumber == currentDay;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onDaySelected(day.dayNumber),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    margin:
                        EdgeInsets.only(right: index < days.length - 1 ? 10 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.semanticYellow
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.secondaryDark
                            : AppColors.white.withValues(alpha: 0.75),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Day ${day.dayNumber}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: isSelected
                                ? AppColors.secondaryDark
                                : AppColors.white.withValues(alpha: 0.85),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              day.dateLabel,
                              maxLines: 1,
                              style: AppTypography.titleMedium.copyWith(
                                color: isSelected
                                    ? AppColors.secondaryDark
                                    : AppColors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),

          // Dashed divider
          const _DashedDivider(),
          const SizedBox(height: 10),

          // Footer date range
          Row(
            children: [
              const Icon(
                Iconsax.calendar_1,
                color: AppColors.semanticYellow,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  fullDateRange,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashedWeatherBadge extends StatelessWidget {
  const _DashedWeatherBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: CustomPaint(
        painter: _DashedCirclePainter(color: AppColors.white),
        child: const Center(
          child: Icon(
            Icons.cloud_rounded,
            color: AppColors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;

  const _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    const dashCount = 16;
    const sweep = (3.14159265 * 2) / dashCount;
    final rect = Rect.fromLTWH(1, 1, size.width - 2, size.height - 2);

    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(rect, i * sweep, sweep * 0.55, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 5.0;
        const dashSpace = 4.0;
        final count =
            (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(count, (_) {
            return Container(
              width: dashWidth,
              height: 1.2,
              color: AppColors.white.withValues(alpha: 0.45),
            );
          }),
        );
      },
    );
  }
}

class _ScheduleHighlightCard extends StatelessWidget {
  final ItineraryItemModel item;
  final IconData icon;
  final VoidCallback onTap;

  const _ScheduleHighlightCard({
    required this.item,
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
          border: Border.all(color: AppColors.secondaryDark, width: 2.0),
          boxShadow: const [
            BoxShadow(
              color: AppColors.secondaryDark,
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: AppColors.white,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8DA2BF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item.category,
                      style: AppTypography.badge.copyWith(
                        color: AppColors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.secondaryDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Iconsax.location5,
                        size: 13,
                        color: AppColors.primaryNavy,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          item.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.secondaryDark,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Iconsax.clock5,
                        size: 13,
                        color: AppColors.primaryNavy,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          item.timeRange,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.secondaryDark,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
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
