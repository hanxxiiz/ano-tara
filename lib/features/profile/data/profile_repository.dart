import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/member_preferences.dart';
import '../../../services/preferences_service.dart';

/// Header data for the Profile screen.
class ProfileSummary {
  const ProfileSummary({
    required this.fullName,
    required this.username,
    this.avatarUrl,
    this.trips = 0,
    this.groups = 0,
    this.activeTrips = 0,
    this.planName = 'Plus Plan',
    this.planExpires = 'Jan 12, 2027',
  });

  final String fullName;
  final String username;
  final String? avatarUrl;
  final int trips;
  final int groups;
  final int activeTrips;
  final String planName;
  final String planExpires;
}

/// Shared state for the Profile screen and the preference view/edit screens.
///
/// Saves update [preferences] right away so every screen reflects the change,
/// then sync to `member_preferences` in Supabase on a best-effort basis.
class ProfileRepository {
  ProfileRepository({PreferencesService? service})
    : _service = service ?? PreferencesService();

  static final ProfileRepository instance = ProfileRepository();

  final PreferencesService _service;

  final ValueNotifier<MemberPreferences> preferences =
      ValueNotifier<MemberPreferences>(_samplePreferences);

  bool _loaded = false;

  static const _samplePreferences = MemberPreferences(
    activities: ['Sightseeing', 'Hiking'],
    dietaryPreferences: ['Gluten-free', 'Vegetarian'],
    allergies: ['Dairy', 'Gluten', 'Eggs', 'Sesame'],
    budget: 5000,
    travelPace: 'relaxed',
  );

  /// Name, username and stats. Falls back to sample data when there is no
  /// signed-in user (offline, tests).
  ProfileSummary get summary {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final meta = user.userMetadata ?? const {};
        final first = (meta['first_name'] ?? '').toString().trim();
        final last = (meta['last_name'] ?? '').toString().trim();
        final full = (meta['full_name'] ?? '$first $last').toString().trim();
        final username =
            (meta['username'] ?? user.email?.split('@').first ?? '')
                .toString()
                .trim();
        return ProfileSummary(
          fullName: full.isNotEmpty ? full : username,
          username: username,
          avatarUrl: meta['avatar_url']?.toString(),
          trips: 276,
          groups: 5,
          activeTrips: 3,
        );
      }
    } catch (_) {
      // Supabase not initialized.
    }
    return const ProfileSummary(
      fullName: 'Lucy Hayden Halilia',
      username: 'lucyheartfilia_123',
      trips: 276,
      groups: 5,
      activeTrips: 3,
    );
  }

  /// Loads saved preferences once. Keeps the current value on failure.
  Future<void> load({bool force = false}) async {
    if (_loaded && !force) return;
    _loaded = true;
    try {
      final saved = await _service.load();
      if (saved != null) preferences.value = saved;
    } catch (e) {
      debugPrint('Profile preferences load skipped: $e');
    }
  }

  /// Applies [updated] locally, then tries to save it to Supabase.
  /// Returns false if the remote save failed (the local change is kept).
  Future<bool> save(MemberPreferences updated) async {
    preferences.value = updated;
    try {
      await _service.save(updated);
      return true;
    } catch (e) {
      debugPrint('Profile preferences saved locally only: $e');
      return false;
    }
  }
}
