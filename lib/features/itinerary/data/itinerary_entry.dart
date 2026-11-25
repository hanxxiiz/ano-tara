import 'package:flutter/material.dart';

import '../../trips/data/trip_repository.dart';

/// The three entry types on the Add / Edit Entry form (07.16).
enum ItineraryEntryType {
  accommodation('Accommodation', 'Accommodation'),
  activity('Activity', 'Activity'),
  dining('Dining', 'Food');

  /// Label on the type option card.
  final String label;

  /// Value stored in [ItineraryItemModel.category] and shown on the card chip.
  final String category;

  const ItineraryEntryType(this.label, this.category);

  /// Maps a stored category (including AI ones like "Place") to a type.
  static ItineraryEntryType fromCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'dining':
        return ItineraryEntryType.dining;
      case 'accommodation':
      case 'place/check-in':
      case 'check-in':
        return ItineraryEntryType.accommodation;
      default:
        return ItineraryEntryType.activity;
    }
  }
}

/// "9:00 AM" ↔ [TimeOfDay] helpers. Entry times are stored as display text.
class ItineraryTime {
  ItineraryTime._();

  static String format(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Parses "9:00 AM" / "12:30 pm". Returns `null` for anything else.
  static TimeOfDay? parse(String text) {
    final match = RegExp(r'^\s*(\d{1,2}):(\d{2})\s*([AaPp][Mm])\s*$')
        .firstMatch(text);
    if (match == null) return null;
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour < 1 || hour > 12 || minute > 59) return null;
    final pm = match.group(3)!.toLowerCase() == 'pm';
    return TimeOfDay(hour: (hour % 12) + (pm ? 12 : 0), minute: minute);
  }

  static int toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  /// Sort key for an entry; unparseable times go last.
  static int sortKey(String text) {
    final time = parse(text);
    return time == null ? 24 * 60 : toMinutes(time);
  }
}

/// Entries of one day, ordered by start time.
List<ItineraryItemModel> entriesForDay(
  Iterable<ItineraryItemModel> items,
  int day,
) {
  return items.where((i) => i.dayNumber == day).toList()
    ..sort(
      (a, b) => ItineraryTime.sortKey(a.startTime)
          .compareTo(ItineraryTime.sortKey(b.startTime)),
    );
}
