import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../components/atoms/app_icon.dart';
import '../../../../components/organisms/app_bottom_navigation.dart';
import '../../../../components/organisms/app_main_top_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/trip_view_models.dart';
import '../widgets/styled_map_canvas.dart';
import '../widgets/trip_card_widgets.dart';
import 'trip_expenses_screen.dart';
import 'trip_itinerary_readonly_screen.dart';
import 'trip_map_screen.dart';
import 'trip_members_screen.dart';

/// Read-only Completed and Cancelled Trip Overview screen matching:
/// - Figma 11.01 (Completed trip — overview)
/// - Figma 11.10 (Cancelled trip — overview)
///
/// Strictly non-editable: no edit controls are shown on Completed or Cancelled trips.
class TripOverviewScreen extends StatefulWidget {
  final TripDetailData trip;

  const TripOverviewScreen({
    super.key,
    required this.trip,
  });

  @override
  State<TripOverviewScreen> createState() => _TripOverviewScreenState();
}

class _TripOverviewScreenState extends State<TripOverviewScreen> {
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.trip.currentDay.clamp(1, widget.trip.totalDays);
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(61),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.secondaryDark, width: 1.5),
            ),
          ),
          child: AppMainTopBar(
            showBackButton: false,
            onProfileTap: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Hero Trip Card
              _buildHeroTripCard(trip),
              const SizedBox(height: 16),

              // 2. 2x2 Action Grid (Itinerary, Expenses, Members, Map)
              Row(
                children: [
                  Expanded(
                    child: _OverviewActionCard(
                      title: 'Itinerary',
                      subtitle: 'View and\nmanage plans.',
                      icon: Iconsax.calendar_add5,
                      iconBgColor: AppColors.primaryNavy,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TripItineraryReadOnlyScreen(
                              trip: trip,
                              initialDay: 2,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _OverviewActionCard(
                      title: 'Expenses',
                      subtitle: 'Track and split\ncosts.',
                      icon: Iconsax.wallet_25,
                      iconBgColor: AppColors.primaryOrange,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TripExpensesScreen(
                              trip: trip,
                              initialDay: 1,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _OverviewActionCard(
                      title: 'Members',
                      subtitle: 'See your travel\nbuddies.',
                      icon: Iconsax.profile_2user5,
                      iconBgColor: AppColors.semanticYellow,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TripMembersScreen(trip: trip),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _OverviewActionCard(
                      title: 'Map',
                      subtitle: 'Keep everyone\nin sight.',
                      icon: Iconsax.map_15,
                      iconBgColor: const Color(0xFF524B6B),
                      isMuted: trip.isReadOnly,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TripMapScreen(trip: trip),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. Bottom Status Card (Completed Day Card vs Cancelled Info Card)
              if (trip.isCancelled)
                _buildCancelledStatusCard(trip)
              else
                _buildCompletedDayCard(trip),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 1,
        onTabSelected: (index) {
          if (index == 1) return;
          Navigator.of(context).maybePop();
        },
      ),
    );
  }

  Widget _buildHeroTripCard(TripDetailData trip) {
    final isCancelled = trip.isCancelled;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.secondaryDark,
          width: 2.0,
        ),
        boxShadow: kTripHardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Stylized Map Banner with Status Badge
          SizedBox(
            height: 76,
            width: double.infinity,
            child: Stack(
              children: [
                const Positioned.fill(
                  child: StyledMapCanvas(denseRoads: false),
                ),
                Positioned(
                  top: 14,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isCancelled
                          ? AppColors.primaryOrange
                          : AppColors.semanticYellow,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.secondaryDark,
                        width: 1.6,
                      ),
                    ),
                    child: Text(
                      trip.status.badgeLabel,
                      style: AppTypography.badge.copyWith(
                        color: isCancelled
                            ? AppColors.white
                            : AppColors.secondaryDark,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1.8,
            thickness: 1.8,
            color: AppColors.secondaryDark,
          ),

          // Trip Details Body
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row (strictly read-only — no edit button)
                Text(
                  trip.title,
                  style: AppTypography.h2.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 25,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),

                // Location + Member Initials Stack
                Row(
                  children: [
                    const Icon(
                      Iconsax.location,
                      color: AppColors.primaryOrange,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        trip.location,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.shayne,
                          fontSize: 12.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TripInitialsAvatarStack(
                      initials: trip.memberInitials,
                      extraCount: trip.extraMemberCount,
                      size: 25,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ABOUT THIS TRIP Read-only Box
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 88),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.secondaryDark,
                      width: 1.6,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ABOUT THIS TRIP',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.shayne,
                          fontWeight: FontWeight.w700,
                          fontSize: 9.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trip.about,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.secondaryDark,
                          fontSize: 13,
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

  /// Navy Day Progress Card matching Figma 11.01 (Completed Trip).
  Widget _buildCompletedDayCard(TripDetailData trip) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.secondaryDark,
          width: 2.0,
        ),
        boxShadow: kTripHardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Day ',
                        style: AppTypography.h1.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 32,
                        ),
                      ),
                      TextSpan(
                        text: '$_selectedDay',
                        style: AppTypography.h1.copyWith(
                          color: AppColors.semanticYellow,
                          fontWeight: FontWeight.w800,
                          fontSize: 34,
                        ),
                      ),
                      TextSpan(
                        text: ' of ${trip.totalDays}',
                        style: AppTypography.h3.copyWith(
                          color: AppColors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const DashedCircleIconBadge(
                size: 56,
                child: Icon(
                  Icons.cloud_rounded,
                  color: AppColors.white,
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3 Yellow Progress Pills
          Row(
            children: List.generate(trip.totalDays, (index) {
              return Expanded(
                child: Container(
                  height: 10,
                  margin: EdgeInsets.only(
                    right: index < trip.totalDays - 1 ? 10 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.semanticYellow,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.secondaryDark,
                      width: 1.4,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),

          // 3 Day Selector Boxes
          Row(
            children: List.generate(trip.totalDays, (index) {
              final dayNum = index + 1;
              final isSelected = dayNum == _selectedDay;
              final dateLabel = index < trip.shortDayDates.length
                  ? trip.shortDayDates[index]
                  : 'Day $dayNum';

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDay = dayNum),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: EdgeInsets.only(
                      right: index < trip.totalDays - 1 ? 10 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.semanticYellow
                          : AppColors.primaryNavyHover.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.secondaryDark
                            : AppColors.white.withValues(alpha: 0.8),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Day $dayNum',
                          style: AppTypography.caption.copyWith(
                            color: isSelected
                                ? AppColors.secondaryDark
                                : AppColors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateLabel,
                          style: AppTypography.titleLarge.copyWith(
                            color: isSelected
                                ? AppColors.secondaryDark
                                : AppColors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 18),

          const DashedDivider(),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Iconsax.calendar_1,
                color: AppColors.semanticYellow,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                trip.fullDateRange,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Cancelled Trip Banner & Reason Card matching Figma 11.10 (strictly non-editable).
  Widget _buildCancelledStatusCard(TripDetailData trip) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.secondaryDark,
          width: 2.0,
        ),
        boxShadow: kTripHardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Orange Header Strip: "TRIP CANCELLED / This trip is off"
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            color: AppColors.primaryOrange,
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColors.primaryOrange,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRIP CANCELLED',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w700,
                        fontSize: 10.5,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'This trip is off',
                      style: AppTypography.h3.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(
            height: 1.8,
            thickness: 1.8,
            color: AppColors.secondaryDark,
          ),

          // Cancellation Details Body (read-only: no Edit button)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Iconsax.user,
                      color: AppColors.secondaryDark,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        trip.cancelledByText ?? 'Trip was cancelled',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.secondaryDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // REASON Read-only Box
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 74),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.secondaryDark,
                      width: 1.6,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REASON',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.shayne,
                          fontWeight: FontWeight.w700,
                          fontSize: 9.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trip.cancellationReason ?? 'No reason provided.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.secondaryDark,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Soft Peach "Existing Expenses" Callout
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBE1DA),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const AppIcon(
                            Iconsax.warning_25,
                            color: AppColors.primaryOrange,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Existing Expenses',
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'This trip has been cancelled, but any recorded expenses will remain accessible. Please review and settle any outstanding balances.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.secondaryDark,
                          fontSize: 12,
                          height: 1.4,
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

class _OverviewActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBgColor;
  final bool isMuted;
  final VoidCallback onTap;

  const _OverviewActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBgColor,
    this.isMuted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 12, 8, 12),
        decoration: BoxDecoration(
          color: isMuted ? const Color(0xFFEBEAEF) : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.secondaryDark,
            width: 2.0,
          ),
          boxShadow: kTripHardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Center(
                child: AppIcon(
                  icon,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      color: isMuted
                          ? const Color(0xFF524B6B)
                          : AppColors.secondaryDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      height: 1.15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: isMuted
                          ? const Color(0xFF6B657E)
                          : AppColors.carla,
                      fontSize: 10.5,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isMuted
                  ? const Color(0xFF524B6B)
                  : AppColors.secondaryDark,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
