import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_icon.dart';
import '../../../../components/organisms/app_top_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../models/group_models.dart';
import '../../../itinerary/data/place_service.dart';
import '../../data/trip_repository.dart';
import '../widgets/trip_form_widgets.dart';

/// What the user chose on "Your trip is ready!".
enum TripReadyAction { planItinerary, viewTrip }

/// Popped by [CreateTripScreen] once the trip exists. `null` means the user
/// backed out before creating it.
class CreateTripResult {
  final GroupTrip trip;
  final TripReadyAction action;

  const CreateTripResult(this.trip, this.action);
}

/// Create Trip: 08.01 trip essentials → 08.02 Who's coming → "Your trip is
/// ready!" (Plan Itinerary / View Trip).
class CreateTripScreen extends StatefulWidget {
  final GroupDetails group;
  final PlaceService? placeService;
  final TripRepository? repository;

  const CreateTripScreen({
    super.key,
    required this.group,
    this.placeService,
    this.repository,
  });

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  late final TripRepository _repo =
      widget.repository ?? TripRepository.instance;
  final _essentials = TripEssentialsController();
  Set<String> _selectedIds = {};
  int _step = 0;
  bool _saving = false;

  /// Set once Create Trip succeeds; the ready screen is showing.
  GroupTrip? _created;

  @override
  void dispose() {
    _essentials.dispose();
    super.dispose();
  }

  void _back() {
    if (_created != null) {
      _finish(TripReadyAction.viewTrip);
    } else if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _finish(TripReadyAction action) =>
      Navigator.of(context).pop(CreateTripResult(_created!, action));

  void _continue() {
    FocusScope.of(context).unfocus();
    if (!_essentials.validate()) return;
    setState(() => _step = 1);
  }

  Future<void> _create() async {
    if (_saving) return;
    setState(() => _saving = true);

    final e = _essentials;
    final start = e.startDate!;
    final end = e.endDate!;
    final me = widget.group.currentUser ?? GroupMember.me;
    final going = [
      for (final m in TripParticipantsPicker.pickable(widget.group))
        if (_selectedIds.contains(m.id)) m,
    ];
    final destination = e.destination!.name.trim();

    final saved = await _repo.saveTrip(
      groupName: widget.group.name,
      name: e.name.text.trim(),
      destination: destination,
      startDate: formatTripDate(start),
      endDate: formatTripDate(end),
      meetingPlace: e.meetingPlace.text.trim(),
      description: e.description.text.trim(),
      isAiGenerated: false,
      members: [
        TripMemberModel(name: me.name, role: 'Organizer'),
        for (final m in going) TripMemberModel(name: m.name, role: 'Member'),
      ],
      itineraryItems: const [],
    );
    if (!mounted) return;

    setState(() {
      _saving = false;
      _created = GroupTrip(
        id: saved.id,
        title: e.name.text.trim(),
        location: destination,
        startDate: start,
        endDate: end,
        status: tripStatusFor(start, end),
        memberNames: [me.name, for (final m in going) m.name],
        meetingPlace: e.meetingPlace.text.trim(),
        description: e.description.text.trim(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final done = _created != null;

    return PopScope(
      canPop: _step == 0 && !done,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(57),
          child: Column(
            children: [
              AppTopBar(
                title: 'Create Trip',
                showBackButton: !done,
                onBackPressed: _back,
              ),
              const ColoredBox(
                color: AppColors.secondaryDark,
                child: SizedBox(height: 1, width: double.infinity),
              ),
            ],
          ),
        ),
        body: done
            ? _TripReadyView(trip: _created!)
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                children: _step == 0
                    ? _buildEssentials()
                    : _buildParticipants(),
              ),
        bottomNavigationBar: _buildBottomBar(done),
      ),
    );
  }

  List<Widget> _buildEssentials() => [
    const _StepHeading(
      title: 'Set up your trip essentials',
      subtitle: 'Give your trip a name and fill in a few details. '
          'You can change them later.',
    ),
    const SizedBox(height: 26),
    TripEssentialsFields(
      controller: _essentials,
      placeService: widget.placeService,
    ),
  ];

  List<Widget> _buildParticipants() => [
    const _StepHeading(
      title: 'Who\'s coming?',
      subtitle: 'Tap members to add them to this trip, or select everyone. '
          'Check each person\'s availability before you decide.',
    ),
    const SizedBox(height: 22),
    TripParticipantsPicker(
      group: widget.group,
      selectedIds: _selectedIds,
      onChanged: (ids) => setState(() => _selectedIds = ids),
      start: _essentials.startDate,
      end: _essentials.endDate,
    ),
  ];

  Widget _buildBottomBar(bool done) {
    final List<Widget> buttons;
    if (done) {
      buttons = [
        AppButton(
          text: 'Plan Itinerary',
          customHeight: 50,
          borderRadius: 16,
          onPressed: () => _finish(TripReadyAction.planItinerary),
        ),
        const SizedBox(height: 18),
        AppButton(
          text: 'View Trip',
          variant: AppButtonVariant.secondary,
          customHeight: 50,
          borderRadius: 16,
          onPressed: () => _finish(TripReadyAction.viewTrip),
        ),
      ];
    } else if (_step == 0) {
      buttons = [
        AppButton(
          key: const ValueKey('trip-continue'),
          text: 'Continue',
          customHeight: 56,
          borderRadius: 16,
          iconTrailing: const Icon(
            Iconsax.arrow_right_1,
            size: 20,
            color: AppColors.white,
          ),
          onPressed: _continue,
        ),
      ];
    } else {
      buttons = [
        AppButton(
          key: const ValueKey('trip-create'),
          text: 'Create Trip',
          customHeight: 50,
          borderRadius: 16,
          isLoading: _saving,
          onPressed: _create,
        ),
      ];
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        border: _step == 1 && !done
            ? const Border(top: BorderSide(color: AppColors.secondaryDark))
            : null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: buttons),
        ),
      ),
    );
  }
}

class _StepHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _StepHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.h3.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.black,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

/// "Your trip is ready!"
class _TripReadyView extends StatelessWidget {
  final GroupTrip trip;

  const _TripReadyView({required this.trip});

  @override
  Widget build(BuildContext context) {
    final others = trip.memberNames.length - 1;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppIcon(
              Iconsax.verify5,
              size: 155,
              color: AppColors.primaryOrange,
            ),
            const SizedBox(height: 22),
            Text(
              'Your trip is ready!',
              textAlign: TextAlign.center,
              style: AppTypography.h2.copyWith(
                color: AppColors.secondaryDark,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '${trip.title} to ${trip.location} is set for '
              '${formatTripDate(trip.startDate)} – '
              '${formatTripDate(trip.endDate)}. '
              '${others > 0 ? 'We\'ve let ${others == 1 ? '1 member' : '$others members'} know. ' : ''}'
              'Start planning your itinerary together.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.secondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
