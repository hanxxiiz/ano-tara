import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/trip.dart';
import '../../services/trips_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/trip_widgets.dart';

/// Where markers are placed when nothing has a position yet (Manila).
const _fallbackCenter = GeoPoint(14.5995, 120.9842);

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    required this.tripId,
    TripsRepository? repository,
  }) : _repository = repository;

  final String tripId;
  final TripsRepository? _repository;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final TripsRepository _repo =
      widget._repository ?? TripsRepository.instance;
  var _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final trip = _repo.tripById(widget.tripId);
    if (trip == null || trip.remoteId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _repo.loadMap(trip);
    } catch (_) {
      _error = "Couldn't load the map. Check your connection and try again.";
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _editMeetingPoint(Trip trip, {GeoPoint? movedTo}) async {
    final current = trip.meetingPoint;
    final position = movedTo ?? current?.position ?? _centerOf(trip);
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) => _MeetingPointSheet(
        trip: trip,
        initial:
            current?.copyWith(position: position) ??
            MeetingPoint(name: '', position: position),
        repository: _repo,
        moved: movedTo != null,
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Meeting point updated.')));
    }
  }

  GeoPoint _centerOf(Trip trip) {
    final points = trip.memberLocations.map((l) => l.position).toList();
    if (points.isEmpty) return _fallbackCenter;
    final lat =
        points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
    final lng =
        points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length;
    return GeoPoint(lat, lng);
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
        return Scaffold(
          appBar: const TitleBar(title: 'View Map'),
          body: _body(trip),
        );
      },
    );
  }

  Widget _body(Trip trip) {
    if (_loading) {
      return const _MapBackdrop(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: LoadingCard(message: 'Loading the map…'),
          ),
        ),
      );
    }
    if (_error != null) {
      return _MapBackdrop(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ErrorCard(message: _error!, onRetry: _refresh),
          ),
        ),
      );
    }

    final sharing = trip.memberLocations.length;
    return Stack(
      children: [
        Positioned.fill(
          child: _TripMap(
            trip: trip,
            onLongPress: trip.isOrganizer
                ? (point) => _editMeetingPoint(trip, movedTo: point)
                : null,
          ),
        ),
        Positioned(
          top: 16,
          left: 15,
          right: 15,
          child: OutlinedCard(
            radius: 12,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sharing == 0
                      ? 'No one is sharing their location yet'
                      : '$sharing ${sharing == 1 ? 'member' : 'members'} sharing their location',
                  style: const TextStyle(fontSize: 12, color: AppColors.ink),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 15,
          right: 15,
          bottom: 16,
          child: _MeetingPointCard(
            trip: trip,
            onEdit: trip.isOrganizer ? () => _editMeetingPoint(trip) : null,
          ),
        ),
      ],
    );
  }
}

class _MeetingPointCard extends StatelessWidget {
  const _MeetingPointCard({required this.trip, this.onEdit});

  final Trip trip;

  /// Organizer only; null hides the edit controls.
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final point = trip.meetingPoint;
    Widget legendDot(Color color, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );

    return OutlinedCard(
      radius: 12,
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  point == null
                      ? 'No meeting point yet'
                      : 'Meeting point: ${point.name}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (onEdit != null)
                IconButton(
                  tooltip: point == null
                      ? 'Set meeting point'
                      : 'Edit meeting point',
                  visualDensity: VisualDensity.compact,
                  onPressed: onEdit,
                  icon: Icon(
                    point == null
                        ? Icons.add_location_alt_rounded
                        : Icons.edit_rounded,
                    size: 20,
                    color: AppColors.ink,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (point == null && onEdit == null)
            const Text(
              'The organizer hasn\'t set one.',
              style: TextStyle(fontSize: 12, color: TripColors.navIdle),
            )
          else
            Wrap(
              spacing: 18,
              children: [
                legendDot(AppColors.navy, 'Members'),
                legendDot(AppColors.accent, 'Meeting point'),
              ],
            ),
          if (onEdit != null) ...[
            const SizedBox(height: 6),
            const Text(
              'Long-press the map to move the meeting point.',
              style: TextStyle(fontSize: 11, color: TripColors.navIdle),
            ),
          ],
        ],
      ),
    );
  }
}

/// Lavender background with the illustrated street pattern.
class _MapBackdrop extends StatelessWidget {
  const _MapBackdrop({this.seed = 7, this.child});

  final int seed;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StreetsPainter(seed),
      child: SizedBox.expand(child: child),
    );
  }
}

/// Places member and meeting-point markers on the illustrated map. Positions
/// are scaled to fit the screen, so distances are relative, not to scale.
class _TripMap extends StatelessWidget {
  const _TripMap({required this.trip, this.onLongPress});

  final Trip trip;
  final ValueChanged<GeoPoint>? onLongPress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final projection = _Projection.fit(
          [
            ...trip.memberLocations.map((l) => l.position),
            if (trip.meetingPoint != null) trip.meetingPoint!.position,
          ],
          // Keep markers clear of the top and bottom cards.
          Rect.fromLTRB(
            constraints.maxWidth * 0.14,
            constraints.maxHeight * 0.24,
            constraints.maxWidth * 0.86,
            constraints.maxHeight * 0.74,
          ),
        );

        Widget place(GeoPoint p, Widget marker) {
          final o = projection.toOffset(p);
          return Positioned(
            left: o.dx - 50,
            top: o.dy - 12,
            width: 100,
            child: marker,
          );
        }

        return GestureDetector(
          onLongPressStart: onLongPress == null
              ? null
              : (d) => onLongPress!(projection.toGeo(d.localPosition)),
          child: _MapBackdrop(
            seed: trip.id.hashCode,
            child: Stack(
              children: [
                for (final l in trip.memberLocations)
                  place(
                    l.position,
                    _Marker(
                      color: AppColors.navy,
                      label:
                          trip.group.memberById(l.memberId)?.shortName ??
                          'Member',
                    ),
                  ),
                if (trip.meetingPoint != null)
                  place(
                    trip.meetingPoint!.position,
                    const _Marker(
                      color: AppColors.accent,
                      label: 'Meeting point',
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Projection {
  _Projection(this.minLat, this.minLng, this.latSpan, this.lngSpan, this.area);

  factory _Projection.fit(List<GeoPoint> points, Rect area) {
    if (points.isEmpty) points = [_fallbackCenter];
    var minLat = points.map((p) => p.latitude).reduce(math.min);
    var maxLat = points.map((p) => p.latitude).reduce(math.max);
    var minLng = points.map((p) => p.longitude).reduce(math.min);
    var maxLng = points.map((p) => p.longitude).reduce(math.max);
    // A single point (or points very close together) sits in the middle.
    const minSpan = 0.002;
    if (maxLat - minLat < minSpan) {
      final mid = (minLat + maxLat) / 2;
      minLat = mid - minSpan / 2;
      maxLat = mid + minSpan / 2;
    }
    if (maxLng - minLng < minSpan) {
      final mid = (minLng + maxLng) / 2;
      minLng = mid - minSpan / 2;
      maxLng = mid + minSpan / 2;
    }
    return _Projection(minLat, minLng, maxLat - minLat, maxLng - minLng, area);
  }

  final double minLat;
  final double minLng;
  final double latSpan;
  final double lngSpan;
  final Rect area;

  Offset toOffset(GeoPoint p) => Offset(
    area.left + (p.longitude - minLng) / lngSpan * area.width,
    area.bottom - (p.latitude - minLat) / latSpan * area.height,
  );

  GeoPoint toGeo(Offset o) => GeoPoint(
    minLat + (area.bottom - o.dy) / area.height * latSpan,
    minLng + (o.dx - area.left) / area.width * lngSpan,
  );
}

class _Marker extends StatelessWidget {
  const _Marker({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label == 'Meeting point' ? label : '$label\'s location',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(height: 4),
          ExcludeSemantics(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.ink),
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: AppColors.ink),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorative streets: a few thick avenues and a mesh of side streets,
/// generated from [seed] so each trip's map looks the same every time.
class _StreetsPainter extends CustomPainter {
  _StreetsPainter(this.seed);

  final int seed;

  static const _background = Color(0xFFE9E9FB);
  static const _street = Color(0xFF8592F2);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _background);
    final rnd = math.Random(seed);
    final thin = Paint()
      ..color = _street
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 26; i++) {
      final start = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      final path = Path()..moveTo(start.dx, start.dy);
      var p = start;
      var angle = rnd.nextDouble() * math.pi * 2;
      for (var s = 0; s < 4; s++) {
        angle += (rnd.nextDouble() - 0.5) * 1.2;
        final len = 40 + rnd.nextDouble() * 90;
        p = p + Offset(math.cos(angle) * len, math.sin(angle) * len);
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, thin);
    }

    final thick = Paint()
      ..color = _street
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final avenue = Path()
      ..moveTo(-20, size.height * (0.75 + rnd.nextDouble() * 0.2))
      ..cubicTo(
        size.width * 0.35,
        size.height * 0.55,
        size.width * 0.5,
        size.height * 0.4,
        size.width + 20,
        size.height * (0.15 + rnd.nextDouble() * 0.15),
      );
    canvas.drawPath(avenue, thick);
    final side = Path()
      ..moveTo(size.width * (0.55 + rnd.nextDouble() * 0.3), -20)
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.3,
        size.width + 20,
        size.height * 0.45,
      );
    canvas.drawPath(side, thick..strokeWidth = 8);
  }

  @override
  bool shouldRepaint(_StreetsPainter oldDelegate) => oldDelegate.seed != seed;
}

class _MeetingPointSheet extends StatefulWidget {
  const _MeetingPointSheet({
    required this.trip,
    required this.initial,
    required this.repository,
    required this.moved,
  });

  final Trip trip;
  final MeetingPoint initial;
  final TripsRepository repository;
  final bool moved;

  @override
  State<_MeetingPointSheet> createState() => _MeetingPointSheetState();
}

class _MeetingPointSheetState extends State<_MeetingPointSheet> {
  late final _name = TextEditingController(text: widget.initial.name);
  var _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Give the meeting point a name.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.repository.setMeetingPoint(
        widget.trip,
        widget.initial.copyWith(name: name),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = "Couldn't save the meeting point. Try again.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.ink, width: 2),
    );
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeading(
              widget.moved ? 'Move meeting point here' : 'Meeting point',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Name',
                errorText: _error,
                filled: true,
                fillColor: AppColors.field,
                border: border,
                enabledBorder: border,
                focusedBorder: border,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.ink,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
