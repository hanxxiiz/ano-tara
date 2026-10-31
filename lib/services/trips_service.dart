import 'package:supabase_flutter/supabase_flutter.dart';

/// Writes trip fields to the `trips` table.
class TripsService {
  TripsService([SupabaseClient? client]) : _clientOverride = client;

  static const table = 'trips';

  final SupabaseClient? _clientOverride;

  // Resolved lazily so screens can be built without Supabase initialized.
  SupabaseClient get _client => _clientOverride ?? Supabase.instance.client;

  Future<void> rename(String tripId, String name) async {
    await _client.from(table).update({'name': name}).eq('id', tripId);
  }
}
