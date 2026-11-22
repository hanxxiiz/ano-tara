import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_icon.dart';
import '../../../../components/atoms/app_input_field.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/place_service.dart';
import '../widgets/itinerary_map.dart';

/// App bar shared by the itinerary entry screens: back arrow, title, ink rule.
PreferredSizeWidget itineraryAppBar(
  BuildContext context,
  String title, {
  List<Widget> actions = const [],
}) {
  return AppBar(
    backgroundColor: AppColors.background,
    elevation: 0,
    scrolledUnderElevation: 0,
    titleSpacing: 0,
    leading: IconButton(
      tooltip: 'Back',
      icon: const Icon(Iconsax.arrow_left, color: AppColors.secondaryDark),
      onPressed: () => Navigator.of(context).maybePop(),
    ),
    title: Text(
      title,
      style: AppTypography.h3.copyWith(color: AppColors.secondaryDark),
    ),
    actions: actions,
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(height: 1, thickness: 1, color: AppColors.secondaryDark),
    ),
  );
}

/// Location search: search field, map of results and "Top Picks Nearby".
/// Pops with the confirmed [PlaceResult], or `null` if the user backs out.
class LocationSearchScreen extends StatefulWidget {
  final String destination;
  final PlaceService? placeService;

  const LocationSearchScreen({
    super.key,
    required this.destination,
    this.placeService,
  });

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  late final PlaceService _service = widget.placeService ?? defaultPlaceService;
  final _query = TextEditingController();
  List<PlaceResult> _topPicks = const [];
  List<PlaceResult> _results = const [];
  String? _highlightedId;
  int _searchToken = 0;

  bool get _searching => _query.text.trim().isNotEmpty;
  List<PlaceResult> get _shown => _searching ? _results : _topPicks;

  @override
  void initState() {
    super.initState();
    _service.topPicks(widget.destination).then((picks) {
      if (mounted) setState(() => _topPicks = picks);
    });
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _onQueryChanged(String text) async {
    final token = ++_searchToken;
    setState(() => _highlightedId = null);
    final results = await _service.search(widget.destination, text);
    if (!mounted || token != _searchToken) return;
    setState(() => _results = results);
  }

  Future<void> _confirm(PlaceResult place) async {
    setState(() => _highlightedId = place.id);
    final confirmed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ConfirmLocationScreen(
          place: place,
          destination: widget.destination,
          placeService: _service,
        ),
      ),
    );
    if (confirmed == true && mounted) Navigator.of(context).pop(place);
  }

  @override
  Widget build(BuildContext context) {
    final center = _service.centerFor(widget.destination);
    final shown = _shown;
    final typed = _query.text.trim();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: itineraryAppBar(context, 'Search Location'),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: AppInputField(
                controller: _query,
                hint: 'Search places in ${widget.destination}',
                borderRadius: 15,
                prefixIcon: const Icon(
                  Iconsax.search_normal_1,
                  size: 18,
                  color: AppColors.secondaryDark,
                ),
                suffixIcon: typed.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.secondaryDark,
                        ),
                        onPressed: () {
                          _query.clear();
                          _onQueryChanged('');
                        },
                      ),
                onChanged: _onQueryChanged,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _MapFrame(
                height: 200,
                child: ItineraryMap(
                  centerLatitude: center.latitude,
                  centerLongitude: center.longitude,
                  zoom: 13,
                  highlightedId: _highlightedId,
                  pins: [
                    for (final p in shown)
                      if (p.hasCoordinates)
                        ItineraryMapPin(
                          id: p.id,
                          latitude: p.latitude!,
                          longitude: p.longitude!,
                          label: p.name,
                        ),
                  ],
                  onPinTap: (pin) => _confirm(
                    shown.firstWhere((p) => p.id == pin.id),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                children: [
                  Text(
                    _searching ? 'Results' : 'Top Picks Nearby',
                    style: AppTypography.h3.copyWith(
                      color: AppColors.secondaryDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  for (final place in shown) ...[
                    _PlaceRow(
                      place: place,
                      distance: place.hasCoordinates
                          ? formatDistance(
                              distanceKm(
                                center.latitude,
                                center.longitude,
                                place.latitude!,
                                place.longitude!,
                              ),
                            )
                          : null,
                      onTap: () => _confirm(place),
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (_searching && shown.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        'No places match "$typed" near ${widget.destination}.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.slate,
                        ),
                      ),
                    ),
                  if (_searching)
                    _PlaceRow(
                      place: PlaceResult.custom(typed),
                      customLabel: 'Use "$typed" as the location',
                      onTap: () =>
                          Navigator.of(context).pop(PlaceResult.custom(typed)),
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

class _MapFrame extends StatelessWidget {
  final double? height;
  final Widget child;

  const _MapFrame({this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: child,
      ),
    );
  }
}

class _PlaceRow extends StatelessWidget {
  final PlaceResult place;
  final String? distance;
  final String? customLabel;
  final VoidCallback onTap;

  const _PlaceRow({
    required this.place,
    required this.onTap,
    this.distance,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    final details = [
      if (place.kind.isNotEmpty) place.kind,
      if (place.address.isNotEmpty) place.address,
    ].join(' · ');

    return Semantics(
      button: true,
      label: customLabel ?? place.name,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(15),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: customLabel == null
                      ? AppColors.primaryNavy
                      : AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(8),
                  border: customLabel == null
                      ? null
                      : Border.all(color: AppColors.secondaryDark, width: 1.5),
                ),
                alignment: Alignment.center,
                child: AppIcon(
                  customLabel == null ? Iconsax.location5 : Iconsax.edit_25,
                  size: 22,
                  color: customLabel == null
                      ? AppColors.white
                      : AppColors.secondaryDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customLabel ?? place.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    if (customLabel == null && details.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        details,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.slate,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    if (place.rating != null || distance != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (place.rating != null) ...[
                            const AppIcon(
                              Iconsax.star_15,
                              size: 13,
                              color: AppColors.semanticYellow,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              place.rating!.toStringAsFixed(1),
                              style: AppTypography.caption.copyWith(
                                color: AppColors.secondaryDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          if (distance != null)
                            Text(
                              distance!,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.shayne,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Iconsax.arrow_right_3,
                size: 18,
                color: AppColors.secondaryDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom card on the map screens: place name, address, rating.
class _PlaceSummaryCard extends StatelessWidget {
  final String name;
  final String address;
  final double? rating;
  final String? extra;
  final List<Widget> actions;

  const _PlaceSummaryCard({
    required this.name,
    required this.address,
    required this.rating,
    this.extra,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
        border: Border(
          top: BorderSide(color: AppColors.secondaryDark, width: 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: AppTypography.h3.copyWith(
              color: AppColors.secondaryDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const AppIcon(
                Iconsax.location5,
                size: 16,
                color: AppColors.primaryOrange,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  address,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (rating != null || extra != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                if (rating != null) ...[
                  const AppIcon(
                    Iconsax.star_15,
                    size: 16,
                    color: AppColors.semanticYellow,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${rating!.toStringAsFixed(1)} stars',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.secondaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (extra != null)
                  Flexible(
                    child: Text(
                      extra!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.shayne,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            actions[i],
          ],
        ],
      ),
    );
  }
}

/// Confirm Location: the picked place on the map. Pops `true` on confirm.
class ConfirmLocationScreen extends StatelessWidget {
  final PlaceResult place;
  final String destination;
  final PlaceService? placeService;

  const ConfirmLocationScreen({
    super.key,
    required this.place,
    required this.destination,
    this.placeService,
  });

  @override
  Widget build(BuildContext context) {
    final service = placeService ?? defaultPlaceService;
    final center = service.centerFor(destination);
    final lat = place.latitude ?? center.latitude;
    final lng = place.longitude ?? center.longitude;
    final distance = place.hasCoordinates
        ? formatDistance(
            distanceKm(center.latitude, center.longitude, lat, lng),
          )
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: itineraryAppBar(context, 'Confirm Location'),
      body: Column(
        children: [
          Expanded(
            child: ItineraryMap(
              centerLatitude: lat,
              centerLongitude: lng,
              zoom: 16,
              highlightedId: place.id,
              pins: [
                if (place.hasCoordinates)
                  ItineraryMapPin(
                    id: place.id,
                    latitude: lat,
                    longitude: lng,
                    label: place.name,
                  ),
              ],
            ),
          ),
          _PlaceSummaryCard(
            name: place.name,
            address: place.address,
            rating: place.rating,
            extra: distance,
            actions: [
              AppButton(
                text: 'Confirm Location',
                customHeight: 50,
                borderRadius: 16,
                iconLeading: const AppIcon(
                  Iconsax.location_tick5,
                  size: 20,
                  color: AppColors.white,
                ),
                onPressed: () => Navigator.of(context).pop(true),
              ),
              AppButton(
                text: 'Choose Another',
                variant: AppButtonVariant.secondary,
                customHeight: 50,
                borderRadius: 16,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// View in Map: an entry's location on the map.
class ViewInMapScreen extends StatelessWidget {
  final String placeName;
  final String address;
  final double latitude;
  final double longitude;
  final double? rating;

  /// e.g. "Eat at Jollibee · 9:00 AM - 10:00 AM".
  final String? entrySummary;

  const ViewInMapScreen({
    super.key,
    required this.placeName,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.rating,
    this.entrySummary,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: itineraryAppBar(context, 'View in Map'),
      body: Column(
        children: [
          Expanded(
            child: ItineraryMap(
              centerLatitude: latitude,
              centerLongitude: longitude,
              zoom: 16,
              highlightedId: 'entry',
              pins: [
                ItineraryMapPin(
                  id: 'entry',
                  latitude: latitude,
                  longitude: longitude,
                  label: placeName,
                ),
              ],
            ),
          ),
          _PlaceSummaryCard(
            name: placeName,
            address: address,
            rating: rating,
            extra: entrySummary,
            actions: [
              AppButton(
                text: 'Done',
                customHeight: 50,
                borderRadius: 16,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
