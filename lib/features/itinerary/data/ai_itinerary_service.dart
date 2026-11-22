import 'package:supabase_flutter/supabase_flutter.dart';

import '../../trips/data/trip_repository.dart';

/// What the organizer asked the AI to plan (07.17 / 07.18).
enum AiPlanScope { thisDay, wholeTrip }

/// Everything the AI needs to draft suggestions for a trip.
class AiItineraryRequest {
  final String? tripId;
  final String destination;

  /// Number of days in the trip (Day 1 … Day [dayCount]).
  final int dayCount;

  /// 1-based day the user was viewing when they opened the sheet.
  final int selectedDay;
  final AiPlanScope scope;

  /// Entries already on the itinerary. The AI must only fill free time
  /// around these and never replace them.
  final List<ItineraryItemModel> existingItems;

  const AiItineraryRequest({
    this.tripId,
    required this.destination,
    required this.dayCount,
    required this.selectedDay,
    required this.scope,
    this.existingItems = const [],
  });

  /// Days the AI is allowed to add suggestions to.
  List<int> get targetDays => scope == AiPlanScope.thisDay
      ? [selectedDay]
      : List<int>.generate(dayCount, (i) => i + 1);

  Map<String, dynamic> toJson() => {
        if (tripId != null) 'trip_id': tripId,
        'destination': destination,
        'day_count': dayCount,
        'selected_day': selectedDay,
        'scope': scope == AiPlanScope.thisDay ? 'day' : 'trip',
        'target_days': targetDays,
        'existing_items': existingItems
            .map((i) => {
                  'day_number': i.dayNumber,
                  'title': i.title,
                  'start_time': i.startTime,
                  'end_time': i.endTime,
                })
            .toList(),
      };
}

/// One AI-proposed itinerary entry shown on the review screen (08.06).
class AiItinerarySuggestion {
  final String id;
  final int dayNumber;

  /// Display category, e.g. "Food", "Activity", "Place".
  final String category;
  final String title;
  final String location;
  final String startTime;
  final String endTime;

  const AiItinerarySuggestion({
    required this.id,
    required this.dayNumber,
    required this.category,
    required this.title,
    required this.location,
    required this.startTime,
    required this.endTime,
  });

  String get timeRange => '$startTime - $endTime';

  factory AiItinerarySuggestion.fromJson(Map<String, dynamic> json) {
    String str(String key, [String fallback = '']) =>
        (json[key] ?? fallback).toString();
    return AiItinerarySuggestion(
      id: str('id', 'ai-${DateTime.now().microsecondsSinceEpoch}'),
      dayNumber: int.tryParse(str('day_number', '1')) ?? 1,
      category: str('category', 'Activity'),
      title: str('title'),
      location: str('location'),
      startTime: str('start_time'),
      endTime: str('end_time'),
    );
  }

  ItineraryItemModel toItineraryItem({String? tripId}) => ItineraryItemModel(
        id: id,
        tripId: tripId,
        category: category,
        placeName: title,
        location: location,
        title: title,
        startTime: startTime,
        endTime: endTime,
        dayNumber: dayNumber,
      );
}

/// Thrown when itinerary generation fails. [message] is shown to the user.
class AiItineraryException implements Exception {
  final String message;
  const AiItineraryException(this.message);

  @override
  String toString() => 'AiItineraryException: $message';
}

/// Source of AI itinerary suggestions. Swap the implementation passed to the
/// flow (see [defaultAiItineraryService]) without touching the UI.
abstract class AiItineraryService {
  Future<List<AiItinerarySuggestion>> generate(AiItineraryRequest request);
}

/// Calls the Supabase Edge Function `generate-itinerary`.
///
/// Expected response body: `{ "suggestions": [ { day_number, category, title,
/// location, start_time, end_time }, ... ] }`.
class SupabaseAiItineraryService implements AiItineraryService {
  final String functionName;
  const SupabaseAiItineraryService({this.functionName = 'generate-itinerary'});

  @override
  Future<List<AiItinerarySuggestion>> generate(
    AiItineraryRequest request,
  ) async {
    try {
      final response = await Supabase.instance.client.functions
          .invoke(functionName, body: request.toJson());
      final data = response.data;
      final raw = data is Map ? data['suggestions'] : null;
      if (raw is! List) {
        throw const AiItineraryException(
          'We got an unexpected response from the AI. Please try again.',
        );
      }
      final suggestions = raw
          .whereType<Map>()
          .map((e) => AiItinerarySuggestion.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .where((s) => request.targetDays.contains(s.dayNumber))
          .toList();
      if (suggestions.isEmpty) {
        throw const AiItineraryException(
          'The AI couldn\'t find anything to add for these days. '
          'Try again or add entries manually.',
        );
      }
      return suggestions;
    } on AiItineraryException {
      rethrow;
    } catch (_) {
      throw const AiItineraryException(
        'Something went wrong while creating your itinerary. '
        'Check your connection and try again.',
      );
    }
  }
}

/// Local stand-in used until the `generate-itinerary` Edge Function exists.
/// Set [failNextRequests] to exercise the failure screen.
class MockAiItineraryService implements AiItineraryService {
  final Duration latency;
  int failNextRequests;

  MockAiItineraryService({
    this.latency = const Duration(seconds: 4),
    this.failNextRequests = 0,
  });

  static const _templates = [
    ('Food', 'Breakfast at a local café', '8:00 AM', '9:00 AM'),
    ('Activity', 'Island hopping tour', '9:30 AM', '12:00 PM'),
    ('Food', 'Seafood lunch by the beach', '12:30 PM', '1:30 PM'),
    ('Place', 'Explore the town plaza', '2:00 PM', '4:00 PM'),
    ('Activity', 'Sunset at the beach', '5:00 PM', '6:30 PM'),
    ('Food', 'Group dinner', '7:00 PM', '8:30 PM'),
  ];

  @override
  Future<List<AiItinerarySuggestion>> generate(
    AiItineraryRequest request,
  ) async {
    await Future<void>.delayed(latency);
    if (failNextRequests > 0) {
      failNextRequests--;
      throw const AiItineraryException(
        'Something went wrong while creating your itinerary. '
        'Check your connection and try again.',
      );
    }

    final suggestions = <AiItinerarySuggestion>[];
    for (final day in request.targetDays) {
      // Leave time already taken by existing entries alone.
      final taken = request.existingItems
          .where((i) => i.dayNumber == day)
          .map((i) => i.startTime)
          .toSet();
      var index = 0;
      for (final t in _templates) {
        if (taken.contains(t.$3)) continue;
        suggestions.add(AiItinerarySuggestion(
          id: 'ai-$day-${index++}-${DateTime.now().microsecondsSinceEpoch}',
          dayNumber: day,
          category: t.$1,
          title: t.$2,
          location: request.destination,
          startTime: t.$3,
          endTime: t.$4,
        ));
      }
    }
    return suggestions;
  }
}

/// Service the AI flow uses when none is injected.
/// TODO: switch to `SupabaseAiItineraryService()` once the
/// `generate-itinerary` Edge Function is deployed.
AiItineraryService defaultAiItineraryService = MockAiItineraryService();
