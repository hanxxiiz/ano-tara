import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ItineraryItemModel {
  final String id;
  final String? tripId;
  final String category;
  final String placeName;
  final String location;
  final String title;
  final String startTime;
  final String endTime;
  final String notes;
  final int dayNumber;

  /// Map position of [placeName], when it was picked from location search.
  /// Kept locally only (not part of the `itinerary_items` insert).
  final double? latitude;
  final double? longitude;

  /// Place rating out of 5, when known.
  final double? rating;

  const ItineraryItemModel({
    required this.id,
    this.tripId,
    required this.category,
    required this.placeName,
    required this.location,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.notes = '',
    this.dayNumber = 19,
    this.latitude,
    this.longitude,
    this.rating,
  });

  String get timeRange => '$startTime - $endTime';

  bool get hasCoordinates => latitude != null && longitude != null;

  ItineraryItemModel copyWith({
    String? category,
    String? placeName,
    String? location,
    String? title,
    String? startTime,
    String? endTime,
    String? notes,
    int? dayNumber,
    double? latitude,
    double? longitude,
    double? rating,
    bool clearCoordinates = false,
  }) {
    return ItineraryItemModel(
      id: id,
      tripId: tripId,
      category: category ?? this.category,
      placeName: placeName ?? this.placeName,
      location: location ?? this.location,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
      dayNumber: dayNumber ?? this.dayNumber,
      latitude: clearCoordinates ? null : (latitude ?? this.latitude),
      longitude: clearCoordinates ? null : (longitude ?? this.longitude),
      rating: clearCoordinates ? null : (rating ?? this.rating),
    );
  }

  Map<String, dynamic> toSupabaseMap({String? overrideTripId}) {
    return {
      if (overrideTripId != null || tripId != null)
        'trip_id': overrideTripId ?? tripId,
      'category': category,
      'place_name': placeName,
      'location': location,
      'title': title,
      'start_time': startTime,
      'end_time': endTime,
      'notes': notes,
      'day_number': dayNumber,
    };
  }
}

class TripMemberModel {
  final String name;
  final String role;
  final List<String> availabilityDays;

  const TripMemberModel({
    required this.name,
    required this.role,
    this.availabilityDays = const ['Mon', 'Tue'],
  });

  Map<String, dynamic> toSupabaseMap({required String tripId}) {
    return {
      'trip_id': tripId,
      'member_name': name,
      'role': role,
      'availability': availabilityDays.join(','),
    };
  }
}

class TripModel {
  final String id;
  final String groupName;
  final String name;
  final String destination;
  final String startDate;
  final String endDate;
  final String meetingPlace;
  final String description;
  final bool isAiGenerated;
  final List<TripMemberModel> members;
  final List<ItineraryItemModel> itineraryItems;

  const TripModel({
    required this.id,
    required this.groupName,
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.meetingPlace,
    required this.description,
    required this.isAiGenerated,
    required this.members,
    required this.itineraryItems,
  });

  String get dateRangeLabel {
    if (startDate.trim().isEmpty && endDate.trim().isEmpty) {
      return 'Oct 10 - Oct 15';
    }
    if (endDate.trim().isEmpty) return startDate.trim();
    if (startDate.trim().isEmpty) return endDate.trim();
    return '${startDate.trim()} - ${endDate.trim()}';
  }

  String get groupGoingLabel {
    final count = members.isNotEmpty ? members.length : 6;
    return 'The Group ($count going)';
  }
}

/// Repository handling Flow 05 (Plan a Trip) persistence:
/// - Saves trips to `trips` and `trip_members`
/// - Saves manually added items to `itinerary_items`
/// - Publishes reactive updates so created trips immediately appear in the
///   group's Trips tab and Overview tab.
class TripRepository {
  TripRepository._();

  static final TripRepository instance = TripRepository._();

  final ValueNotifier<List<TripModel>> tripsNotifier =
      ValueNotifier<List<TripModel>>(_initialTrips);

  final ValueNotifier<List<ItineraryItemModel>> manualItineraryItemsNotifier =
      ValueNotifier<List<ItineraryItemModel>>([]);

  static final List<TripModel> _initialTrips = [
    const TripModel(
      id: 'seed-trip-1',
      groupName: 'Trip to Bantayan',
      name: 'Bantayan Trip',
      destination: 'Bantayan, Philippines',
      startDate: 'Oct 10',
      endDate: 'Oct 15',
      meetingPlace: 'North Bus Terminal',
      description: 'Beach getaway with the group.',
      isAiGenerated: true,
      members: [
        TripMemberModel(name: 'Hannah S. Labandero', role: 'Organizer'),
        TripMemberModel(name: 'Louielyn Abella', role: 'Member'),
        TripMemberModel(name: 'Ellle Bernante', role: 'Member'),
        TripMemberModel(name: 'Carla Santos', role: 'Member'),
        TripMemberModel(name: 'Sarah Jenkins', role: 'Member'),
        TripMemberModel(name: 'Mark Lim', role: 'Member'),
      ],
      itineraryItems: [],
    ),
    const TripModel(
      id: 'seed-trip-2',
      groupName: 'Trip to Bantayan',
      name: 'Bantayan Trip',
      destination: 'Bantayan, Philippines',
      startDate: 'Oct 10',
      endDate: 'Oct 15',
      meetingPlace: 'North Bus Terminal',
      description: 'Second group excursion.',
      isAiGenerated: false,
      members: [
        TripMemberModel(name: 'Hannah S. Labandero', role: 'Organizer'),
        TripMemberModel(name: 'Louielyn Abella', role: 'Member'),
        TripMemberModel(name: 'Ellle Bernante', role: 'Member'),
        TripMemberModel(name: 'Carla Santos', role: 'Member'),
        TripMemberModel(name: 'Sarah Jenkins', role: 'Member'),
        TripMemberModel(name: 'Mark Lim', role: 'Member'),
      ],
      itineraryItems: [],
    ),
  ];

  List<TripModel> tripsForGroup(String groupName) {
    final all = tripsNotifier.value;
    final matching = all
        .where(
          (t) =>
              t.groupName.toLowerCase() == groupName.toLowerCase() ||
              groupName.toLowerCase() == 'trip to bantayan' ||
              groupName.toLowerCase() == 'the group',
        )
        .toList();
    return matching.isNotEmpty ? matching : all;
  }

  /// Saves a manually added itinerary item to `itinerary_items` in Supabase
  /// and appends it to the local state list.
  Future<ItineraryItemModel> saveManualItineraryItem({
    String? tripId,
    required String category,
    required String placeName,
    required String location,
    required String title,
    required String startTime,
    required String endTime,
    String notes = '',
    int dayNumber = 19,
    double? latitude,
    double? longitude,
    double? rating,
  }) async {
    final item = ItineraryItemModel(
      id: 'item-${DateTime.now().microsecondsSinceEpoch}',
      tripId: tripId,
      category: category,
      placeName: placeName,
      location: location,
      title: title,
      startTime: startTime,
      endTime: endTime,
      notes: notes,
      dayNumber: dayNumber,
      latitude: latitude,
      longitude: longitude,
      rating: rating,
    );

    manualItineraryItemsNotifier.value = [
      item,
      ...manualItineraryItemsNotifier.value,
    ];

    try {
      final client = Supabase.instance.client;
      await client.from('itinerary_items').insert(item.toSupabaseMap());
    } catch (e) {
      debugPrint('Supabase itinerary_items insert fallback (local saved): $e');
    }

    return item;
  }

  /// Saves several itinerary items at once (e.g. accepted AI suggestions) to
  /// `itinerary_items` and appends them to the local state list.
  ///
  /// Like [saveManualItineraryItem], items are kept locally even if the
  /// Supabase insert fails.
  Future<List<ItineraryItemModel>> saveItineraryItems(
    List<ItineraryItemModel> items,
  ) async {
    if (items.isEmpty) return items;

    manualItineraryItemsNotifier.value = [
      ...items,
      ...manualItineraryItemsNotifier.value,
    ];

    try {
      final client = Supabase.instance.client;
      await client
          .from('itinerary_items')
          .insert(items.map((item) => item.toSupabaseMap()).toList());
    } catch (e) {
      debugPrint('Supabase itinerary_items batch insert fallback (local saved): $e');
    }
    return items;
  }

  /// Itinerary items of one trip (all days), from the local state list.
  List<ItineraryItemModel> itineraryItemsForTrip(String? tripId) {
    return manualItineraryItemsNotifier.value
        .where((i) => i.tripId == tripId)
        .toList();
  }

  /// Replaces an existing itinerary item (matched by id) locally and in
  /// `itinerary_items`. Kept locally even if the Supabase update fails.
  Future<ItineraryItemModel> updateItineraryItem(
    ItineraryItemModel item,
  ) async {
    manualItineraryItemsNotifier.value = [
      for (final existing in manualItineraryItemsNotifier.value)
        existing.id == item.id ? item : existing,
    ];

    try {
      final client = Supabase.instance.client;
      await client
          .from('itinerary_items')
          .update(item.toSupabaseMap())
          .eq('id', item.id);
    } catch (e) {
      debugPrint('Supabase itinerary_items update fallback (local saved): $e');
    }
    return item;
  }

  /// Removes itinerary items by id locally and from `itinerary_items`.
  Future<void> deleteItineraryItems(Iterable<String> ids) async {
    final toDelete = ids.toSet();
    if (toDelete.isEmpty) return;

    manualItineraryItemsNotifier.value = manualItineraryItemsNotifier.value
        .where((i) => !toDelete.contains(i.id))
        .toList();

    try {
      final client = Supabase.instance.client;
      await client
          .from('itinerary_items')
          .delete()
          .inFilter('id', toDelete.toList());
    } catch (e) {
      debugPrint('Supabase itinerary_items delete fallback (local removed): $e');
    }
  }

  /// Saves a newly planned trip to `trips`, its selected members to `trip_members`,
  /// and its itinerary items to `itinerary_items`.
  Future<TripModel> saveTrip({
    required String groupName,
    required String name,
    required String destination,
    required String startDate,
    required String endDate,
    required String meetingPlace,
    required String description,
    required bool isAiGenerated,
    required List<TripMemberModel> members,
    required List<ItineraryItemModel> itineraryItems,
  }) async {
    final resolvedName =
        name.trim().isNotEmpty ? name.trim() : 'Bantayan Trip';
    final resolvedDestination = destination.trim().isNotEmpty
        ? destination.trim()
        : 'Bantayan, Philippines';
    final resolvedStart =
        startDate.trim().isNotEmpty ? startDate.trim() : 'Oct 10';
    final resolvedEnd = endDate.trim().isNotEmpty ? endDate.trim() : 'Oct 15';
    final resolvedMeeting = meetingPlace.trim().isNotEmpty
        ? meetingPlace.trim()
        : 'North Bus Terminal';

    String tripId = 'trip-${DateTime.now().millisecondsSinceEpoch}';

    // 1. Save to Supabase `trips`, `trip_members`, and `itinerary_items`
    try {
      final client = Supabase.instance.client;
      final insertedTrip = await client
          .from('trips')
          .insert({
            'group_name': groupName,
            'name': resolvedName,
            'destination': resolvedDestination,
            'start_date': resolvedStart,
            'end_date': resolvedEnd,
            'meeting_place': resolvedMeeting,
            'description': description.trim(),
            'planning_mode': isAiGenerated ? 'ai' : 'manual',
          })
          .select('id')
          .maybeSingle();

      if (insertedTrip != null && insertedTrip['id'] != null) {
        tripId = insertedTrip['id'].toString();
      }

      if (members.isNotEmpty) {
        await client.from('trip_members').insert(
              members
                  .map((m) => m.toSupabaseMap(tripId: tripId))
                  .toList(),
            );
      }

      if (itineraryItems.isNotEmpty) {
        await client.from('itinerary_items').insert(
              itineraryItems
                  .map((item) => item.toSupabaseMap(overrideTripId: tripId))
                  .toList(),
            );
      }
    } catch (e) {
      debugPrint(
        'Supabase trips/trip_members/itinerary_items sync notice (stored locally): $e',
      );
    }

    final newTrip = TripModel(
      id: tripId,
      groupName: groupName,
      name: resolvedName,
      destination: resolvedDestination,
      startDate: resolvedStart,
      endDate: resolvedEnd,
      meetingPlace: resolvedMeeting,
      description: description.trim(),
      isAiGenerated: isAiGenerated,
      members: members,
      itineraryItems: itineraryItems,
    );

    tripsNotifier.value = [newTrip, ...tripsNotifier.value];
    return newTrip;
  }
}
