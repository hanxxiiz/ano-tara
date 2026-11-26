import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum TripStatus {
  upcoming,
  ongoing,
  completed,
  cancelled,
}

extension TripStatusX on TripStatus {
  String get label {
    switch (this) {
      case TripStatus.upcoming:
        return 'Upcoming';
      case TripStatus.ongoing:
        return 'Ongoing';
      case TripStatus.completed:
        return 'Completed';
      case TripStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class TripDaySchedule {
  final int dayNumber;
  final String dateLabel;

  const TripDaySchedule({
    required this.dayNumber,
    required this.dateLabel,
  });
}

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
    this.dayNumber = 1,
  });

  String get timeRange => '$startTime - $endTime';

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

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'MR';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

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
  final String fullDateRange;
  final DateTime sortDate;
  final String meetingPlace;
  final String description;
  final bool isAiGenerated;
  final TripStatus status;
  final String? cancellationReason;
  final bool isOrganizer;
  final int currentDay;
  final List<TripDaySchedule> days;
  final List<TripMemberModel> members;
  final List<ItineraryItemModel> itineraryItems;

  const TripModel({
    required this.id,
    required this.groupName,
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
    String? fullDateRange,
    DateTime? sortDate,
    required this.meetingPlace,
    required this.description,
    required this.isAiGenerated,
    this.status = TripStatus.ongoing,
    this.cancellationReason,
    this.isOrganizer = true,
    this.currentDay = 1,
    this.days = const [],
    required this.members,
    required this.itineraryItems,
  })  : fullDateRange = fullDateRange ?? '$startDate - $endDate',
        sortDate = sortDate ?? const _DefaultDateTime();

  String get dateRangeLabel {
    if (startDate.trim().isEmpty && endDate.trim().isEmpty) {
      return 'Nov 13 - Nov 15';
    }
    if (endDate.trim().isEmpty) return startDate.trim();
    if (startDate.trim().isEmpty) return endDate.trim();
    return '${startDate.trim()} - ${endDate.trim()}';
  }

  String get groupGoingLabel {
    final count = members.isNotEmpty ? members.length : 6;
    return 'The Group ($count going)';
  }

  int get totalDays => days.isNotEmpty ? days.length : 3;

  TripModel copyWith({
    String? groupName,
    String? name,
    String? destination,
    String? startDate,
    String? endDate,
    String? fullDateRange,
    DateTime? sortDate,
    String? meetingPlace,
    String? description,
    bool? isAiGenerated,
    TripStatus? status,
    String? cancellationReason,
    bool? isOrganizer,
    int? currentDay,
    List<TripDaySchedule>? days,
    List<TripMemberModel>? members,
    List<ItineraryItemModel>? itineraryItems,
  }) {
    return TripModel(
      id: id,
      groupName: groupName ?? this.groupName,
      name: name ?? this.name,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      fullDateRange: fullDateRange ?? this.fullDateRange,
      sortDate: sortDate ?? this.sortDate,
      meetingPlace: meetingPlace ?? this.meetingPlace,
      description: description ?? this.description,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
      status: status ?? this.status,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      isOrganizer: isOrganizer ?? this.isOrganizer,
      currentDay: currentDay ?? this.currentDay,
      days: days ?? this.days,
      members: members ?? this.members,
      itineraryItems: itineraryItems ?? this.itineraryItems,
    );
  }
}

class _DefaultDateTime implements DateTime {
  const _DefaultDateTime();

  DateTime get _d => DateTime(2026, 11, 13);

  @override
  DateTime add(Duration duration) => _d.add(duration);
  @override
  int compareTo(DateTime other) => _d.compareTo(other);
  @override
  int get day => _d.day;
  @override
  Duration difference(DateTime other) => _d.difference(other);
  @override
  int get hour => _d.hour;
  @override
  bool isAfter(DateTime other) => _d.isAfter(other);
  @override
  bool isAtSameMomentAs(DateTime other) => _d.isAtSameMomentAs(other);
  @override
  bool isBefore(DateTime other) => _d.isBefore(other);
  @override
  bool get isUtc => _d.isUtc;
  @override
  int get microsecond => _d.microsecond;
  @override
  int get microsecondsSinceEpoch => _d.microsecondsSinceEpoch;
  @override
  int get millisecond => _d.millisecond;
  @override
  int get millisecondsSinceEpoch => _d.millisecondsSinceEpoch;
  @override
  int get minute => _d.minute;
  @override
  int get month => _d.month;
  @override
  int get second => _d.second;
  @override
  DateTime subtract(Duration duration) => _d.subtract(duration);
  @override
  String get timeZoneName => _d.timeZoneName;
  @override
  Duration get timeZoneOffset => _d.timeZoneOffset;
  @override
  String toIso8601String() => _d.toIso8601String();
  @override
  DateTime toLocal() => _d.toLocal();
  @override
  DateTime toUtc() => _d.toUtc();
  @override
  int get weekday => _d.weekday;
  @override
  int get year => _d.year;
}

/// Repository handling Trips persistence and reactive state across
/// Trips List, Trip Overview, and Plan a Trip flows.
class TripRepository {
  TripRepository._();

  static final TripRepository instance = TripRepository._();

  final ValueNotifier<List<TripModel>> tripsNotifier =
      ValueNotifier<List<TripModel>>(_initialTrips);

  final ValueNotifier<List<ItineraryItemModel>> manualItineraryItemsNotifier =
      ValueNotifier<List<ItineraryItemModel>>([]);

  static final List<TripModel> _initialTrips = [
    TripModel(
      id: 'seed-trip-1',
      groupName: 'The Group',
      name: 'Bantayan Trip',
      destination: 'Bantayan, Philippines',
      startDate: 'Nov 13',
      endDate: 'Nov 15',
      fullDateRange: 'November 13 - November 15',
      sortDate: DateTime(2026, 11, 13),
      meetingPlace: 'North Bus Terminal',
      description:
          'Island hopping, beach dinners and as many sunsets as we can fit in.',
      isAiGenerated: true,
      status: TripStatus.ongoing,
      isOrganizer: true,
      currentDay: 3,
      days: const [
        TripDaySchedule(dayNumber: 1, dateLabel: 'Nov 13'),
        TripDaySchedule(dayNumber: 2, dateLabel: 'Nov 14'),
        TripDaySchedule(dayNumber: 3, dateLabel: 'Nov 15'),
      ],
      members: const [
        TripMemberModel(name: 'Maya Reyes', role: 'Organizer'),
        TripMemberModel(name: 'Miguel Ramos', role: 'Member'),
        TripMemberModel(name: 'Marco Rivera', role: 'Member'),
        TripMemberModel(name: 'Mina Roque', role: 'Member'),
        TripMemberModel(name: 'Carla Santos', role: 'Member'),
        TripMemberModel(name: 'Sarah Jenkins', role: 'Member'),
        TripMemberModel(name: 'Mark Lim', role: 'Member'),
      ],
      itineraryItems: const [
        ItineraryItemModel(
          id: 'it-1',
          tripId: 'seed-trip-1',
          category: 'Activity',
          placeName: 'Santa Fe, Bantayan',
          location: 'Santa Fe, Bantayan',
          title: 'Island Hopping',
          startTime: '9:00 AM',
          endTime: '10:00 AM',
          dayNumber: 3,
        ),
        ItineraryItemModel(
          id: 'it-2',
          tripId: 'seed-trip-1',
          category: 'Check-in',
          placeName: 'Kota Beach Resort',
          location: 'Kota Beach Resort',
          title: 'Check in at Kota Resort',
          startTime: '10:00 AM',
          endTime: '12:00 PM',
          dayNumber: 3,
        ),
        ItineraryItemModel(
          id: 'it-3',
          tripId: 'seed-trip-1',
          category: 'Travel',
          placeName: 'Hagnaya Port',
          location: 'Hagnaya Port, Cebu',
          title: 'Ferry to Santa Fe',
          startTime: '7:00 AM',
          endTime: '8:30 AM',
          dayNumber: 1,
        ),
        ItineraryItemModel(
          id: 'it-4',
          tripId: 'seed-trip-1',
          category: 'Food',
          placeName: 'MJ Square',
          location: 'Santa Fe, Bantayan',
          title: 'Seafood Dinner at MJ Square',
          startTime: '6:30 PM',
          endTime: '8:30 PM',
          dayNumber: 1,
        ),
        ItineraryItemModel(
          id: 'it-5',
          tripId: 'seed-trip-1',
          category: 'Activity',
          placeName: 'Virgin Island',
          location: 'Virgin Island, Bantayan',
          title: 'Snorkeling & Cliff Jump',
          startTime: '10:00 AM',
          endTime: '2:00 PM',
          dayNumber: 2,
        ),
        ItineraryItemModel(
          id: 'it-6',
          tripId: 'seed-trip-1',
          category: 'Sightseeing',
          placeName: 'Ogtong Cave',
          location: 'Santa Fe, Bantayan',
          title: 'Ogtong Cave & Sunset Walk',
          startTime: '3:30 PM',
          endTime: '5:30 PM',
          dayNumber: 2,
        ),
      ],
    ),
    TripModel(
      id: 'seed-trip-2',
      groupName: 'Twice',
      name: 'Siargao Surf Trip',
      destination: 'Siargao, Philippines',
      startDate: 'Oct 10',
      endDate: 'Oct 12',
      fullDateRange: 'October 10 - October 12',
      sortDate: DateTime(2026, 10, 10),
      meetingPlace: 'Mactan Airport Terminal 1',
      description:
          'Cloud 9 surf sessions, Sugba Lagoon paddleboarding, and sunset bonfires.',
      isAiGenerated: false,
      status: TripStatus.completed,
      isOrganizer: true,
      currentDay: 3,
      days: const [
        TripDaySchedule(dayNumber: 1, dateLabel: 'Oct 10'),
        TripDaySchedule(dayNumber: 2, dateLabel: 'Oct 11'),
        TripDaySchedule(dayNumber: 3, dateLabel: 'Oct 12'),
      ],
      members: const [
        TripMemberModel(name: 'Maya Reyes', role: 'Organizer'),
        TripMemberModel(name: 'Louielyn Abella', role: 'Member'),
        TripMemberModel(name: 'Ellle Bernante', role: 'Member'),
        TripMemberModel(name: 'Carla Santos', role: 'Member'),
        TripMemberModel(name: 'Sarah Jenkins', role: 'Member'),
        TripMemberModel(name: 'Mark Lim', role: 'Member'),
      ],
      itineraryItems: const [
        ItineraryItemModel(
          id: 'it-s1',
          tripId: 'seed-trip-2',
          category: 'Activity',
          placeName: 'Cloud 9 Boardwalk',
          location: 'General Luna, Siargao',
          title: 'Morning Surf Lesson',
          startTime: '7:00 AM',
          endTime: '9:30 AM',
          dayNumber: 3,
        ),
        ItineraryItemModel(
          id: 'it-s2',
          tripId: 'seed-trip-2',
          category: 'Food',
          placeName: 'Shaka Cafe',
          location: 'Tourism Road, Siargao',
          title: 'Smoothie Bowls at Shaka',
          startTime: '10:00 AM',
          endTime: '11:30 AM',
          dayNumber: 3,
        ),
      ],
    ),
    TripModel(
      id: 'seed-trip-3',
      groupName: 'Blackpink',
      name: 'Baguio Pine Retreat',
      destination: 'Baguio, Philippines',
      startDate: 'Sep 04',
      endDate: 'Sep 06',
      fullDateRange: 'September 4 - September 6',
      sortDate: DateTime(2026, 9, 4),
      meetingPlace: 'Victory Liner Cubao',
      description:
          'Cool mountain air, pine forest cafes, night market food crawl, and Camp John Hay.',
      isAiGenerated: false,
      status: TripStatus.cancelled,
      isOrganizer: true,
      currentDay: 1,
      days: const [
        TripDaySchedule(dayNumber: 1, dateLabel: 'Sep 04'),
        TripDaySchedule(dayNumber: 2, dateLabel: 'Sep 05'),
        TripDaySchedule(dayNumber: 3, dateLabel: 'Sep 06'),
      ],
      members: const [
        TripMemberModel(name: 'Maya Reyes', role: 'Organizer'),
        TripMemberModel(name: 'Miguel Ramos', role: 'Member'),
        TripMemberModel(name: 'Marco Rivera', role: 'Member'),
        TripMemberModel(name: 'Carla Santos', role: 'Member'),
        TripMemberModel(name: 'Sarah Jenkins', role: 'Member'),
        TripMemberModel(name: 'Mark Lim', role: 'Member'),
      ],
      itineraryItems: const [
        ItineraryItemModel(
          id: 'it-b1',
          tripId: 'seed-trip-3',
          category: 'Check-in',
          placeName: 'The Manor',
          location: 'Camp John Hay, Baguio',
          title: 'Check in at The Manor',
          startTime: '2:00 PM',
          endTime: '3:00 PM',
          dayNumber: 1,
        ),
      ],
    ),
    TripModel(
      id: 'seed-trip-4',
      groupName: 'The Group',
      name: 'El Nido Escape',
      destination: 'El Nido, Palawan',
      startDate: 'Dec 18',
      endDate: 'Dec 20',
      fullDateRange: 'December 18 - December 20',
      sortDate: DateTime(2026, 12, 18),
      meetingPlace: 'Lio Airport Terminal',
      description:
          'Big Lagoon kayaking, hidden beaches, and sunset cocktails by Corong-Corong.',
      isAiGenerated: true,
      status: TripStatus.upcoming,
      isOrganizer: true,
      currentDay: 1,
      days: const [
        TripDaySchedule(dayNumber: 1, dateLabel: 'Dec 18'),
        TripDaySchedule(dayNumber: 2, dateLabel: 'Dec 19'),
        TripDaySchedule(dayNumber: 3, dateLabel: 'Dec 20'),
      ],
      members: const [
        TripMemberModel(name: 'Maya Reyes', role: 'Organizer'),
        TripMemberModel(name: 'Miguel Ramos', role: 'Member'),
        TripMemberModel(name: 'Marco Rivera', role: 'Member'),
        TripMemberModel(name: 'Mina Roque', role: 'Member'),
        TripMemberModel(name: 'Carla Santos', role: 'Member'),
      ],
      itineraryItems: const [
        ItineraryItemModel(
          id: 'it-e1',
          tripId: 'seed-trip-4',
          category: 'Activity',
          placeName: 'Big Lagoon',
          location: 'Miniloc Island, El Nido',
          title: 'Tour A Lagoon Hopping',
          startTime: '8:30 AM',
          endTime: '12:00 PM',
          dayNumber: 1,
        ),
        ItineraryItemModel(
          id: 'it-e2',
          tripId: 'seed-trip-4',
          category: 'Check-in',
          placeName: 'Piece Lio Resort',
          location: 'Lio Tourism Estate',
          title: 'Check in at Piece Lio',
          startTime: '2:00 PM',
          endTime: '3:30 PM',
          dayNumber: 1,
        ),
      ],
    ),
  ];

  TripModel? getTripById(String tripId) {
    for (final trip in tripsNotifier.value) {
      if (trip.id == tripId) return trip;
    }
    return null;
  }

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

  /// Updates an existing trip (Edit Trip action).
  Future<void> updateTrip(TripModel updated) async {
    tripsNotifier.value = tripsNotifier.value
        .map((t) => t.id == updated.id ? updated : t)
        .toList();

    try {
      final client = Supabase.instance.client;
      await client.from('trips').update({
        'name': updated.name,
        'destination': updated.destination,
        'start_date': updated.startDate,
        'end_date': updated.endDate,
        'meeting_place': updated.meetingPlace,
        'description': updated.description,
        'status': updated.status.name,
      }).eq('id', updated.id);
    } catch (e) {
      debugPrint('Supabase trips update fallback (updated locally): $e');
    }
  }

  /// Cancels a trip and keeps it in history with `TripStatus.cancelled`.
  Future<void> cancelTrip(String tripId, {String? reason}) async {
    final trimmedReason = reason?.trim();
    tripsNotifier.value = tripsNotifier.value
        .map(
          (t) => t.id == tripId
              ? t.copyWith(
                  status: TripStatus.cancelled,
                  cancellationReason:
                      (trimmedReason != null && trimmedReason.isNotEmpty)
                          ? trimmedReason
                          : t.cancellationReason,
                )
              : t,
        )
        .toList();

    try {
      final client = Supabase.instance.client;
      await client
          .from('trips')
          .update({
            'status': TripStatus.cancelled.name,
            if (trimmedReason != null && trimmedReason.isNotEmpty)
              'cancellation_reason': trimmedReason,
          })
          .eq('id', tripId);
    } catch (e) {
      debugPrint('Supabase trips cancel fallback (cancelled locally): $e');
    }
  }

  /// Permanently deletes a trip from the repository.
  Future<void> deleteTrip(String tripId) async {
    tripsNotifier.value =
        tripsNotifier.value.where((t) => t.id != tripId).toList();

    try {
      final client = Supabase.instance.client;
      await client.from('trips').delete().eq('id', tripId);
    } catch (e) {
      debugPrint('Supabase trips delete fallback (deleted locally): $e');
    }
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
    int dayNumber = 1,
  }) async {
    final item = ItineraryItemModel(
      id: 'item-${DateTime.now().millisecondsSinceEpoch}',
      tripId: tripId,
      category: category,
      placeName: placeName,
      location: location,
      title: title,
      startTime: startTime,
      endTime: endTime,
      notes: notes,
      dayNumber: dayNumber,
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
        startDate.trim().isNotEmpty ? startDate.trim() : 'Nov 13';
    final resolvedEnd = endDate.trim().isNotEmpty ? endDate.trim() : 'Nov 15';
    final resolvedMeeting = meetingPlace.trim().isNotEmpty
        ? meetingPlace.trim()
        : 'North Bus Terminal';

    String tripId = 'trip-${DateTime.now().millisecondsSinceEpoch}';

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
      fullDateRange: '$resolvedStart - $resolvedEnd',
      sortDate: DateTime.now(),
      meetingPlace: resolvedMeeting,
      description: description.trim(),
      isAiGenerated: isAiGenerated,
      status: TripStatus.upcoming,
      isOrganizer: true,
      currentDay: 1,
      days: [
        TripDaySchedule(dayNumber: 1, dateLabel: resolvedStart),
        TripDaySchedule(dayNumber: 2, dateLabel: resolvedEnd),
      ],
      members: members,
      itineraryItems: itineraryItems,
    );

    tripsNotifier.value = [newTrip, ...tripsNotifier.value];
    return newTrip;
  }
}
