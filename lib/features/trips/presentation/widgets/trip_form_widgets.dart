import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../components/atoms/app_avatar.dart';
import '../../../../components/atoms/app_input_field.dart';
import '../../../../components/molecules/app_bottom_sheet.dart';
import '../../../../components/organisms/availability_calendar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../models/group_models.dart';
import '../../../itinerary/data/place_service.dart';
import '../screens/select_destination_screen.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "Dec 20, 2026"
String formatTripDate(DateTime date) =>
    '${_months[date.month - 1]} ${date.day}, ${date.year}';

/// Upcoming / ongoing / completed for a trip spanning [start]–[end].
TripStatus tripStatusFor(DateTime start, DateTime end, {DateTime? today}) {
  final now = dateOnly(today ?? DateTime.now());
  if (now.isBefore(dateOnly(start))) return TripStatus.upcoming;
  if (now.isAfter(dateOnly(end))) return TripStatus.completed;
  return TripStatus.ongoing;
}

enum TripField { name, destination, startDate, endDate, meetingPlace }

/// Holds the trip essentials (08.01 / Edit Trip) and validates them.
class TripEssentialsController extends ChangeNotifier {
  final name = TextEditingController();
  final meetingPlace = TextEditingController();
  final description = TextEditingController();
  final _destinationText = TextEditingController();
  final _startText = TextEditingController();
  final _endText = TextEditingController();

  PlaceResult? _destination;
  DateTime? _start;
  DateTime? _end;
  final Map<TripField, String> _errors = {};

  TripEssentialsController({GroupTrip? trip}) {
    if (trip != null) {
      name.text = trip.title;
      meetingPlace.text = trip.meetingPlace;
      description.text = trip.description;
      destination = PlaceResult.custom(trip.location);
      startDate = trip.startDate;
      endDate = trip.endDate;
    }
    name.addListener(() => _clear(TripField.name));
    meetingPlace.addListener(() => _clear(TripField.meetingPlace));
  }

  PlaceResult? get destination => _destination;
  set destination(PlaceResult? value) {
    _destination = value;
    _destinationText.text = value?.name ?? '';
    _clear(TripField.destination);
    notifyListeners();
  }

  DateTime? get startDate => _start;
  set startDate(DateTime? value) {
    _start = value == null ? null : dateOnly(value);
    _startText.text = value == null ? '' : formatTripDate(value);
    _clear(TripField.startDate);
    _clear(TripField.endDate);
    notifyListeners();
  }

  DateTime? get endDate => _end;
  set endDate(DateTime? value) {
    _end = value == null ? null : dateOnly(value);
    _endText.text = value == null ? '' : formatTripDate(value);
    _clear(TripField.endDate);
    notifyListeners();
  }

  String? errorFor(TripField field) => _errors[field];

  void _clear(TripField field) {
    if (_errors.remove(field) != null) notifyListeners();
  }

  /// Sets an error on every invalid required field. Returns true when valid.
  bool validate() {
    _errors.clear();
    if (name.text.trim().isEmpty) {
      _errors[TripField.name] = 'Trip name is required';
    }
    if (_destination == null || _destination!.name.trim().isEmpty) {
      _errors[TripField.destination] = 'Choose a destination';
    }
    if (_start == null) {
      _errors[TripField.startDate] = 'Pick a start date';
    }
    if (_end == null) {
      _errors[TripField.endDate] = 'Pick an end date';
    } else if (_start != null && _end!.isBefore(_start!)) {
      _errors[TripField.endDate] = 'Must be on or after the start date';
    }
    if (meetingPlace.text.trim().isEmpty) {
      _errors[TripField.meetingPlace] = 'Meeting place is required';
    }
    notifyListeners();
    return _errors.isEmpty;
  }

  @override
  void dispose() {
    for (final c in [
      name,
      meetingPlace,
      description,
      _destinationText,
      _startText,
      _endText,
    ]) {
      c.dispose();
    }
    super.dispose();
  }
}

/// Field label with an orange asterisk for required fields ("Trip Name*").
class TripFieldLabel extends StatelessWidget {
  final String text;
  final bool isRequired;

  const TripFieldLabel(this.text, {super.key, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.titleMedium.copyWith(
      color: AppColors.secondaryDark,
      fontWeight: FontWeight.w700,
      fontSize: 14,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          text: text,
          style: style,
          children: [
            if (isRequired)
              TextSpan(
                text: '*',
                style: style.copyWith(color: AppColors.primaryOrange),
              ),
          ],
        ),
      ),
    );
  }
}

/// Trip Name, Destination, Start/End Date, Meeting Place, Description.
class TripEssentialsFields extends StatelessWidget {
  final TripEssentialsController controller;
  final PlaceService? placeService;

  const TripEssentialsFields({
    super.key,
    required this.controller,
    this.placeService,
  });

  Future<void> _pickDestination(BuildContext context) async {
    final place = await Navigator.of(context).push<PlaceResult>(
      MaterialPageRoute(
        builder: (_) => SelectDestinationScreen(
          initial: controller.destination,
          placeService: placeService,
        ),
      ),
    );
    if (place != null) controller.destination = place;
  }

  Future<void> _pickDate(BuildContext context, {required bool start}) async {
    final today = dateOnly(DateTime.now());
    final current = start ? controller.startDate : controller.endDate;
    final first = start
        ? DateTime(today.year - 1)
        : (controller.startDate ?? DateTime(today.year - 1));
    var initial = current ?? controller.startDate ?? today;
    if (initial.isBefore(first)) initial = first;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime(today.year + 5, 12, 31),
      helpText: start ? 'Start date' : 'End date',
    );
    if (picked == null) return;
    if (start) {
      controller.startDate = picked;
      // Keep the range valid when the new start is after the old end.
      final end = controller.endDate;
      if (end != null && end.isBefore(picked)) controller.endDate = picked;
    } else {
      controller.endDate = picked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TripFieldLabel('Trip Name', isRequired: true),
          AppInputField(
            key: const ValueKey('trip-name'),
            controller: controller.name,
            hint: 'e.g. Bantayan Getaway',
            borderRadius: 15,
            errorText: controller.errorFor(TripField.name),
          ),
          const SizedBox(height: 22),
          const TripFieldLabel('Destination', isRequired: true),
          AppInputField(
            key: const ValueKey('trip-destination'),
            controller: controller._destinationText,
            hint: 'Search a destination',
            borderRadius: 15,
            isReadOnly: true,
            onTap: () => _pickDestination(context),
            errorText: controller.errorFor(TripField.destination),
            prefixIcon: const Icon(
              Iconsax.location,
              size: 18,
              color: AppColors.secondaryDark,
            ),
            suffixIcon: const Icon(
              Iconsax.arrow_right_3,
              size: 18,
              color: AppColors.secondaryDark,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const TripFieldLabel('Start Date', isRequired: true),
                    AppInputField(
                      key: const ValueKey('trip-start'),
                      controller: controller._startText,
                      hint: 'Select date',
                      borderRadius: 15,
                      isReadOnly: true,
                      onTap: () => _pickDate(context, start: true),
                      errorText: controller.errorFor(TripField.startDate),
                      suffixIcon: const Icon(
                        Iconsax.calendar_1,
                        size: 18,
                        color: AppColors.secondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const TripFieldLabel('End Date', isRequired: true),
                    AppInputField(
                      key: const ValueKey('trip-end'),
                      controller: controller._endText,
                      hint: 'Select date',
                      borderRadius: 15,
                      isReadOnly: true,
                      onTap: () => _pickDate(context, start: false),
                      errorText: controller.errorFor(TripField.endDate),
                      suffixIcon: const Icon(
                        Iconsax.calendar_1,
                        size: 18,
                        color: AppColors.secondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const TripFieldLabel('Meeting Place', isRequired: true),
          AppInputField(
            key: const ValueKey('trip-meeting'),
            controller: controller.meetingPlace,
            hint: 'e.g. North Bus Terminal',
            borderRadius: 15,
            errorText: controller.errorFor(TripField.meetingPlace),
          ),
          const SizedBox(height: 22),
          const TripFieldLabel('Description'),
          AppInputField(
            controller: controller.description,
            hint: 'What\'s this trip about? (optional)',
            borderRadius: 15,
            minLines: 3,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
          ),
        ],
      ),
    );
  }
}

/// Who's coming (08.02): search, "Select all members" and member cards with
/// a checkbox and an availability shortcut.
class TripParticipantsPicker extends StatefulWidget {
  final GroupDetails group;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onChanged;

  /// Trip dates, used to show how many days each member is free.
  final DateTime? start;
  final DateTime? end;

  const TripParticipantsPicker({
    super.key,
    required this.group,
    required this.selectedIds,
    required this.onChanged,
    this.start,
    this.end,
  });

  /// Members who can be picked (everyone except the signed-in organizer,
  /// who always comes along).
  static List<GroupMember> pickable(GroupDetails group) => [
    for (final m in group.members)
      if (!m.isCurrentUser) m,
  ];

  @override
  State<TripParticipantsPicker> createState() =>
      _TripParticipantsPickerState();
}

class _TripParticipantsPickerState extends State<TripParticipantsPicker> {
  final _search = TextEditingController();

  /// Latest selection, so quick taps before the parent rebuilds don't drop
  /// each other's changes.
  late Set<String> _selected = {...widget.selectedIds};

  @override
  void didUpdateWidget(TripParticipantsPicker old) {
    super.didUpdateWidget(old);
    _selected = {...widget.selectedIds};
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _set(Set<String> ids) {
    _selected = ids;
    widget.onChanged({...ids});
  }

  void _toggle(String id) {
    final next = {..._selected};
    if (!next.remove(id)) next.add(id);
    _set(next);
  }

  @override
  Widget build(BuildContext context) {
    final all = TripParticipantsPicker.pickable(widget.group);
    final query = _search.text.trim().toLowerCase();
    final shown = [
      for (final m in all)
        if (query.isEmpty ||
            m.name.toLowerCase().contains(query) ||
            m.handle.toLowerCase().contains(query))
          m,
    ];
    final allSelected =
        all.isNotEmpty && all.every((m) => _selected.contains(m.id));
    final tripDays = widget.start != null && widget.end != null
        ? dateOnly(widget.end!).difference(dateOnly(widget.start!)).inDays + 1
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInputField(
          controller: _search,
          hint: 'Search members...',
          borderRadius: 14,
          prefixIcon: const Icon(
            Iconsax.search_normal_1,
            size: 18,
            color: AppColors.secondaryDark,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: _SelectAllChip(
            selected: allSelected,
            onTap: all.isEmpty
                ? null
                : () => _set(
                    allSelected ? <String>{} : {for (final m in all) m.id},
                  ),
          ),
        ),
        const SizedBox(height: 14),
        if (shown.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              all.isEmpty
                  ? 'Invite members to your group to add them to trips.'
                  : 'No members match "${_search.text.trim()}".',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(color: AppColors.slate),
            ),
          ),
        for (final member in shown)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _ParticipantCard(
              member: member,
              selected: _selected.contains(member.id),
              subtitle: _subtitleFor(member, tripDays),
              onTap: () => _toggle(member.id),
              onAvailabilityTap: () => showMemberAvailabilitySheet(
                context,
                group: widget.group,
                member: member,
                month: widget.start ?? DateTime.now(),
                start: widget.start,
                end: widget.end,
              ),
            ),
          ),
      ],
    );
  }

  String _subtitleFor(GroupMember member, int? tripDays) {
    if (member.isPending) return 'Pending invitation';
    if (tripDays == null) return member.handle;
    final free = widget.group.freeDaysFor(member, widget.start!, widget.end!);
    return 'Free $free of $tripDays trip ${tripDays == 1 ? 'day' : 'days'}';
  }
}

class _SelectAllChip extends StatelessWidget {
  final bool selected;
  final VoidCallback? onTap;

  const _SelectAllChip({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: selected,
      label: 'Select all members',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 39,
          padding: const EdgeInsets.symmetric(horizontal: 7),
          decoration: BoxDecoration(
            color: AppColors.nextTripPill,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.secondaryDark),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CheckBox(checked: selected),
              const SizedBox(width: 9),
              Text(
                'Select all members',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckBox extends StatelessWidget {
  final bool checked;

  const _CheckBox({required this.checked});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: checked ? AppColors.primaryNavy : AppColors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppColors.secondaryDark, width: 2),
      ),
      child: checked
          ? const Icon(Icons.check_rounded, size: 16, color: AppColors.white)
          : null,
    );
  }
}

class _ParticipantCard extends StatelessWidget {
  final GroupMember member;
  final bool selected;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback onAvailabilityTap;

  const _ParticipantCard({
    required this.member,
    required this.selected,
    required this.subtitle,
    required this.onTap,
    required this.onAvailabilityTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: selected,
      label: member.name,
      child: GestureDetector(
        key: ValueKey('participant-${member.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.fromLTRB(15, 15, 8, 15),
          decoration: BoxDecoration(
            color: selected ? AppColors.selectedRowBlue : AppColors.white,
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
            children: [
              AppAvatar.singleUser(size: 40),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.secondaryDark,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'View ${member.name}\'s availability',
                onPressed: onAvailabilityTap,
                icon: const Icon(
                  Iconsax.calendar_1,
                  size: 20,
                  color: AppColors.secondaryDark,
                ),
              ),
              _CheckBox(checked: selected),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }
}

/// 05.13-style sheet: one member's available days for a month, with the
/// trip dates outlined.
Future<void> showMemberAvailabilitySheet(
  BuildContext context, {
  required GroupDetails group,
  required GroupMember member,
  required DateTime month,
  DateTime? start,
  DateTime? end,
}) {
  return showAppBottomSheet<void>(
    context,
    builder: (context) => AppBottomSheet(
      title: 'Availability',
      child: _MemberAvailability(
        group: group,
        member: member,
        initialMonth: DateTime(month.year, month.month),
        start: start,
        end: end,
      ),
    ),
  );
}

class _MemberAvailability extends StatefulWidget {
  final GroupDetails group;
  final GroupMember member;
  final DateTime initialMonth;
  final DateTime? start;
  final DateTime? end;

  const _MemberAvailability({
    required this.group,
    required this.member,
    required this.initialMonth,
    this.start,
    this.end,
  });

  @override
  State<_MemberAvailability> createState() => _MemberAvailabilityState();
}

class _MemberAvailabilityState extends State<_MemberAvailability> {
  late DateTime _month = widget.initialMonth;

  bool _inTrip(DateTime day) =>
      widget.start != null &&
      widget.end != null &&
      !day.isBefore(dateOnly(widget.start!)) &&
      !day.isAfter(dateOnly(widget.end!));

  @override
  Widget build(BuildContext context) {
    final free = widget.group.availability[widget.member.id] ?? const {};
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 6, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.member.name,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.slate),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              AvailabilityMonthNav(
                month: _month,
                onPrevious: () => setState(
                  () => _month = DateTime(_month.year, _month.month - 1),
                ),
                onNext: () => setState(
                  () => _month = DateTime(_month.year, _month.month + 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AvailabilityCalendar(
            month: _month,
            dayStyle: (day) {
              final isFree = free.contains(dateOnly(day));
              final base = isFree
                  ? const AvailabilityDayStyle(fill: AppColors.primaryOrange)
                  : AvailabilityDayStyle.empty;
              return _inTrip(day)
                  ? AvailabilityDayStyle(
                      fill: base.fill,
                      outlined: true,
                      textColor: base.textColor,
                    )
                  : base;
            },
            dayLabel: (day) =>
                free.contains(dateOnly(day)) ? 'Available' : 'Not available',
          ),
          if (free.isEmpty) ...[
            const SizedBox(height: 12),
            Text(
              widget.member.isPending
                  ? 'They haven\'t joined the group yet.'
                  : 'They haven\'t marked their availability yet.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.slate),
            ),
          ],
        ],
      ),
    );
  }
}
