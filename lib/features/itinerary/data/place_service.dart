import 'dart:math' as math;

/// A place picked from location search.
class PlaceResult {
  final String id;
  final String name;

  /// Short area / address line, e.g. "Santa Fe, Bantayan".
  final String address;
  final double? latitude;
  final double? longitude;

  /// Rating out of 5, when known.
  final double? rating;

  /// e.g. "Resort", "Beach", "Restaurant".
  final String kind;

  const PlaceResult({
    required this.id,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    this.rating,
    this.kind = '',
  });

  /// A typed-in place that isn't in search results (no map pin).
  factory PlaceResult.custom(String name, {String address = ''}) =>
      PlaceResult(id: 'custom-$name', name: name, address: address);

  bool get hasCoordinates => latitude != null && longitude != null;
}

/// Location search used by the Add Entry flow.
///
/// [MockPlaceService] is a local catalog so the flow works without an API
/// key. Swap [defaultPlaceService] for a real places/geocoding service later.
abstract class PlaceService {
  /// Map center for a trip destination.
  ({double latitude, double longitude}) centerFor(String destination);

  /// Highest-rated places near the destination.
  Future<List<PlaceResult>> topPicks(String destination, {int limit = 5});

  /// Places whose name, kind or address matches [query].
  Future<List<PlaceResult>> search(String destination, String query);

  /// Trip-level destinations suggested before the user searches.
  Future<List<PlaceResult>> popularDestinations();
}

class MockPlaceService implements PlaceService {
  const MockPlaceService();

  // Santa Fe port area, Bantayan Island.
  static const _center = (latitude: 11.1545, longitude: 123.8020);

  static const List<PlaceResult> _catalog = [
    PlaceResult(
      id: 'hannahs-beach-resort',
      name: 'Hannah\'s Beach Resort',
      address: 'Santa Fe, Bantayan',
      latitude: 11.1530,
      longitude: 123.8035,
      rating: 4.8,
      kind: 'Resort',
    ),
    PlaceResult(
      id: 'paradise-beach',
      name: 'Paradise Beach',
      address: 'Santa Fe, Bantayan',
      latitude: 11.1665,
      longitude: 123.8090,
      rating: 4.7,
      kind: 'Beach',
    ),
    PlaceResult(
      id: 'kota-beach',
      name: 'Kota Beach',
      address: 'Santa Fe, Bantayan',
      latitude: 11.1505,
      longitude: 123.7985,
      rating: 4.6,
      kind: 'Beach',
    ),
    PlaceResult(
      id: 'virgin-island',
      name: 'Virgin Island',
      address: 'Bantayan Island',
      latitude: 11.1320,
      longitude: 123.7790,
      rating: 4.6,
      kind: 'Island',
    ),
    PlaceResult(
      id: 'ogtong-cave',
      name: 'Ogtong Cave',
      address: 'Santa Fe, Bantayan',
      latitude: 11.1600,
      longitude: 123.8050,
      rating: 4.4,
      kind: 'Cave pool',
    ),
    PlaceResult(
      id: 'bantayan-church',
      name: 'Sts. Peter and Paul Parish Church',
      address: 'Bantayan, Cebu',
      latitude: 11.1680,
      longitude: 123.7225,
      rating: 4.6,
      kind: 'Church',
    ),
    PlaceResult(
      id: 'omagieca-mangrove',
      name: 'Omagieca Mangrove Garden',
      address: 'Bantayan, Cebu',
      latitude: 11.2040,
      longitude: 123.7330,
      rating: 4.5,
      kind: 'Nature park',
    ),
    PlaceResult(
      id: 'jollibee-santa-fe',
      name: 'Jollibee Santa Fe',
      address: 'Santa Fe, Bantayan',
      latitude: 11.1560,
      longitude: 123.8005,
      rating: 4.2,
      kind: 'Restaurant',
    ),
    PlaceResult(
      id: 'mj-square',
      name: 'MJ Square',
      address: 'Santa Fe, Bantayan',
      latitude: 11.1572,
      longitude: 123.8012,
      rating: 4.3,
      kind: 'Food park',
    ),
    // Trip-level destinations (Create Trip → Select Destination).
    PlaceResult(
      id: 'bantayan-island',
      name: 'Bantayan Island',
      address: 'Cebu, Philippines',
      latitude: 11.2000,
      longitude: 123.7300,
      rating: 4.7,
      kind: 'Destination',
    ),
    PlaceResult(
      id: 'siargao',
      name: 'Siargao Island',
      address: 'Surigao del Norte, Philippines',
      latitude: 9.8480,
      longitude: 126.0458,
      rating: 4.8,
      kind: 'Destination',
    ),
    PlaceResult(
      id: 'boracay',
      name: 'Boracay',
      address: 'Malay, Aklan, Philippines',
      latitude: 11.9674,
      longitude: 121.9248,
      rating: 4.7,
      kind: 'Destination',
    ),
    PlaceResult(
      id: 'el-nido',
      name: 'El Nido',
      address: 'Palawan, Philippines',
      latitude: 11.1956,
      longitude: 119.4075,
      rating: 4.8,
      kind: 'Destination',
    ),
    PlaceResult(
      id: 'baguio',
      name: 'Baguio City',
      address: 'Benguet, Philippines',
      latitude: 16.4023,
      longitude: 120.5960,
      rating: 4.5,
      kind: 'Destination',
    ),
    PlaceResult(
      id: 'moalboal',
      name: 'Moalboal',
      address: 'Cebu, Philippines',
      latitude: 9.9536,
      longitude: 123.3989,
      rating: 4.6,
      kind: 'Destination',
    ),
    PlaceResult(
      id: 'santa-fe-port',
      name: 'Santa Fe Port',
      address: 'Santa Fe, Bantayan',
      latitude: 11.1515,
      longitude: 123.8060,
      rating: 4.0,
      kind: 'Ferry terminal',
    ),
  ];

  @override
  ({double latitude, double longitude}) centerFor(String destination) =>
      _center;

  @override
  Future<List<PlaceResult>> topPicks(
    String destination, {
    int limit = 5,
  }) async {
    final sorted = _catalog.where((p) => p.kind != _destinationKind).toList()
      ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    return sorted.take(limit).toList();
  }

  static const _destinationKind = 'Destination';

  @override
  Future<List<PlaceResult>> popularDestinations() async =>
      _catalog.where((p) => p.kind == _destinationKind).toList();

  @override
  Future<List<PlaceResult>> search(String destination, String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return _catalog
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              p.kind.toLowerCase().contains(q) ||
              p.address.toLowerCase().contains(q),
        )
        .toList();
  }
}

/// TODO: replace with a real places service (e.g. a Supabase Edge Function
/// wrapping a places API) once one is available.
PlaceService defaultPlaceService = const MockPlaceService();

/// Straight-line distance in kilometres.
double distanceKm(double lat1, double lng1, double lat2, double lng2) {
  const earthRadiusKm = 6371.0;
  double rad(double deg) => deg * math.pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLng = rad(lng2 - lng1);
  final a = math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(lat1)) *
          math.cos(rad(lat2)) *
          math.pow(math.sin(dLng / 2), 2);
  return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

String formatDistance(double km) =>
    km < 1 ? '${(km * 1000).round()} m away' : '${km.toStringAsFixed(1)} km away';
