import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../models/trip.dart';
import '../../services/trips_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/trip_widgets.dart';
import 'plan_trip_flow.dart';
import 'trip_overview_screen.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key, TripsRepository? repository})
    : _repository = repository;

  final TripsRepository? _repository;

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  late final TripsRepository _repo =
      widget._repository ?? TripsRepository.instance;
  final _search = TextEditingController();

  /// Empty means "all statuses".
  Set<TripStatus> _statusFilter = {};

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Trip> _visibleTrips() {
    final query = _search.text.trim().toLowerCase();
    final now = DateTime.now();
    return _repo.trips.where((trip) {
      if (_statusFilter.isNotEmpty &&
          !_statusFilter.contains(trip.statusAt(now))) {
        return false;
      }
      if (query.isEmpty) return true;
      return trip.title.toLowerCase().contains(query) ||
          trip.destination.toLowerCase().contains(query) ||
          trip.group.name.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _openFilter() async {
    final result = await showModalBottomSheet<Set<TripStatus>>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) => _FilterSheet(initial: _statusFilter),
    );
    if (result != null) setState(() => _statusFilter = result);
  }

  void _onTabSelected(AppTab tab) {
    switch (tab) {
      case AppTab.trips:
        return;
      case AppTab.home:
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
      case AppTab.groups:
        showComingSoon(context, 'Groups');
      case AppTab.profile:
        showComingSoon(context, 'Profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TripsTopBar(),
      bottomNavigationBar: AppBottomNav(
        current: AppTab.trips,
        onTabSelected: _onTabSelected,
        onPlanTrip: () => startPlanTrip(context, _repo),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([_repo, _search]),
        builder: (context, _) {
          final trips = _visibleTrips();
          return ListView(
            padding: const EdgeInsets.fromLTRB(17, 21, 15, 24),
            children: [
              Row(
                children: [
                  Expanded(child: _SearchField(controller: _search)),
                  const SizedBox(width: 11),
                  _FilterButton(
                    activeCount: _statusFilter.length,
                    onPressed: _openFilter,
                  ),
                ],
              ),
              const SizedBox(height: 21),
              if (trips.isEmpty)
                _NoTrips(
                  filtered: _search.text.isNotEmpty || _statusFilter.isNotEmpty,
                  onPlanTrip: () => startPlanTrip(context, _repo),
                )
              else
                for (final trip in trips) ...[
                  _TripCard(
                    trip: trip,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TripOverviewScreen(
                          tripId: trip.id,
                          repository: _repo,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                ],
            ],
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return OutlinedCard(
      color: AppColors.field,
      radius: 14,
      child: SizedBox(
        height: 51,
        child: Row(
          children: [
            const SizedBox(width: 18),
            const Icon(Icons.search_rounded, color: AppColors.ink, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 13, color: AppColors.ink),
                decoration: const InputDecoration(
                  hintText: 'Search trips...',
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.ink),
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),
            if (controller.text.isNotEmpty)
              IconButton(
                tooltip: 'Clear search',
                onPressed: controller.clear,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.ink,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.activeCount, required this.onPressed});

  final int activeCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Filter trips',
      child: OutlinedCard(
        color: TripColors.yellow,
        radius: 14,
        onTap: onPressed,
        child: SizedBox(
          width: 67,
          height: 51,
          child: Badge(
            isLabelVisible: activeCount > 0,
            label: Text('$activeCount'),
            backgroundColor: AppColors.accent,
            alignment: const AlignmentDirectional(0.5, -0.6),
            child: const Center(
              child: Icon(
                Icons.filter_alt_rounded,
                color: AppColors.ink,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial});

  final Set<TripStatus> initial;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late final Set<TripStatus> _selected = {...widget.initial};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeading('Filter trips'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final status in TripStatus.values)
                  FilterChip(
                    label: Text(status.label),
                    selected: _selected.contains(status),
                    selectedColor: TripColors.yellow,
                    checkmarkColor: AppColors.ink,
                    side: const BorderSide(color: AppColors.ink, width: 1.5),
                    onSelected: (on) => setState(
                      () =>
                          on ? _selected.add(status) : _selected.remove(status),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(<TripStatus>{}),
                  child: const Text('Clear'),
                ),
                const Spacer(),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.ink),
                  onPressed: () => Navigator.of(context).pop(_selected),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip, required this.onTap});

  final Trip trip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = trip.statusAt(DateTime.now());
    return OutlinedCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cover: the design uses a destination photo; trips have no photo
          // yet, so this is a navy band with the status.
          Container(
            height: 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.navy, Color(0xFF3C6FA8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(
                bottom: BorderSide(color: AppColors.ink, width: 2),
              ),
            ),
            alignment: Alignment.topRight,
            padding: const EdgeInsets.all(10),
            child: _StatusPill(status),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      IconLabel(
                        icon: Icons.location_on_rounded,
                        label: trip.destination,
                        fontSize: 12,
                      ),
                      const SizedBox(height: 4),
                      IconLabel(
                        icon: Icons.groups_rounded,
                        label:
                            '${trip.group.name} (${trip.group.memberCount} going)',
                        fontSize: 12,
                      ),
                      const SizedBox(height: 4),
                      IconLabel(
                        icon: Icons.calendar_month_rounded,
                        label: formatDateRange(trip.startDate, trip.endDate),
                        fontSize: 12,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: AppColors.ink),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill(this.status);

  final TripStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      TripStatus.ongoing => AppColors.accent,
      TripStatus.upcoming => TripColors.yellow,
      TripStatus.past => AppColors.field,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.ink, width: 1.5),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: status == TripStatus.ongoing ? Colors.white : AppColors.ink,
        ),
      ),
    );
  }
}

class _NoTrips extends StatelessWidget {
  const _NoTrips({required this.filtered, required this.onPlanTrip});

  final bool filtered;
  final VoidCallback onPlanTrip;

  @override
  Widget build(BuildContext context) {
    if (filtered) {
      return const EmptyCard(message: 'No trips match your search or filters.');
    }
    return OutlinedCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'No trips yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppColors.ink),
            onPressed: onPlanTrip,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Plan a trip'),
          ),
        ],
      ),
    );
  }
}
