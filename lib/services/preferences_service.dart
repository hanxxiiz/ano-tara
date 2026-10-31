import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/member_preferences.dart';

class NotSignedInException implements Exception {
  @override
  String toString() => 'No signed-in member to save preferences for.';
}

/// Reads and writes the signed-in member's row in `member_preferences`.
class PreferencesService {
  PreferencesService([SupabaseClient? client]) : _clientOverride = client;

  static const table = 'member_preferences';

  final SupabaseClient? _clientOverride;

  // Resolved lazily so screens can be built (e.g. in widget tests) without
  // Supabase being initialized.
  SupabaseClient get _client => _clientOverride ?? Supabase.instance.client;

  String? get _memberId => _client.auth.currentUser?.id;

  /// Returns the saved preferences, or null if there are none yet.
  Future<MemberPreferences?> load() async {
    final memberId = _memberId;
    if (memberId == null) throw NotSignedInException();

    final row = await _client
        .from(table)
        .select()
        .eq('user_id', memberId)
        .maybeSingle();
    return row == null ? null : MemberPreferences.fromMap(row);
  }

  /// Inserts or replaces the member's preferences.
  Future<void> save(MemberPreferences preferences) async {
    final memberId = _memberId;
    if (memberId == null) throw NotSignedInException();

    await _client.from(table).upsert({
      ...preferences.toMap(),
      'user_id': memberId,
    }, onConflict: 'user_id');
  }
}
