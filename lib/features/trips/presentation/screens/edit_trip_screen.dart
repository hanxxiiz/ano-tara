import 'package:flutter/material.dart';

import '../../../../components/atoms/app_button.dart';
import '../../../../components/organisms/app_top_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../models/group_models.dart';
import '../../../itinerary/data/place_service.dart';
import '../../data/trip_repository.dart';
import '../widgets/trip_form_widgets.dart';

PreferredSizeWidget _topBar(String title) => PreferredSize(
  preferredSize: const Size.fromHeight(57),
  child: Column(
    children: [
      AppTopBar(title: title),
      const ColoredBox(
        color: AppColors.secondaryDark,
        child: SizedBox(height: 1, width: double.infinity),
      ),
    ],
  ),
);

/// Edit Trip: the trip essentials plus who's coming. Pops with the updated
/// [GroupTrip] on Save Changes, or null on Cancel / back.
class EditTripScreen extends StatefulWidget {
  final GroupDetails group;
  final GroupTrip trip;
  final PlaceService? placeService;
  final TripRepository? repository;

  const EditTripScreen({
    super.key,
    required this.group,
    required this.trip,
    this.placeService,
    this.repository,
  });

  @override
  State<EditTripScreen> createState() => _EditTripScreenState();
}

class _EditTripScreenState extends State<EditTripScreen> {
  late final TripRepository _repo =
      widget.repository ?? TripRepository.instance;
  late final _essentials = TripEssentialsController(trip: widget.trip);
  late Set<String> _selectedIds = {
    for (final m in TripParticipantsPicker.pickable(widget.group))
      if (widget.trip.memberNames.contains(m.name)) m.id,
  };
  bool _saving = false;

  @override
  void dispose() {
    _essentials.dispose();
    super.dispose();
  }

  Future<void> _editParticipants() async {
    final ids = await Navigator.of(context).push<Set<String>>(
      MaterialPageRoute(
        builder: (_) => _ParticipantsScreen(
          group: widget.group,
          initial: _selectedIds,
          start: _essentials.startDate,
          end: _essentials.endDate,
        ),
      ),
    );
    if (ids != null && mounted) setState(() => _selectedIds = ids);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (_saving || !_essentials.validate()) return;
    setState(() => _saving = true);

    final e = _essentials;
    final me = widget.group.currentUser ?? GroupMember.me;
    final going = [
      for (final m in TripParticipantsPicker.pickable(widget.group))
        if (_selectedIds.contains(m.id)) m,
    ];
    final updated = widget.trip.copyWith(
      title: e.name.text.trim(),
      location: e.destination!.name.trim(),
      startDate: e.startDate,
      endDate: e.endDate,
      status: widget.trip.status == TripStatus.cancelled
          ? TripStatus.cancelled
          : tripStatusFor(e.startDate!, e.endDate!),
      memberNames: [me.name, for (final m in going) m.name],
      meetingPlace: e.meetingPlace.text.trim(),
      description: e.description.text.trim(),
    );

    await _repo.updateTripDetails(
      tripId: updated.id,
      name: updated.title,
      destination: updated.location,
      startDate: formatTripDate(updated.startDate),
      endDate: formatTripDate(updated.endDate),
      meetingPlace: updated.meetingPlace,
      description: updated.description,
      members: [
        TripMemberModel(name: me.name, role: 'Organizer'),
        for (final m in going) TripMemberModel(name: m.name, role: 'Member'),
      ],
    );
    if (mounted) Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final going = [
      for (final m in TripParticipantsPicker.pickable(widget.group))
        if (_selectedIds.contains(m.id)) m.name,
    ];

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _topBar('Edit Trip'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: [
          TripEssentialsFields(
            controller: _essentials,
            placeService: widget.placeService,
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Who\'s coming',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                key: const ValueKey('edit-participants'),
                onPressed: _editParticipants,
                child: Text(
                  'Edit',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            going.isEmpty
                ? 'Just you so far.'
                : 'You, ${going.join(', ')}',
            style: AppTypography.bodySmall.copyWith(color: AppColors.slate),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                key: const ValueKey('trip-save'),
                text: 'Save Changes',
                borderRadius: 16,
                customHeight: 50,
                isLoading: _saving,
                onPressed: _save,
              ),
              const SizedBox(height: 18),
              AppButton(
                text: 'Cancel',
                variant: AppButtonVariant.secondary,
                borderRadius: 16,
                customHeight: 50,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-screen Who's coming picker used from Edit Trip. Pops with the ids.
class _ParticipantsScreen extends StatefulWidget {
  final GroupDetails group;
  final Set<String> initial;
  final DateTime? start;
  final DateTime? end;

  const _ParticipantsScreen({
    required this.group,
    required this.initial,
    this.start,
    this.end,
  });

  @override
  State<_ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends State<_ParticipantsScreen> {
  late Set<String> _ids = {...widget.initial};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _topBar('Who\'s coming?'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
        children: [
          TripParticipantsPicker(
            group: widget.group,
            selectedIds: _ids,
            onChanged: (ids) => setState(() => _ids = ids),
            start: widget.start,
            end: widget.end,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: AppButton(
            text: 'Done',
            borderRadius: 16,
            customHeight: 50,
            onPressed: () => Navigator.of(context).pop(_ids),
          ),
        ),
      ),
    );
  }
}
