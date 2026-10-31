import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/trip.dart';

class TripMapData {
  const TripMapData({required this.meetingPoint, required this.locations});

  final MeetingPoint? meetingPoint;
  final List<MemberLocation> locations;
}

/// Reads `meeting_points` and `location_shares` for a trip, and saves the
/// organizer's meeting point.
class TripMapService {
  TripMapService([SupabaseClient? client]) : _clientOverride = client;

  static const meetingPointsTable = 'meeting_points';
  static const locationSharesTable = 'location_shares';

  final SupabaseClient? _clientOverride;

  // Resolved lazily so screens can be built without Supabase initialized.
  SupabaseClient get _client => _clientOverride ?? Supabase.instance.client;

  Future<TripMapData> fetch(Trip trip) async {
    final tripId = trip.remoteId!;
    final pointRow = await _client
        .from(meetingPointsTable)
        .select('id, name, latitude, longitude')
        .eq('trip_id', tripId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    final shareRows = await _client
        .from(locationSharesTable)
        .select('user_id, latitude, longitude, expires_at')
        .eq('trip_id', tripId)
        .eq('is_active', true);

    final now = DateTime.now();
    final locations = <MemberLocation>[];
    for (final row in shareRows) {
      final expires = row['expires_at'] == null
          ? null
          : DateTime.tryParse(row['expires_at'].toString());
      if (expires != null && expires.isBefore(now)) continue;
      final lat = (row['latitude'] as num?)?.toDouble();
      final lng = (row['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) continue;
      locations.add(
        MemberLocation(
          memberId: _memberIdFor(trip, row['user_id'].toString()),
          position: GeoPoint(lat, lng),
        ),
      );
    }

    MeetingPoint? meetingPoint;
    final lat = (pointRow?['latitude'] as num?)?.toDouble();
    final lng = (pointRow?['longitude'] as num?)?.toDouble();
    if (pointRow != null && lat != null && lng != null) {
      meetingPoint = MeetingPoint(
        id: pointRow['id'].toString(),
        name: (pointRow['name'] ?? 'Meeting point').toString(),
        position: GeoPoint(lat, lng),
      );
    }
    return TripMapData(meetingPoint: meetingPoint, locations: locations);
  }

  /// Inserts or updates the meeting point and returns its id.
  Future<String> saveMeetingPoint(Trip trip, MeetingPoint point) async {
    final values = {
      'name': point.name,
      'latitude': point.position.latitude,
      'longitude': point.position.longitude,
    };
    if (point.id != null) {
      await _client.from(meetingPointsTable).update(values).eq('id', point.id!);
      return point.id!;
    }
    final row = await _client
        .from(meetingPointsTable)
        .insert({
          ...values,
          'trip_id': trip.remoteId,
          'created_by': _client.auth.currentUser?.id,
        })
        .select('id')
        .single();
    return row['id'].toString();
  }

  /// Maps an auth user id to the trip member, or keeps the raw id so the
  /// marker still shows (labelled "Member").
  static String _memberIdFor(Trip trip, String userId) {
    for (final m in trip.group.members) {
      if (m.userId == userId) return m.id;
    }
    return userId;
  }
}
