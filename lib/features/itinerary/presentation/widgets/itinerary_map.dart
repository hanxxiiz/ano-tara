import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';

import '../../../../components/atoms/app_icon.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

/// One pin on an [ItineraryMap].
class ItineraryMapPin {
  final String id;
  final double latitude;
  final double longitude;
  final String? label;

  const ItineraryMapPin({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.label,
  });
}

/// OpenStreetMap view with orange pins, used by location search, Confirm
/// Location and View in Map. The highlighted pin is drawn larger and labelled.
class ItineraryMap extends StatefulWidget {
  /// Set to `false` in widget tests, which can't fetch map tiles.
  static bool showTiles = true;

  final double centerLatitude;
  final double centerLongitude;
  final double zoom;
  final List<ItineraryMapPin> pins;
  final String? highlightedId;
  final ValueChanged<ItineraryMapPin>? onPinTap;

  const ItineraryMap({
    super.key,
    required this.centerLatitude,
    required this.centerLongitude,
    this.zoom = 14,
    this.pins = const [],
    this.highlightedId,
    this.onPinTap,
  });

  @override
  State<ItineraryMap> createState() => _ItineraryMapState();
}

class _ItineraryMapState extends State<ItineraryMap> {
  final _controller = MapController();
  bool _ready = false;

  @override
  void didUpdateWidget(ItineraryMap old) {
    super.didUpdateWidget(old);
    final moved = old.centerLatitude != widget.centerLatitude ||
        old.centerLongitude != widget.centerLongitude ||
        old.zoom != widget.zoom;
    if (moved && _ready) {
      _controller.move(
        LatLng(widget.centerLatitude, widget.centerLongitude),
        widget.zoom,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pins = [...widget.pins]
      // Draw the highlighted pin last so it sits on top.
      ..sort((a, b) => (a.id == widget.highlightedId ? 1 : 0)
          .compareTo(b.id == widget.highlightedId ? 1 : 0));

    return ColoredBox(
      color: AppColors.mapLavender,
      child: FlutterMap(
        mapController: _controller,
        options: MapOptions(
          initialCenter: LatLng(widget.centerLatitude, widget.centerLongitude),
          initialZoom: widget.zoom,
          minZoom: 4,
          maxZoom: 18,
          backgroundColor: AppColors.mapLavender,
          onMapReady: () => _ready = true,
        ),
        children: [
          if (ItineraryMap.showTiles)
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.anotara.app',
            ),
          MarkerLayer(
            markers: [
              for (final pin in pins)
                Marker(
                  point: LatLng(pin.latitude, pin.longitude),
                  width: 160,
                  height: 72,
                  alignment: Alignment.topCenter,
                  child: _Pin(
                    pin: pin,
                    highlighted: pin.id == widget.highlightedId,
                    onTap: widget.onPinTap == null
                        ? null
                        : () => widget.onPinTap!(pin),
                  ),
                ),
            ],
          ),
          // Required OSM credit; truncates instead of overflowing.
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              color: const Color(0xCCFFFFFF),
              child: Text(
                '© OpenStreetMap contributors',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: AppColors.secondaryDark,
                  fontSize: 9,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  final ItineraryMapPin pin;
  final bool highlighted;
  final VoidCallback? onTap;

  const _Pin({required this.pin, required this.highlighted, this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = highlighted ? 40.0 : 30.0;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (highlighted && pin.label != null)
            Container(
              margin: const EdgeInsets.only(bottom: 2),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.secondaryDark, width: 1.5),
              ),
              child: Text(
                pin.label!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
          AppIcon(
            Iconsax.location5,
            size: size,
            color: highlighted ? AppColors.primaryOrange : AppColors.primaryNavy,
          ),
        ],
      ),
    );
  }
}
