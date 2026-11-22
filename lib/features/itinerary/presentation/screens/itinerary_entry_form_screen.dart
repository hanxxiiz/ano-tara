import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_icon.dart';
import '../../../../components/atoms/app_input_field.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../trips/data/trip_repository.dart';
import '../../data/itinerary_entry.dart';
import '../../data/place_service.dart';
import '../widgets/itinerary_entry_widgets.dart';
import 'itinerary_location_screens.dart';

/// What happened on the entry form. `null` from the route means cancelled.
class EntryFormResult {
  final ItineraryItemModel item;
  final bool deleted;

  const EntryFormResult.saved(this.item) : deleted = false;
  const EntryFormResult.deleted(this.item) : deleted = true;
}

/// Add Entry, or Edit Entry when [entry] is given (07.16).
///
/// Type, location, title, start and end time are required; Save stays
/// disabled until they're filled (and, when editing, until something changed).
class ItineraryEntryFormScreen extends StatefulWidget {
  final String? tripId;
  final String destination;
  final int dayNumber;
  final ItineraryItemModel? entry;
  final PlaceService? placeService;
  final TripRepository? repository;

  const ItineraryEntryFormScreen({
    super.key,
    this.tripId,
    required this.destination,
    required this.dayNumber,
    this.entry,
    this.placeService,
    this.repository,
  });

  bool get isEditing => entry != null;

  @override
  State<ItineraryEntryFormScreen> createState() =>
      _ItineraryEntryFormScreenState();
}

class _ItineraryEntryFormScreenState extends State<ItineraryEntryFormScreen> {
  late final TripRepository _repo =
      widget.repository ?? TripRepository.instance;

  ItineraryEntryType? _type;
  String? _placeName;
  String _address = '';
  double? _lat;
  double? _lng;
  double? _rating;
  TimeOfDay? _start;
  TimeOfDay? _end;
  final _title = TextEditingController();
  final _notes = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    if (e != null) {
      _type = ItineraryEntryType.fromCategory(e.category);
      _placeName = e.placeName.isEmpty ? e.location : e.placeName;
      _address = e.location;
      _lat = e.latitude;
      _lng = e.longitude;
      _rating = e.rating;
      _start = ItineraryTime.parse(e.startTime);
      _end = ItineraryTime.parse(e.endTime);
      _title.text = e.title;
      _notes.text = e.notes;
    }
    _initialSignature = _signature();
    _title.addListener(_refresh);
    _notes.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  bool get _endBeforeStart =>
      _start != null &&
      _end != null &&
      ItineraryTime.toMinutes(_end!) <= ItineraryTime.toMinutes(_start!);

  bool get _isComplete =>
      _type != null &&
      (_placeName?.trim().isNotEmpty ?? false) &&
      _title.text.trim().isNotEmpty &&
      _start != null &&
      _end != null &&
      !_endBeforeStart;

  ItineraryItemModel _buildItem() {
    final base = widget.entry;
    final item = ItineraryItemModel(
      id: base?.id ?? 'item-${DateTime.now().microsecondsSinceEpoch}',
      tripId: base?.tripId ?? widget.tripId,
      category: _type!.category,
      placeName: _placeName!.trim(),
      location: _address.isEmpty ? _placeName!.trim() : _address,
      title: _title.text.trim(),
      startTime: ItineraryTime.format(_start!),
      endTime: ItineraryTime.format(_end!),
      notes: _notes.text.trim(),
      dayNumber: base?.dayNumber ?? widget.dayNumber,
      latitude: _lat,
      longitude: _lng,
      rating: _rating,
    );
    return item;
  }

  /// Form values when it opened, to detect edits.
  late final String _initialSignature;

  String _signature() => [
        _type?.name,
        _placeName,
        _address,
        _lat,
        _lng,
        _title.text.trim(),
        _start == null ? '' : ItineraryTime.format(_start!),
        _end == null ? '' : ItineraryTime.format(_end!),
        _notes.text.trim(),
      ].join('|');

  bool get _hasChanges =>
      !widget.isEditing || _signature() != _initialSignature;

  bool get _canSave => _isComplete && _hasChanges && !_saving;

  Future<void> _chooseLocation() async {
    final place = await Navigator.of(context).push<PlaceResult>(
      MaterialPageRoute(
        builder: (_) => LocationSearchScreen(
          destination: widget.destination,
          placeService: widget.placeService,
        ),
      ),
    );
    if (place == null || !mounted) return;
    setState(() {
      _placeName = place.name;
      _address = place.address;
      _lat = place.latitude;
      _lng = place.longitude;
      _rating = place.rating;
    });
  }

  void _viewInMap() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ViewInMapScreen(
          placeName: _placeName!,
          address: _address,
          latitude: _lat!,
          longitude: _lng!,
          rating: _rating,
          entrySummary: _title.text.trim().isEmpty
              ? null
              : _title.text.trim(),
        ),
      ),
    );
  }

  Future<void> _pickTime({required bool start}) async {
    final initial = start
        ? (_start ?? const TimeOfDay(hour: 9, minute: 0))
        : (_end ??
            (_start == null
                ? const TimeOfDay(hour: 10, minute: 0)
                : TimeOfDay(
                    hour: (_start!.hour + 1).clamp(0, 23),
                    minute: _start!.minute,
                  )));
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: start ? 'Start time' : 'End time',
    );
    if (picked == null || !mounted) return;
    setState(() => start ? _start = picked : _end = picked);
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    final item = _buildItem();
    final ItineraryItemModel saved;
    if (widget.isEditing) {
      saved = await _repo.updateItineraryItem(item);
    } else {
      saved = await _repo.saveManualItineraryItem(
        tripId: item.tripId,
        category: item.category,
        placeName: item.placeName,
        location: item.location,
        title: item.title,
        startTime: item.startTime,
        endTime: item.endTime,
        notes: item.notes,
        dayNumber: item.dayNumber,
        latitude: item.latitude,
        longitude: item.longitude,
        rating: item.rating,
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop(EntryFormResult.saved(saved));
  }

  Future<void> _delete() async {
    final entry = widget.entry!;
    final confirmed = await showDeleteEntriesSheet(
      context: context,
      title: 'Delete Entry',
      message: '${entry.title} will be permanently removed from '
          'Day ${entry.dayNumber}\'s itinerary. This can\'t be undone.',
    );
    if (!confirmed || !mounted) return;
    await _repo.deleteItineraryItems([entry.id]);
    if (!mounted) return;
    Navigator.of(context).pop(EntryFormResult.deleted(entry));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: itineraryAppBar(
        context,
        widget.isEditing ? 'Edit Entry' : 'Add Entry',
        actions: [
          if (widget.isEditing)
            IconButton(
              tooltip: 'Delete entry',
              icon: const Icon(
                Iconsax.trash,
                color: AppColors.primaryOrange,
              ),
              onPressed: _delete,
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
          children: [
            const ItineraryFieldLabel('Type', required: true),
            EntryTypeSelector(
              selected: _type,
              onChanged: (t) => setState(() => _type = t),
            ),
            const SizedBox(height: 22),
            const ItineraryFieldLabel('Location', required: true),
            EntryLocationCard(
              placeName: _placeName,
              address: _address,
              rating: _rating,
              onChoose: _chooseLocation,
              onViewInMap: _lat != null && _lng != null ? _viewInMap : null,
            ),
            const SizedBox(height: 26),
            const ItineraryFieldLabel('Title', required: true),
            AppInputField(
              key: const ValueKey('entry-title'),
              controller: _title,
              hint: 'e.g. Eat at Jollibee',
              borderRadius: 15,
            ),
            const SizedBox(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _TimeField(
                    key: const ValueKey('entry-start'),
                    label: 'Start Time',
                    value: _start,
                    onTap: () => _pickTime(start: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimeField(
                    key: const ValueKey('entry-end'),
                    label: 'End Time',
                    value: _end,
                    error: _endBeforeStart ? 'Must be after start' : null,
                    onTap: () => _pickTime(start: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const ItineraryFieldLabel('Notes'),
            AppInputField(
              controller: _notes,
              hint: 'Add details for the group (optional)',
              borderRadius: 15,
              minLines: 5,
              maxLines: 8,
            ),
            const SizedBox(height: 34),
            AppButton(
              key: const ValueKey('entry-save'),
              text: widget.isEditing ? 'Save Changes' : 'Add to Itinerary',
              customHeight: 50,
              borderRadius: 16,
              isLoading: _saving,
              isDisabled: !_canSave,
              onPressed: _save,
            ),
            const SizedBox(height: 18),
            AppButton(
              text: 'Cancel',
              variant: AppButtonVariant.secondary,
              customHeight: 50,
              borderRadius: 16,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final TimeOfDay? value;
  final String? error;
  final VoidCallback onTap;

  const _TimeField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;
    final ink = hasError ? AppColors.primaryOrange : AppColors.secondaryDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ItineraryFieldLabel(label, required: true),
        Semantics(
          button: true,
          label: '$label${value == null ? '' : ', ${ItineraryTime.format(value!)}'}',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              height: 51,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.secondaryLight,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: ink, width: 2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value == null
                          ? 'Select time'
                          : ItineraryTime.format(value!),
                      style: AppTypography.inputText.copyWith(
                        fontSize: 15,
                        fontWeight:
                            value == null ? FontWeight.w500 : FontWeight.w600,
                        color: value == null
                            ? AppColors.shayne
                            : (hasError
                                ? AppColors.primaryOrange
                                : AppColors.secondaryDark),
                      ),
                    ),
                  ),
                  AppIcon(Iconsax.clock5, size: 18, color: ink),
                ],
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            error!,
            style: AppTypography.caption.copyWith(
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
