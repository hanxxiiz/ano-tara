import 'package:flutter/material.dart';

import '../../models/trip.dart';
import '../../services/trips_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/trip_widgets.dart';
import 'trip_overview_screen.dart';

/// Asks which group the trip is for, then opens the Plan a Trip screen.
Future<void> startPlanTrip(BuildContext context, TripsRepository repo) async {
  final group = await showDialog<TripGroup>(
    context: context,
    builder: (_) => _ChooseGroupDialog(groups: repo.groups),
  );
  if (group == null || !context.mounted) return;

  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => PlanTripScreen(group: group, repository: repo),
    ),
  );
}

class _ChooseGroupDialog extends StatefulWidget {
  const _ChooseGroupDialog({required this.groups});

  final List<TripGroup> groups;

  @override
  State<_ChooseGroupDialog> createState() => _ChooseGroupDialogState();
}

class _ChooseGroupDialogState extends State<_ChooseGroupDialog> {
  TripGroup? _selected;

  @override
  Widget build(BuildContext context) {
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
            const SectionHeading('Plan a trip'),
            const SizedBox(height: 6),
            const Text(
              'Which group are you planning this trip with?',
              style: TextStyle(fontSize: 13, color: AppColors.ink),
            ),
            const SizedBox(height: 16),
            if (widget.groups.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  "You're not in any groups yet. Create a group first.",
                  style: TextStyle(fontSize: 13, color: TripColors.navIdle),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: widget.groups.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final group = widget.groups[index];
                    final selected = group.id == _selected?.id;
                    return _GroupOption(
                      group: group,
                      selected: selected,
                      onTap: () => setState(() => _selected = group),
                    );
                  },
                ),
              ),
            const SizedBox(height: 18),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.ink),
                  ),
                ),
                const Spacer(),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.ink),
                  onPressed: _selected == null
                      ? null
                      : () => Navigator.of(context).pop(_selected),
                  child: const Text('Continue'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupOption extends StatelessWidget {
  const _GroupOption({
    required this.group,
    required this.selected,
    required this.onTap,
  });

  final TripGroup group;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? TripColors.yellow : AppColors.field,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.ink, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.navy,
                  child: Icon(
                    Icons.groups_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        '${group.memberCount} members',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: AppColors.ink,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Basic trip details for the chosen group.
class PlanTripScreen extends StatefulWidget {
  const PlanTripScreen({
    super.key,
    required this.group,
    TripsRepository? repository,
  }) : _repository = repository;

  final TripGroup group;
  final TripsRepository? _repository;

  @override
  State<PlanTripScreen> createState() => _PlanTripScreenState();
}

class _PlanTripScreenState extends State<PlanTripScreen> {
  late final TripsRepository _repo =
      widget._repository ?? TripsRepository.instance;
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _destination = TextEditingController();
  final _description = TextEditingController();
  DateTimeRange? _dates;
  var _showDateError = false;

  @override
  void dispose() {
    _title.dispose();
    _destination.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
      initialDateRange: _dates,
    );
    if (picked != null) {
      setState(() {
        _dates = picked;
        _showDateError = false;
      });
    }
  }

  void _create() {
    final formOk = _formKey.currentState!.validate();
    setState(() => _showDateError = _dates == null);
    if (!formOk || _dates == null) return;

    final trip = _repo.createTrip(
      title: _title.text.trim(),
      destination: _destination.text.trim(),
      group: widget.group,
      startDate: _dates!.start,
      endDate: _dates!.end,
      description: _description.text.trim(),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TripOverviewScreen(tripId: trip.id, repository: _repo),
      ),
    );
  }

  String? _required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Required' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Plan a Trip',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
        ),
        shape: const Border(bottom: BorderSide(color: Colors.black)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            IconLabel(
              icon: Icons.groups_rounded,
              label:
                  'With ${widget.group.name} (${widget.group.memberCount} members)',
              fontSize: 13,
            ),
            const SizedBox(height: 20),
            _Field(
              controller: _title,
              label: 'Trip name',
              validator: _required,
            ),
            const SizedBox(height: 14),
            _Field(
              controller: _destination,
              label: 'Destination',
              validator: _required,
            ),
            const SizedBox(height: 14),
            OutlinedCard(
              color: AppColors.field,
              radius: 12,
              onTap: _pickDates,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: IconLabel(
                icon: Icons.calendar_month_rounded,
                label: _dates == null
                    ? 'Select dates'
                    : formatDateRange(_dates!.start, _dates!.end),
                fontSize: 14,
              ),
            ),
            if (_showDateError)
              const Padding(
                padding: EdgeInsets.only(top: 6, left: 12),
                child: Text(
                  'Pick the trip dates',
                  style: TextStyle(fontSize: 12, color: AppColors.accent),
                ),
              ),
            const SizedBox(height: 14),
            _Field(
              controller: _description,
              label: 'Description (optional)',
              maxLines: 4,
            ),
            const SizedBox(height: 28),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.ink,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: _create,
              child: const Text('Create trip'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.validator,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.ink, width: 2),
    );
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.field,
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      ),
    );
  }
}
