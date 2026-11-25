import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_icon.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../trips/data/trip_repository.dart';
import '../../data/ai_itinerary_service.dart';
import '../../data/itinerary_entry.dart';
import '../../data/place_service.dart';
import '../widgets/itinerary_entry_widgets.dart';
import '../widgets/itinerary_widgets.dart';
import 'ai_itinerary_flow_screen.dart';
import 'entry_added_screen.dart';
import 'itinerary_empty_day_screen.dart';
import 'itinerary_entry_form_screen.dart';
import 'itinerary_location_screens.dart';

/// View Itinerary (07.11 – 07.14): day navigator, the day's entries (or the
/// empty state), Add to Itinerary, select mode with "Delete (N)", and the AI
/// button.
class ItineraryScreen extends StatefulWidget {
  final String? tripId;
  final String destination;

  /// Calendar dates for Day 1…N. Must not be empty.
  final List<DateTime> tripDays;
  final int initialDay;
  final AiItineraryService? aiService;
  final PlaceService? placeService;
  final TripRepository? repository;

  const ItineraryScreen({
    super.key,
    this.tripId,
    required this.destination,
    required this.tripDays,
    this.initialDay = 1,
    this.aiService,
    this.placeService,
    this.repository,
  });

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  late final TripRepository _repo =
      widget.repository ?? TripRepository.instance;
  late int _day = widget.initialDay.clamp(1, widget.tripDays.length);
  bool _selecting = false;
  final Set<String> _selected = {};

  int get _dayCount => widget.tripDays.length;
  DateTime get _date => widget.tripDays[_day - 1];

  List<ItineraryItemModel> get _tripItems =>
      _repo.itineraryItemsForTrip(widget.tripId);

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _goToDay(int day) => setState(() => _day = day);

  void _startSelecting() => setState(() {
        _selecting = true;
        _selected.clear();
      });

  void _stopSelecting() => setState(() {
        _selecting = false;
        _selected.clear();
      });

  void _toggle(String id) => setState(() {
        if (!_selected.remove(id)) _selected.add(id);
      });

  Future<void> _openAdd() async {
    final result = await Navigator.of(context).push<EntryFormResult>(
      MaterialPageRoute(
        builder: (_) => ItineraryEntryFormScreen(
          tripId: widget.tripId,
          destination: widget.destination,
          dayNumber: _day,
          placeService: widget.placeService,
          repository: _repo,
        ),
      ),
    );
    if (result == null || !mounted) return;

    final action = await Navigator.of(context).push<EntryAddedAction>(
      MaterialPageRoute(
        builder: (_) => EntryAddedScreen(item: result.item, date: _date),
      ),
    );
    if (action == EntryAddedAction.addAnother && mounted) _openAdd();
  }

  Future<void> _openEdit(ItineraryItemModel entry) async {
    final result = await Navigator.of(context).push<EntryFormResult>(
      MaterialPageRoute(
        builder: (_) => ItineraryEntryFormScreen(
          tripId: widget.tripId,
          destination: widget.destination,
          dayNumber: entry.dayNumber,
          entry: entry,
          placeService: widget.placeService,
          repository: _repo,
        ),
      ),
    );
    if (result == null || !mounted) return;
    _showMessage(result.deleted ? 'Entry deleted' : 'Changes saved');
  }

  Future<void> _generateWithAi() async {
    final result = await startAiItineraryFlow(
      context: context,
      tripId: widget.tripId,
      destination: widget.destination,
      tripDays: widget.tripDays,
      selectedDay: _day,
      existingItems: _tripItems,
      service: widget.aiService,
    );
    if (result == null || !mounted) return;
    if (result.action == AiItineraryFlowAction.backToTrip) {
      Navigator.of(context).maybePop();
      return;
    }
    // Jump to the first day that got suggestions if this one got none.
    final days = result.savedItems.map((i) => i.dayNumber).toSet();
    if (days.isNotEmpty && !days.contains(_day)) {
      _goToDay((days.toList()..sort()).first.clamp(1, _dayCount));
    }
  }

  Future<void> _deleteSelected() async {
    final count = _selected.length;
    if (count == 0) return;
    final confirmed = await showDeleteEntriesSheet(
      context: context,
      title: 'Delete Entries',
      message: '${count == 1 ? '1 entry' : '$count entries'} will be '
          'permanently removed from Day $_day. This can\'t be undone.',
    );
    if (!confirmed || !mounted) return;
    await _repo.deleteItineraryItems(_selected.toList());
    if (!mounted) return;
    _stopSelecting();
    _showMessage(count == 1 ? 'Deleted 1 entry' : 'Deleted $count entries');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ItineraryItemModel>>(
      valueListenable: _repo.manualItineraryItemsNotifier,
      builder: (context, _, _) {
        final entries = entriesForDay(_tripItems, _day);
        // Drop selections for entries that no longer exist.
        _selected.removeWhere((id) => !entries.any((e) => e.id == id));
        final allSelected =
            entries.isNotEmpty && _selected.length == entries.length;

        return PopScope(
          canPop: !_selecting,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && _selecting) _stopSelecting();
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: _selecting
                ? _selectionAppBar(entries, allSelected)
                : itineraryAppBar(context, 'View Itinerary'),
            body: SafeArea(
              top: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(13, 18, 13, 0),
                    child: ItineraryDayHeader(
                      dayNumber: _day,
                      dayCount: _dayCount,
                      date: _date,
                      muted: _selecting,
                      onPrevious: _day > 1 ? () => _goToDay(_day - 1) : null,
                      onNext: _day < _dayCount
                          ? () => _goToDay(_day + 1)
                          : null,
                    ),
                  ),
                  Expanded(
                    child: entries.isEmpty && !_selecting
                        ? ItineraryEmptyDayBody(
                            dayNumber: _day,
                            onGenerateWithAi: _generateWithAi,
                            onAddManually: _openAdd,
                          )
                        : _buildEntries(entries),
                  ),
                  if (_selecting)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 15, 24),
                      child: AppButton(
                        key: const ValueKey('delete-selected'),
                        text: 'Delete (${_selected.length})',
                        variant: AppButtonVariant.primaryOrange,
                        customHeight: 50,
                        borderRadius: 16,
                        isDisabled: _selected.isEmpty,
                        iconLeading: const Icon(
                          Iconsax.trash,
                          size: 20,
                          color: AppColors.white,
                        ),
                        onPressed: _deleteSelected,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _selectionAppBar(
    List<ItineraryItemModel> entries,
    bool allSelected,
  ) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        tooltip: 'Cancel selection',
        icon: const Icon(
          Icons.close_rounded,
          color: AppColors.primaryOrange,
        ),
        onPressed: _stopSelecting,
      ),
      title: Text(
        '${_selected.length} Selected',
        style: AppTypography.h3.copyWith(color: AppColors.primaryOrange),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: Center(
            child: AppButton(
              text: allSelected ? 'Deselect All' : 'Select All',
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.small,
              isFullWidth: false,
              width: 112,
              customHeight: 36,
              borderRadius: 10,
              onPressed: entries.isEmpty
                  ? null
                  : () => setState(() {
                        if (allSelected) {
                          _selected.clear();
                        } else {
                          _selected
                            ..clear()
                            ..addAll(entries.map((e) => e.id));
                        }
                      }),
            ),
          ),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: AppColors.secondaryDark),
      ),
    );
  }

  Widget _buildEntries(List<ItineraryItemModel> entries) {
    final headingColor =
        _selecting ? AppColors.shayne : AppColors.secondaryDark;
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(15, 22, 13, 120),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Entries',
                    style: AppTypography.h1.copyWith(
                      color: headingColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                    ),
                  ),
                ),
                if (!_selecting && entries.isNotEmpty)
                  ItinerarySelectChip(onTap: _startSelecting),
              ],
            ),
            const SizedBox(height: 16),
            for (final entry in entries) ...[
              _entryCard(entry),
              const SizedBox(height: 24),
            ],
            if (!_selecting) AddToItineraryTile(onTap: _openAdd),
          ],
        ),
        if (!_selecting)
          Positioned(
            right: 13,
            bottom: 24,
            child: ItineraryAiFab(onPressed: _generateWithAi),
          ),
      ],
    );
  }

  Widget _entryCard(ItineraryItemModel entry) {
    final selected = _selected.contains(entry.id);
    return ItineraryEntryCard(
      key: ValueKey('entry-${entry.id}'),
      category: entry.category,
      title: entry.title,
      location: entry.location,
      timeRange: entry.timeRange,
      background: _selecting && selected
          ? AppColors.secondaryLight
          : AppColors.white,
      semanticLabel: _selecting
          ? '${selected ? 'Deselect' : 'Select'} ${entry.title}'
          : 'Edit ${entry.title}',
      onTap: _selecting ? () => _toggle(entry.id) : () => _openEdit(entry),
      trailing: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: _selecting
              ? (selected
                  ? const AppIcon(
                      Iconsax.tick_square5,
                      size: 24,
                      color: AppColors.secondaryDark,
                    )
                  : const Icon(
                      Iconsax.stop,
                      size: 24,
                      color: AppColors.secondaryDark,
                    ))
              : const Icon(
                  Iconsax.arrow_right_3,
                  size: 20,
                  color: AppColors.secondaryDark,
                ),
        ),
      ),
    );
  }
}
