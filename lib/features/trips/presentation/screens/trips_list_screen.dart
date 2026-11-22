import 'package:flutter/material.dart';
import '../../../../app_routes.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../components/molecules/app_search_filter_bar.dart';
import '../../../../components/organisms/app_bottom_navigation.dart';
import '../../../../components/organisms/app_main_top_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/trip_repository.dart';
import '../widgets/filter_trips_sheet.dart';
import '../widgets/trip_list_card.dart';
import 'trip_overview_screen.dart';

/// Trips List screen matching Figma 07.01:
/// Search bar, Filter button opening Filter Trips sheet (07.03),
/// and Trip Cards with status pills navigating to Trip Overview (07.02).
class TripsListScreen extends StatefulWidget {
  const TripsListScreen({super.key});

  @override
  State<TripsListScreen> createState() => _TripsListScreenState();
}

class _TripsListScreenState extends State<TripsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  TripFilterState _filterState = const TripFilterState();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilterSheet() async {
    final result = await FilterTripsSheet.show(
      context,
      initialFilter: _filterState,
    );
    if (result != null && mounted) {
      setState(() => _filterState = result);
    }
  }

  List<TripModel> _applyFiltersAndSort(List<TripModel> trips) {
    final query = _searchQuery.trim().toLowerCase();

    final filtered = trips.where((trip) {
      // Search query match
      if (query.isNotEmpty) {
        final matchesName = trip.name.toLowerCase().contains(query);
        final matchesDest = trip.destination.toLowerCase().contains(query);
        final matchesGroup = trip.groupName.toLowerCase().contains(query);
        if (!matchesName && !matchesDest && !matchesGroup) return false;
      }

      // Status filter
      if (_filterState.status != null && trip.status != _filterState.status) {
        return false;
      }

      // Role filter
      switch (_filterState.role) {
        case TripRoleFilter.allRoles:
          break;
        case TripRoleFilter.organizedByMe:
          if (!trip.isOrganizer) return false;
          break;
        case TripRoleFilter.joinedTrips:
          if (trip.isOrganizer) return false;
          break;
      }

      return true;
    }).toList();

    // Sort
    switch (_filterState.sortBy) {
      case TripSortOption.dateNewestFirst:
        filtered.sort((a, b) => b.sortDate.compareTo(a.sortDate));
        break;
      case TripSortOption.dateOldestFirst:
        filtered.sort((a, b) => a.sortDate.compareTo(b.sortDate));
        break;
      case TripSortOption.nameAZ:
        filtered.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case TripSortOption.nameZA:
        filtered.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
        break;
    }

    return filtered;
  }

  void _openTripOverview(TripModel trip) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TripOverviewScreen(tripId: trip.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppMainTopBar(
        onNotificationTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.notifications),
      ),
      body: Column(
        children: [
          // Crisp dark divider under top bar matching Figma 07.01
          Container(
            height: 1.5,
            width: double.infinity,
            color: AppColors.secondaryDark,
          ),
          Expanded(
            child: ValueListenableBuilder<List<TripModel>>(
              valueListenable: TripRepository.instance.tripsNotifier,
              builder: (context, allTrips, _) {
                final trips = _applyFiltersAndSort(allTrips);

                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                      sliver: SliverToBoxAdapter(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AppSearchFilterBar(
                              hintText: 'Search trips...',
                              controller: _searchController,
                              onChanged: (value) =>
                                  setState(() => _searchQuery = value),
                              onFilterTap: _openFilterSheet,
                            ),
                            if (_filterState.hasActiveFilters)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryOrange,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.secondaryDark,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (trips.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyTripsView(
                          hasFilters: _filterState.hasActiveFilters ||
                              _searchQuery.isNotEmpty,
                          onReset: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _filterState = const TripFilterState();
                            });
                          },
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
                        sliver: SliverList.separated(
                          itemCount: trips.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 18),
                          itemBuilder: (context, index) {
                            final trip = trips[index];
                            return TripListCard(
                              trip: trip,
                              onTap: () => _openTripOverview(trip),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 1,
        onTabSelected: (index) {
          if (index == 1) return;
          if (index == 0) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            return;
          }
          const labels = ['Home', 'Trips', 'Create trip', 'Groups', 'Profile'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${labels[index]} tapped')),
          );
        },
      ),
    );
  }
}

class _EmptyTripsView extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onReset;

  const _EmptyTripsView({
    required this.hasFilters,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            hasFilters ? 'No matching trips' : 'No trips yet',
            style: AppTypography.h3.copyWith(
              color: AppColors.secondaryDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Try adjusting your search or filter settings to see more trips.'
                : 'Start planning a trip with your group and it will appear here.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.carla),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 20),
            AppButton(
              text: 'Reset Filters',
              variant: AppButtonVariant.primaryNavy,
              isFullWidth: false,
              customHeight: 44,
              borderRadius: 14,
              onPressed: onReset,
            ),
          ],
        ],
      ),
    );
  }
}
