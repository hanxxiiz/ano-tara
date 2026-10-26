/// Answers collected during onboarding, stored in the `member_preferences`
/// table (one row per member, keyed by `member_id`).
class MemberPreferences {
  const MemberPreferences({
    this.activities = const [],
    this.dietaryPreferences = const [],
    this.allergies = const [],
    this.budget = 2000,
    this.travelPace,
    this.availableDays = const [],
    this.notes = '',
  });

  final List<String> activities;
  final List<String> dietaryPreferences;
  final List<String> allergies;

  /// Budget in pesos. 10000 means "10,000+".
  final int budget;

  /// One of [TravelPace.values] names, or null if not picked yet.
  final String? travelPace;
  final List<String> availableDays;
  final String notes;

  factory MemberPreferences.fromMap(Map<String, dynamic> map) {
    List<String> list(String key) =>
        (map[key] as List<dynamic>? ?? const []).map((e) => e.toString()).toList();

    return MemberPreferences(
      activities: list('activities'),
      dietaryPreferences: list('dietary_preferences'),
      allergies: list('allergies'),
      budget: (map['budget'] as num?)?.toInt() ?? 2000,
      travelPace: map['travel_pace'] as String?,
      availableDays: list('available_days'),
      notes: map['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'activities': activities,
        'dietary_preferences': dietaryPreferences,
        'allergies': allergies,
        'budget': budget,
        'travel_pace': travelPace,
        'available_days': availableDays,
        'notes': notes,
      };
}

enum TravelPace { relaxed, balanced, packed }
