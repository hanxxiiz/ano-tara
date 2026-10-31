import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../components/molecules/app_segmented_tabs.dart';
import '../../../../components/organisms/app_bottom_navigation.dart';
import '../../../../components/organisms/app_main_top_bar.dart';
import '../../../../components/organisms/availability_panel.dart';
import '../../../../components/organisms/group_header_organism.dart';
import '../../../../components/organisms/member_panel.dart';
import '../../../../components/organisms/overview_summary_panel.dart';
import '../../../../components/organisms/trip_summary_card.dart';
import '../../../shell/presentation/screens/main_shell_screen.dart';
import '../../../trips/data/trip_repository.dart';

enum GroupDetailTab { overview, trips, availability, members }

class GroupDetailScreen extends StatefulWidget {
  final String groupName;
  final GroupDetailTab initialTab;
  final bool embeddedInShell;
  final VoidCallback? onNavigateToProfile;

  const GroupDetailScreen({
    super.key,
    this.groupName = 'Trip to Bantayan',
    this.initialTab = GroupDetailTab.overview,
    this.embeddedInShell = false,
    this.onNavigateToProfile,
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  late GroupDetailTab _activeTab;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
  }

  String _tabLabel(GroupDetailTab tab) {
    switch (tab) {
      case GroupDetailTab.overview:
        return 'Overview';
      case GroupDetailTab.trips:
        return 'Trips';
      case GroupDetailTab.availability:
        return 'Availability';
      case GroupDetailTab.members:
        return 'Members';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      // O01 App Navigation (Non-scrollable Top Bar with solid dark circle at top-left matching Figma)
      appBar: AppMainTopBar(
        showBackButton: false,
        onProfileTap: () {
          if (widget.onNavigateToProfile != null) {
            widget.onNavigateToProfile!();
          } else if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const MainShellScreen(initialTab: 4),
              ),
            );
          }
        },
        onNotificationTap: () => Navigator.pushNamed(context, AppRoutes.invitations),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // O02 Group header organism
              GroupHeaderOrganism(
                groupName: widget.groupName,
                roleLabel: 'Organizer',
                memberCount: 7,
                onPlanTripTap: () async {
                  final created = await Navigator.pushNamed(
                    context,
                    AppRoutes.planTrip,
                    arguments: widget.groupName,
                  );
                  if (created != null && mounted) {
                    setState(() => _activeTab = GroupDetailTab.trips);
                  }
                },
              ),

              const SizedBox(height: 16),

              // M05 Segmented tabs molecule
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppSegmentedTabs<GroupDetailTab>(
                  tabs: GroupDetailTab.values,
                  selectedTab: _activeTab,
                  labelBuilder: _tabLabel,
                  onTabChanged: (tab) => setState(() => _activeTab = tab),
                ),
              ),

              const SizedBox(height: 20),

              // Active Sibling Destination Body
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildActiveTabContent(),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: widget.embeddedInShell
          ? null
          : AppBottomNavigation(
              currentIndex: 1,
              onTabSelected: (index) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => MainShellScreen(initialTab: index),
                  ),
                  (route) => false,
                );
              },
            ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_activeTab) {
      case GroupDetailTab.overview:
        return _buildOverviewContent();
      case GroupDetailTab.trips:
        return _buildTripsContent();
      case GroupDetailTab.availability:
        return const AvailabilityPanel();
      case GroupDetailTab.members:
        return const MemberPanel(
          memberNames: [
            'Hannah S. Labandero',
            'Louielyn Abella',
            'Ellle Bernante',
          ],
        );
    }
  }

  // ================= 1. OVERVIEW SIBLING DESTINATION =================
  Widget _buildOverviewContent() {
    return ValueListenableBuilder<List<TripModel>>(
      valueListenable: TripRepository.instance.tripsNotifier,
      builder: (context, _, _) {
        final groupTrips = TripRepository.instance.tripsForGroup(widget.groupName);
        final upcoming = groupTrips.isNotEmpty ? groupTrips.first : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // O04 Overview summary panel organism
            OverviewSummaryPanel(
              availableToday: '5/7',
              upcomingTrips: '${groupTrips.length + 1}',
              totalExpenses: 'P50,000',
              destinations: '4',
            ),
            const SizedBox(height: 24),

            // Upcoming Trip Section
            Text(
              'Upcoming Trip',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.secondaryDark,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),

            // O03 Trip summary card organism
            if (upcoming != null)
              TripSummaryCard(
                title: upcoming.name,
                location: upcoming.destination,
                groupLabel: upcoming.groupGoingLabel,
                dateRange: upcoming.dateRangeLabel,
                onTap: () => Navigator.pushNamed(context, AppRoutes.tripOverview),
              ),
          ],
        );
      },
    );
  }

  // ================= 2. TRIPS SIBLING DESTINATION =================
  Widget _buildTripsContent() {
    return ValueListenableBuilder<List<TripModel>>(
      valueListenable: TripRepository.instance.tripsNotifier,
      builder: (context, _, _) {
        final groupTrips = TripRepository.instance.tripsForGroup(widget.groupName);
        return Column(
          children: [
            for (int i = 0; i < groupTrips.length; i++) ...[
              TripSummaryCard(
                title: groupTrips[i].name,
                location: groupTrips[i].destination,
                groupLabel: groupTrips[i].groupGoingLabel,
                dateRange: groupTrips[i].dateRangeLabel,
                onTap: () => Navigator.pushNamed(context, AppRoutes.tripOverview),
              ),
              if (i < groupTrips.length - 1) const SizedBox(height: 16),
            ],
          ],
        );
      },
    );
  }
}
