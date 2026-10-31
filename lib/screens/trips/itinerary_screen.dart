import 'package:flutter/material.dart';

import '../../models/trip.dart';
import '../../services/trips_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/trip_widgets.dart';
import 'item_details.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({
    super.key,
    required this.tripId,
    TripsRepository? repository,
  }) : _repository = repository;

  final String tripId;
  final TripsRepository? _repository;

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  late final TripsRepository _repo =
      widget._repository ?? TripsRepository.instance;
  DateTime? _selectedDay;

  /// Today when the trip is underway, otherwise its first day.
  DateTime _defaultDay(Trip trip) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = trip.days;
    return days.contains(today) ? today : days.first;
  }

  Future<void> _addActivity(Trip trip, DateTime day) async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) =>
          ActivityFormSheet(trip: trip, initialDay: day, repository: _repo),
    );
    if (added == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Added to the itinerary.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _repo,
      builder: (context, _) {
        final trip = _repo.tripById(widget.tripId);
        if (trip == null) {
          return const Scaffold(
            body: Center(child: Text('This trip no longer exists.')),
          );
        }
        final days = trip.days;
        final selected = _selectedDay != null && days.contains(_selectedDay)
            ? _selectedDay!
            : _defaultDay(trip);
        final items = trip.itemsOn(selected);

        return Scaffold(
          appBar: TitleBar(
            title: 'View Itinerary',
            onAdd: () => _addActivity(trip, selected),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(15, 24, 13, 28),
            children: [
              DateTabStrip(
                days: days,
                selected: selected,
                onSelected: (day) => setState(() => _selectedDay = day),
              ),
              const SizedBox(height: 25),
              if (items.isEmpty)
                const EmptyCard(
                  message: 'No plans for this day yet. Tap Add to create one.',
                )
              else
                for (final item in items) ...[
                  ActivityCard(
                    item: item,
                    onTap: () => showActivityDetails(
                      context,
                      trip: trip,
                      item: item,
                      repository: _repo,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
            ],
          ),
        );
      },
    );
  }
}

class ActivityFormSheet extends StatefulWidget {
  const ActivityFormSheet({
    super.key,
    required this.trip,
    required this.initialDay,
    required this.repository,
    this.existing,
  });

  final Trip trip;
  final DateTime initialDay;
  final TripsRepository repository;

  /// Edits this activity instead of adding a new one.
  final ItineraryItem? existing;

  @override
  State<ActivityFormSheet> createState() => _ActivityFormSheetState();
}

class _ActivityFormSheetState extends State<ActivityFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.existing?.title);
  late final _location = TextEditingController(text: widget.existing?.location);
  late var _category = widget.existing?.category ?? ActivityCategory.activity;
  late DateTime _day = _dateOnly(widget.existing?.start ?? widget.initialDay);
  late var _start = widget.existing == null
      ? const TimeOfDay(hour: 9, minute: 0)
      : TimeOfDay.fromDateTime(widget.existing!.start);
  late var _end = widget.existing == null
      ? const TimeOfDay(hour: 10, minute: 0)
      : TimeOfDay.fromDateTime(widget.existing!.end);

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    super.dispose();
  }

  DateTime _combine(TimeOfDay t) =>
      DateTime(_day.year, _day.month, _day.day, t.hour, t.minute);

  bool get _timesValid => _combine(_end).isAfter(_combine(_start));

  Future<void> _pickTime({required bool start}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: start ? _start : _end,
    );
    if (picked == null) return;
    setState(() => start ? _start = picked : _end = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate() || !_timesValid) {
      setState(() {});
      return;
    }
    final existing = widget.existing;
    if (existing != null) {
      widget.repository.updateItineraryItem(
        widget.trip,
        existing,
        title: _title.text.trim(),
        category: _category,
        location: _location.text.trim(),
        start: _combine(_start),
        end: _combine(_end),
      );
    } else {
      widget.repository.addItineraryItem(
        widget.trip,
        title: _title.text.trim(),
        category: _category,
        location: _location.text.trim(),
        start: _combine(_start),
        end: _combine(_end),
      );
    }
    Navigator.of(context).pop(true);
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.ink, width: 2),
    );
    InputDecoration deco(String label) => InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.field,
      border: border,
      enabledBorder: border,
      focusedBorder: border,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeading(
                widget.existing == null ? 'Add to itinerary' : 'Edit activity',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _title,
                validator: _required,
                decoration: deco('Title'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _location,
                validator: _required,
                decoration: deco('Location'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ActivityCategory>(
                initialValue: _category,
                decoration: deco('Category'),
                items: [
                  for (final c in ActivityCategory.values)
                    DropdownMenuItem(value: c, child: Text(c.label)),
                ],
                onChanged: (c) => setState(() => _category = c ?? _category),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<DateTime>(
                initialValue: _day,
                decoration: deco('Day'),
                items: [
                  for (final d in widget.trip.days)
                    DropdownMenuItem(value: d, child: Text(formatShortDate(d))),
                ],
                onChanged: (d) => setState(() => _day = d ?? _day),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickTime(start: true),
                      child: Text('Start ${_start.format(context)}'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickTime(start: false),
                      child: Text('End ${_end.format(context)}'),
                    ),
                  ),
                ],
              ),
              if (!_timesValid)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'End time must be after the start time.',
                    style: TextStyle(fontSize: 12, color: AppColors.accent),
                  ),
                ),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _save,
                child: Text(widget.existing == null ? 'Add' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
