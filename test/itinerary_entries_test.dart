import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:anotara/components/atoms/app_button.dart';
import 'package:anotara/features/itinerary/data/itinerary_entry.dart';
import 'package:anotara/features/itinerary/presentation/screens/itinerary_entry_form_screen.dart';
import 'package:anotara/features/itinerary/presentation/screens/itinerary_screen.dart';
import 'package:anotara/features/itinerary/presentation/widgets/itinerary_map.dart';
import 'package:anotara/features/trips/data/trip_repository.dart';

final _repo = TripRepository.instance;

ItineraryItemModel _item(String id, String title, int day, String start) =>
    ItineraryItemModel(
      id: id,
      tripId: 't1',
      category: 'Food',
      placeName: 'Jollibee Santa Fe',
      location: 'Santa Fe, Bantayan',
      title: title,
      startTime: start,
      endTime: '11:00 PM',
      dayNumber: day,
    );

final _days = [
  DateTime(2026, 11, 13),
  DateTime(2026, 11, 14),
  DateTime(2026, 11, 15),
];

void main() {
  setUp(() {
    ItineraryMap.showTiles = false;
    GoogleFonts.config.allowRuntimeFetching = false;
    _repo.manualItineraryItemsNotifier.value = [];
  });

  void useTallPhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(375, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  bool saveDisabled(WidgetTester tester) => tester
      .widget<AppButton>(find.byKey(const ValueKey('entry-save')))
      .isDisabled;

  Future<void> pickTime(WidgetTester tester, String field) async {
    await tester.tap(find.byKey(ValueKey(field)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }

  /// Lets real (non-fake-async) font loading finish, then handles the
  /// relayout it schedules, so it does not fire after the tree is disposed.
  Future<void> settleFonts(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
  }

  test('time helpers parse, format and sort', () {
    expect(ItineraryTime.format(const TimeOfDay(hour: 0, minute: 5)),
        '12:05 AM');
    expect(ItineraryTime.parse('1:30 PM'),
        const TimeOfDay(hour: 13, minute: 30));
    expect(ItineraryTime.parse('nope'), isNull);
    final sorted = entriesForDay([
      _item('b', 'Lunch', 1, '12:30 PM'),
      _item('a', 'Breakfast', 1, '8:00 AM'),
      _item('c', 'Other day', 2, '7:00 AM'),
    ], 1);
    expect(sorted.map((e) => e.title), ['Breakfast', 'Lunch']);
  });

  testWidgets('Add Entry: Save stays disabled until required fields are set',
      (tester) async {
    useTallPhone(tester);
    EntryFormResult? result;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              result = await Navigator.of(context).push<EntryFormResult>(
                MaterialPageRoute(
                  builder: (_) => const ItineraryEntryFormScreen(
                    tripId: 't1',
                    destination: 'Bantayan',
                    dayNumber: 2,
                  ),
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Add Entry'), findsOneWidget);
    expect(saveDisabled(tester), isTrue);

    await tester.tap(find.text('Dining'));
    await tester.pump();
    expect(saveDisabled(tester), isTrue);

    // Location: search → Top Picks Nearby → Confirm Location.
    await tester.tap(find.text('Add a location'));
    await tester.pumpAndSettle();
    expect(find.text('Top Picks Nearby'), findsOneWidget);
    await tester.tap(find.text('Hannah\'s Beach Resort'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(AppButton, 'Confirm Location'));
    await tester.pumpAndSettle();
    expect(find.text('Hannah\'s Beach Resort'), findsOneWidget);
    expect(find.text('View in Map'), findsOneWidget);
    expect(saveDisabled(tester), isTrue);

    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('entry-title')),
        matching: find.byType(EditableText),
      ),
      'Dinner at the resort',
    );
    await tester.pump();
    expect(saveDisabled(tester), isTrue);

    await pickTime(tester, 'entry-start'); // 9:00 AM
    expect(saveDisabled(tester), isTrue);
    await pickTime(tester, 'entry-end'); // 10:00 AM
    expect(saveDisabled(tester), isFalse);

    await tester.tap(find.byKey(const ValueKey('entry-save')));
    await tester.pumpAndSettle();

    expect(result?.deleted, isFalse);
    final saved = _repo.itineraryItemsForTrip('t1').single;
    expect(saved.title, 'Dinner at the resort');
    expect(saved.category, 'Food');
    expect(saved.placeName, 'Hannah\'s Beach Resort');
    expect(saved.timeRange, '9:00 AM - 10:00 AM');
    expect(saved.dayNumber, 2);
    expect(saved.hasCoordinates, isTrue);
    await settleFonts(tester);
  });

  testWidgets('day navigation shows each day\'s entries or the empty state',
      (tester) async {
    useTallPhone(tester);
    _repo.manualItineraryItemsNotifier.value = [
      _item('a', 'Eat at Jollibee', 1, '9:00 AM'),
      _item('b', 'Island hopping', 2, '9:00 AM'),
    ];
    await tester.pumpWidget(MaterialApp(
      home: ItineraryScreen(
        tripId: 't1',
        destination: 'Bantayan',
        tripDays: _days,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Day 1 of 3'), findsOneWidget);
    expect(find.text('Eat at Jollibee'), findsOneWidget);
    expect(find.text('Add to Itinerary'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Next day'));
    await tester.pumpAndSettle();
    expect(find.text('Day 2 of 3'), findsOneWidget);
    expect(find.text('Saturday, November 14'), findsOneWidget);
    expect(find.text('Island hopping'), findsOneWidget);
    expect(find.text('Eat at Jollibee'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Next day'));
    await tester.pumpAndSettle();
    expect(find.text('Day 3 of 3'), findsOneWidget);
    expect(find.text('No itinerary yet'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Previous day'));
    await tester.pumpAndSettle();
    expect(find.text('Day 2 of 3'), findsOneWidget);
  });

  testWidgets('select mode deletes the chosen entries after confirming',
      (tester) async {
    useTallPhone(tester);
    _repo.manualItineraryItemsNotifier.value = [
      _item('a', 'Breakfast', 1, '8:00 AM'),
      _item('b', 'Island hopping', 1, '9:30 AM'),
      _item('c', 'Dinner', 1, '7:00 PM'),
    ];
    await tester.pumpWidget(MaterialApp(
      home: ItineraryScreen(
        tripId: 't1',
        destination: 'Bantayan',
        tripDays: _days,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();
    expect(find.text('0 Selected'), findsOneWidget);
    expect(
      tester
          .widget<AppButton>(find.byKey(const ValueKey('delete-selected')))
          .isDisabled,
      isTrue,
    );

    await tester.tap(find.text('Breakfast'));
    await tester.tap(find.text('Dinner'));
    await tester.pumpAndSettle();
    expect(find.text('2 Selected'), findsOneWidget);
    expect(find.text('Delete (2)'), findsOneWidget);

    await tester.tap(find.text('Delete (2)'));
    await tester.pumpAndSettle();
    expect(find.text('Delete Entries'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(
      _repo.itineraryItemsForTrip('t1').map((e) => e.title),
      ['Island hopping'],
    );
    expect(find.text('Breakfast'), findsNothing);
    expect(find.text('Island hopping'), findsOneWidget);
    expect(find.text('View Itinerary'), findsOneWidget); // left select mode
  });
}
