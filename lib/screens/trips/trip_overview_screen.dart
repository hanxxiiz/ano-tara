import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../models/trip.dart';
import '../../services/trips_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/trip_widgets.dart';
import 'expenses_screen.dart';
import 'item_details.dart';
import 'itinerary_screen.dart';
import 'map_screen.dart';
import 'members_screen.dart';
import 'plan_trip_flow.dart';

class TripOverviewScreen extends StatefulWidget {
  const TripOverviewScreen({
    super.key,
    required this.tripId,
    TripsRepository? repository,
  }) : _repository = repository;

  final String tripId;
  final TripsRepository? _repository;

  @override
  State<TripOverviewScreen> createState() => _TripOverviewScreenState();
}

class _TripOverviewScreenState extends State<TripOverviewScreen> {
  late final TripsRepository _repo =
      widget._repository ?? TripsRepository.instance;

  /// Re-evaluates Happening Now / Up Next as time passes.
  late final Timer _clock;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(minutes: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _clock.cancel();
    super.dispose();
  }

  Future<void> _rename(Trip trip) async {
    final renamed = await showDialog<bool>(
      context: context,
      builder: (_) => _RenameDialog(trip: trip, repository: _repo),
    );
    if (renamed == true && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Trip renamed.')));
    }
  }

  void _openItinerary(Trip trip) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ItineraryScreen(tripId: trip.id, repository: _repo),
      ),
    );
  }

  void _onTabSelected(AppTab tab) {
    switch (tab) {
      case AppTab.trips:
        Navigator.of(context).popUntil(
          (route) => route.isFirst || route.settings.name == AppRoutes.trips,
        );
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
      appBar: TripsTopBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        current: AppTab.trips,
        onTabSelected: _onTabSelected,
        onPlanTrip: () => startPlanTrip(context, _repo),
      ),
      body: ListenableBuilder(
        listenable: _repo,
        builder: (context, _) {
          final trip = _repo.tripById(widget.tripId);
          if (trip == null) {
            return const Center(child: Text('This trip no longer exists.'));
          }
          final now = DateTime.now();
          final happening = trip.happeningAt(now);
          final upNext = trip.nextAfter(now);

          return ListView(
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              _TripHeader(trip: trip, onRename: () => _rename(trip)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ShortcutGrid(
                      onItinerary: () => _openItinerary(trip),
                      onExpenses: () => Navigator.of(context).push(
                        ExpensesScreen.route(
                          tripId: trip.id,
                          repository: _repo,
                        ),
                      ),
                      onMembers: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              MembersScreen(tripId: trip.id, repository: _repo),
                        ),
                      ),
                      onMap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              MapScreen(tripId: trip.id, repository: _repo),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const SectionHeading('Happening Now'),
                    const SizedBox(height: 12),
                    if (happening != null)
                      ActivityCard(
                        item: happening,
                        onTap: () => showActivityDetails(
                          context,
                          trip: trip,
                          item: happening,
                          repository: _repo,
                        ),
                      )
                    else
                      const EmptyCard(
                        message: 'Nothing is happening right now.',
                      ),
                    const SizedBox(height: 24),
                    const SectionHeading('Up Next'),
                    const SizedBox(height: 12),
                    if (upNext != null)
                      ActivityCard(
                        item: upNext,
                        onTap: () => showActivityDetails(
                          context,
                          trip: trip,
                          item: upNext,
                          repository: _repo,
                        ),
                      )
                    else
                      const EmptyCard(
                        message: 'No more plans on the itinerary.',
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Yellow banner: trip icon, title, group/place/dates, more menu, description.
class _TripHeader extends StatelessWidget {
  const _TripHeader({required this.trip, required this.onRename});

  final Trip trip;
  final VoidCallback onRename;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TripColors.yellow,
        border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 22, 14, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(color: AppColors.ink, width: 2),
                  ),
                  boxShadow: [
                    BoxShadow(color: AppColors.ink, offset: Offset(0, 4)),
                  ],
                ),
                child: const Icon(
                  Icons.flight_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              trip.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          if (trip.isOrganizer)
                            IconButton(
                              tooltip: 'Rename trip',
                              visualDensity: VisualDensity.compact,
                              onPressed: onRename,
                              icon: const Icon(
                                Icons.edit_rounded,
                                size: 18,
                                color: AppColors.ink,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      IconLabel(
                        icon: Icons.groups_rounded,
                        label: trip.group.name,
                        iconColor: AppColors.ink,
                      ),
                      const SizedBox(height: 4),
                      IconLabel(
                        icon: Icons.location_on_rounded,
                        label: trip.destination,
                        iconColor: AppColors.ink,
                      ),
                      const SizedBox(height: 4),
                      IconLabel(
                        icon: Icons.calendar_month_rounded,
                        label: formatDateRange(trip.startDate, trip.endDate),
                        iconColor: AppColors.ink,
                      ),
                      const SizedBox(height: 8),
                      _RolePill(trip: trip),
                    ],
                  ),
                ),
              ),
              _MoreButton(trip: trip),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedCard(
            color: AppColors.field,
            radius: 12,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 55),
              child: Text(
                trip.description.isEmpty
                    ? 'No description yet.'
                    : trip.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.ink,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: AppColors.navy,
        shape: BoxShape.circle,
        border: Border.fromBorderSide(
          BorderSide(color: AppColors.ink, width: 2),
        ),
        boxShadow: [BoxShadow(color: AppColors.ink, offset: Offset(0, 4))],
      ),
      child: PopupMenuButton<String>(
        tooltip: 'More options',
        padding: EdgeInsets.zero,
        icon: const Icon(
          Icons.more_horiz_rounded,
          color: Colors.white,
          size: 20,
        ),
        onSelected: (action) => showComingSoon(context, action),
        itemBuilder: (_) => [
          const PopupMenuItem(
            value: 'Sharing trips',
            child: Text('Share trip'),
          ),
          if (trip.isOrganizer)
            const PopupMenuItem(
              value: 'Deleting trips',
              child: Text('Delete trip'),
            )
          else
            const PopupMenuItem(
              value: 'Leaving trips',
              child: Text('Leave trip'),
            ),
        ],
      ),
    );
  }
}

class _ShortcutGrid extends StatelessWidget {
  const _ShortcutGrid({
    required this.onItinerary,
    required this.onExpenses,
    required this.onMembers,
    required this.onMap,
  });

  final VoidCallback onItinerary;
  final VoidCallback onExpenses;
  final VoidCallback onMembers;
  final VoidCallback onMap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _Shortcut(
                title: 'Itinerary',
                subtitle: 'View and manage plans',
                icon: Icons.event_note_rounded,
                tileColor: AppColors.navy,
                onTap: onItinerary,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _Shortcut(
                title: 'Expenses',
                subtitle: 'Track and split costs',
                icon: Icons.account_balance_wallet_rounded,
                tileColor: AppColors.accent,
                onTap: onExpenses,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _Shortcut(
                title: 'Members',
                subtitle: 'See everyone involved',
                icon: Icons.groups_rounded,
                tileColor: TripColors.yellow,
                onTap: onMembers,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _Shortcut(
                title: 'Map',
                subtitle: 'Keep everyone in sight',
                icon: Icons.map_rounded,
                tileColor: TripColors.purple,
                onTap: onMap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tileColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color tileColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedCard(
      radius: 10,
      onTap: onTap,
      padding: const EdgeInsets.all(9),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 50,
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
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
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 10, color: AppColors.ink),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: AppColors.ink,
          ),
        ],
      ),
    );
  }
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.trip, required this.repository});

  final Trip trip;
  final TripsRepository repository;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final _name = TextEditingController(text: widget.trip.title)
    ..selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.trip.title.length,
    );
  var _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Enter a trip name.');
      return;
    }
    if (name == widget.trip.title) {
      Navigator.of(context).pop(false);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.repository.renameTrip(widget.trip, name);
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = "Couldn't rename the trip. Try again.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.ink, width: 2),
    );
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: OutlinedCard(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeading('Rename trip'),
            const SizedBox(height: 6),
            const Text(
              'What do you want to call this trip?',
              style: TextStyle(fontSize: 13, color: AppColors.ink),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) => _saving ? null : _save(),
              decoration: InputDecoration(
                hintText: 'Trip name',
                errorText: _error,
                filled: true,
                fillColor: AppColors.field,
                border: border,
                enabledBorder: border,
                focusedBorder: border,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                TextButton(
                  onPressed: _saving
                      ? null
                      : () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.ink),
                  ),
                ),
                const Spacer(),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.ink),
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// "Organizer" (yellow-on-navy) or "Member · Organized by X".
class _RolePill extends StatelessWidget {
  const _RolePill({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final organizer = trip.organizer?.shortName;
    final label = trip.isOrganizer
        ? "You're the organizer"
        : organizer == null
        ? 'Member'
        : 'Member · Organized by $organizer';
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: trip.isOrganizer ? AppColors.navy : Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: AppColors.ink, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: trip.isOrganizer ? Colors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }
}
