import 'package:flutter/material.dart';

import 'expense.dart';

class TripMember {
  const TripMember({
    required this.id,
    required this.name,
    this.userId,
    this.isYou = false,
  });

  final String id;
  final String name;

  /// Supabase auth user id; needed to save this member's expense shares.
  final String? userId;

  /// The signed-in member ("You" in the designs).
  final bool isYou;

  String get displayName => isYou ? 'You ($name)' : name;
  String get shortName => isYou ? 'You' : name;
}

class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}

class MeetingPoint {
  const MeetingPoint({this.id, required this.name, required this.position});

  /// `meeting_points.id` once saved to Supabase.
  final String? id;
  final String name;
  final GeoPoint position;

  MeetingPoint copyWith({String? id, String? name, GeoPoint? position}) =>
      MeetingPoint(
        id: id ?? this.id,
        name: name ?? this.name,
        position: position ?? this.position,
      );
}

class MemberLocation {
  const MemberLocation({required this.memberId, required this.position});

  /// [TripMember.id] of whoever is sharing.
  final String memberId;
  final GeoPoint position;
}

class TripGroup {
  const TripGroup({
    required this.id,
    required this.name,
    required this.memberCount,
    this.members = const [],
  });

  final String id;
  final String name;
  final int memberCount;
  final List<TripMember> members;

  TripMember? memberById(String id) {
    for (final m in members) {
      if (m.id == id) return m;
    }
    return null;
  }
}

enum ActivityCategory {
  activity('Activity', Icons.landscape_rounded),
  food('Food', Icons.restaurant_rounded),
  checkIn('Check-in', Icons.home_rounded),
  transport('Transport', Icons.directions_boat_rounded),
  other('Other', Icons.place_rounded);

  const ActivityCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}

class ItineraryItem {
  const ItineraryItem({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.start,
    required this.end,
  });

  final String id;
  final String title;
  final ActivityCategory category;
  final String location;
  final DateTime start;
  final DateTime end;

  bool isHappeningAt(DateTime moment) =>
      !moment.isBefore(start) && moment.isBefore(end);
}

enum TripStatus {
  upcoming('Upcoming'),
  ongoing('Ongoing'),
  past('Past');

  const TripStatus(this.label);

  final String label;
}

class Trip {
  Trip({
    required this.id,
    required this.title,
    required this.destination,
    required this.group,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.isOrganizer,
    this.organizerId,
    this.remoteId,
    List<ItineraryItem>? itinerary,
    List<Expense>? expenses,
    this.meetingPoint,
    List<MemberLocation>? memberLocations,
  }) : itinerary = itinerary ?? [],
       expenses = expenses ?? [],
       memberLocations = memberLocations ?? [];

  final String id;

  /// `trips.id` in Supabase. Null for trips that only exist on this device
  /// (the sample data), whose expenses can't be saved to Supabase.
  final String? remoteId;

  /// Renamed by the organizer from the overview header.
  String title;
  final String destination;
  final TripGroup group;

  /// Date-only (time is ignored).
  final DateTime startDate;
  final DateTime endDate;
  final String description;

  /// Whether the signed-in member organized this trip (shows edit controls).
  final bool isOrganizer;

  /// [TripMember.id] of whoever organized the trip.
  final String? organizerId;

  TripMember? get organizer =>
      organizerId == null ? null : group.memberById(organizerId!);

  final List<ItineraryItem> itinerary;
  final List<Expense> expenses;

  /// Where the group meets up; only the organizer can change it.
  MeetingPoint? meetingPoint;

  /// Members currently sharing their location.
  final List<MemberLocation> memberLocations;

  List<Expense> expensesOn(DateTime day) =>
      expenses.where((e) => _dateOnly(e.occurredAt) == _dateOnly(day)).toList()
        ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));

  /// Every calendar day the trip covers, in order.
  List<DateTime> get days {
    final first = _dateOnly(startDate);
    final last = _dateOnly(endDate);
    return [
      for (
        var d = first;
        !d.isAfter(last);
        d = DateTime(d.year, d.month, d.day + 1)
      )
        d,
    ];
  }

  TripStatus statusAt(DateTime moment) {
    final today = _dateOnly(moment);
    if (today.isBefore(_dateOnly(startDate))) return TripStatus.upcoming;
    if (today.isAfter(_dateOnly(endDate))) return TripStatus.past;
    return TripStatus.ongoing;
  }

  List<ItineraryItem> get sortedItinerary =>
      [...itinerary]..sort((a, b) => a.start.compareTo(b.start));

  List<ItineraryItem> itemsOn(DateTime day) => sortedItinerary
      .where((item) => _dateOnly(item.start) == _dateOnly(day))
      .toList();

  ItineraryItem? happeningAt(DateTime moment) {
    for (final item in sortedItinerary) {
      if (item.isHappeningAt(moment)) return item;
    }
    return null;
  }

  ItineraryItem? nextAfter(DateTime moment) {
    for (final item in sortedItinerary) {
      if (item.start.isAfter(moment)) return item;
    }
    return null;
  }
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
