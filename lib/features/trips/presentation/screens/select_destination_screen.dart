import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_icon.dart';
import '../../../../components/organisms/app_top_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../itinerary/data/place_service.dart';
import '../../../itinerary/presentation/widgets/itinerary_map.dart';

/// Select Destination: map with a search bar and a "Selected Location"
/// sheet. Pops with the confirmed [PlaceResult], or null on Cancel / back.
class SelectDestinationScreen extends StatefulWidget {
  final PlaceResult? initial;
  final PlaceService? placeService;

  const SelectDestinationScreen({super.key, this.initial, this.placeService});

  @override
  State<SelectDestinationScreen> createState() =>
      _SelectDestinationScreenState();
}

class _SelectDestinationScreenState extends State<SelectDestinationScreen> {
  // Roughly the middle of the Philippines, zoomed out.
  static const _defaultLat = 11.8;
  static const _defaultLng = 122.6;

  late final PlaceService _service = widget.placeService ?? defaultPlaceService;
  late final _query = TextEditingController(
    text: widget.initial?.hasCoordinates == true ? '' : widget.initial?.name,
  );
  late PlaceResult? _selected = widget.initial;
  List<PlaceResult> _popular = const [];
  List<PlaceResult> _results = const [];
  bool _showResults = false;
  int _token = 0;

  @override
  void initState() {
    super.initState();
    _service.popularDestinations().then((list) {
      if (mounted) setState(() => _popular = list);
    });
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _onQueryChanged(String text) async {
    final token = ++_token;
    setState(() => _showResults = text.trim().isNotEmpty);
    final results = await _service.search('', text);
    if (!mounted || token != _token) return;
    setState(() => _results = results);
  }

  void _select(PlaceResult place) {
    FocusScope.of(context).unfocus();
    setState(() {
      _selected = place;
      _showResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    final pins = <PlaceResult>[
      ..._popular,
      for (final r in _results)
        if (!_popular.any((p) => p.id == r.id)) r,
      if (selected != null &&
          selected.hasCoordinates &&
          !_popular.any((p) => p.id == selected.id) &&
          !_results.any((r) => r.id == selected.id))
        selected,
    ].where((p) => p.hasCoordinates).toList();
    final focus = selected != null && selected.hasCoordinates;
    final typed = _query.text.trim();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(57),
        child: Column(
          children: [
            AppTopBar(title: 'Select Destination'),
            ColoredBox(
              color: AppColors.secondaryDark,
              child: SizedBox(height: 1, width: double.infinity),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ItineraryMap(
                    centerLatitude: focus ? selected.latitude! : _defaultLat,
                    centerLongitude: focus ? selected.longitude! : _defaultLng,
                    zoom: focus ? 12 : 5.5,
                    highlightedId: selected?.id,
                    pins: [
                      for (final p in pins)
                        ItineraryMapPin(
                          id: p.id,
                          latitude: p.latitude!,
                          longitude: p.longitude!,
                          label: p.name,
                        ),
                    ],
                    onPinTap: (pin) =>
                        _select(pins.firstWhere((p) => p.id == pin.id)),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  top: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SearchBar(
                        controller: _query,
                        onChanged: _onQueryChanged,
                        onClear: () {
                          _query.clear();
                          _onQueryChanged('');
                        },
                      ),
                      if (_showResults) ...[
                        const SizedBox(height: 8),
                        _ResultsCard(
                          results: _results,
                          typed: typed,
                          onSelect: _select,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          _SelectedLocationSheet(
            place: selected,
            onConfirm: selected == null
                ? null
                : () => Navigator.of(context).pop(selected),
            onCancel: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(14),
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
          const SizedBox(width: 14),
          const Icon(
            Iconsax.search_normal_1,
            size: 20,
            color: AppColors.secondaryDark,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              key: const ValueKey('destination-search'),
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.secondaryDark,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search a destination',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.shayne,
                ),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              tooltip: 'Clear search',
              onPressed: onClear,
              icon: const Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.secondaryDark,
              ),
            ),
        ],
      ),
    );
  }
}

class _ResultsCard extends StatelessWidget {
  final List<PlaceResult> results;
  final String typed;
  final ValueChanged<PlaceResult> onSelect;

  const _ResultsCard({
    required this.results,
    required this.typed,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      for (final place in results.take(5))
        _ResultRow(
          icon: Iconsax.location5,
          title: place.name,
          subtitle: place.address,
          onTap: () => onSelect(place),
        ),
      if (typed.isNotEmpty)
        _ResultRow(
          icon: Iconsax.edit_25,
          title: 'Use "$typed"',
          subtitle: 'Set as a custom destination',
          onTap: () => onSelect(PlaceResult.custom(typed)),
        ),
    ];

    return Container(
      constraints: const BoxConstraints(maxHeight: 280),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondaryDark, width: 2),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: rows.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, color: AppColors.borderLight),
        itemBuilder: (_, i) => rows[i],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ResultRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            AppIcon(icon, size: 18, color: AppColors.primaryOrange),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.secondaryDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.slate,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// White sheet under the map: "Selected Location", the place card,
/// Confirm Location and Cancel.
class _SelectedLocationSheet extends StatelessWidget {
  final PlaceResult? place;
  final VoidCallback? onConfirm;
  final VoidCallback onCancel;

  const _SelectedLocationSheet({
    required this.place,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 10, 20, 16 + bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
        border: Border(
          top: BorderSide(color: AppColors.secondaryDark, width: 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.secondaryDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Selected Location',
            style: AppTypography.h3.copyWith(
              color: AppColors.secondaryDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          place == null
              ? Text(
                  'Search for a destination or tap a pin on the map.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.slate,
                  ),
                )
              : _PlaceCard(place: place!),
          const SizedBox(height: 18),
          AppButton(
            key: const ValueKey('confirm-destination'),
            text: 'Confirm Location',
            customHeight: 46,
            borderRadius: 14,
            isDisabled: onConfirm == null,
            onPressed: onConfirm,
          ),
          const SizedBox(height: 12),
          AppButton(
            text: 'Cancel',
            variant: AppButtonVariant.secondary,
            customHeight: 46,
            borderRadius: 14,
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final PlaceResult place;

  const _PlaceCard({required this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.secondaryDark, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.secondaryDark,
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.secondaryDark,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: const AppIcon(
              Iconsax.routing5,
              size: 24,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                if (place.address.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const AppIcon(
                        Iconsax.location5,
                        size: 13,
                        color: AppColors.primaryOrange,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          place.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.slate,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (place.rating != null) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const AppIcon(
                        Iconsax.star_15,
                        size: 13,
                        color: AppColors.semanticYellow,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${place.rating!.toStringAsFixed(1)} stars',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.slate,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
