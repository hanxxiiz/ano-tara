import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/subscription_usage.dart';

/// Thrown when the database refuses an action because a plan limit is reached.
///
/// The database (not the app) decides this, so it also applies to anyone
/// calling the backend directly. [quota] is one of: groups,
/// members_per_group, active_trips, ai_generations.
class QuotaExceededException implements Exception {
  const QuotaExceededException(this.quota, this.message);

  final String quota;
  final String message;

  /// Returns a [QuotaExceededException] if [error] is a plan-limit error
  /// from the database, otherwise null.
  static QuotaExceededException? from(Object error) {
    if (error is PostgrestException) {
      final hint = error.hint ?? '';
      if (hint.startsWith('quota_exceeded:')) {
        return QuotaExceededException(
          hint.substring('quota_exceeded:'.length),
          error.message,
        );
      }
    }
    return null;
  }

  @override
  String toString() => message;
}

/// Reads the signed-in user's plan and usage for the Manage Subscription screen.
class SubscriptionService {
  SubscriptionService([SupabaseClient? client]) : _clientOverride = client;

  final SupabaseClient? _clientOverride;

  // Resolved lazily so screens can be built (e.g. in widget tests) without
  // Supabase being initialized.
  SupabaseClient get _client => _clientOverride ?? Supabase.instance.client;

  Future<SubscriptionUsage> fetchUsage() async {
    final result = await _client.rpc('anotara_get_subscription_usage');
    return SubscriptionUsage.fromMap(Map<String, dynamic>.from(result as Map));
  }
}
