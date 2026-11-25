import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:anotara/components/atoms/app_button.dart';
import 'package:anotara/features/itinerary/presentation/widgets/itinerary_map.dart';
import 'package:anotara/features/trips/presentation/screens/create_trip_screen.dart';
import 'package:anotara/features/trips/presentation/screens/edit_trip_screen.dart';
import 'package:anotara/features/trips/presentation/widgets/trip_form_widgets.dart';
import 'package:anotara/models/group_models.dart';

final _group = GroupDetails.sample('The Group');

void main() {
  setUp(() {
    ItineraryMap.showTiles = false;
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  void useTallPhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(375, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  /// Lets real font loading finish, then handles the relayout it schedules.
  Future<void> settleFonts(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
  }

  /// Pushes [page] from a host screen and records what it pops with.
  Future<List<Object?>> pushFromHost(WidgetTester tester, Widget page) async {
    final popped = <Object?>[];
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              popped.add(
                await Navigator.of(context).push<Object?>(
                  MaterialPageRoute(builder: (_) => page),
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
    return popped;
  }

  Finder field(String key) => find.descendant(
    of: find.byKey(ValueKey(key)),
    matching: find.byType(EditableText),
  );

  Future<void> pickDate(WidgetTester tester, String key) async {
    await tester.tap(field(key));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }

  test('end date before the start date is rejected', () {
    final c = TripEssentialsController()
      ..name.text = 'Beach trip'
      ..meetingPlace.text = 'Terminal'
      ..startDate = DateTime(2026, 12, 20)
      ..endDate = DateTime(2026, 12, 18);
    c.destination = null;
    expect(c.validate(), isFalse);
    expect(c.errorFor(TripField.endDate), 'Must be on or after the start date');
    expect(c.errorFor(TripField.name), isNull);
    c.dispose();
  });

  testWidgets('required trip essentials show validation errors',
      (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(
      MaterialApp(home: CreateTripScreen(group: _group)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Set up your trip essentials'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('trip-continue')));
    await tester.pumpAndSettle();

    expect(find.text('Trip name is required'), findsOneWidget);
    expect(find.text('Choose a destination'), findsOneWidget);
    expect(find.text('Pick a start date'), findsOneWidget);
    expect(find.text('Pick an end date'), findsOneWidget);
    expect(find.text('Meeting place is required'), findsOneWidget);
    // Still on the essentials step.
    expect(find.text('Who\'s coming?'), findsNothing);

    // Typing clears that field's error.
    await tester.enterText(field('trip-name'), 'Siargao Getaway');
    await tester.pump();
    expect(find.text('Trip name is required'), findsNothing);
    await settleFonts(tester);
  });

  testWidgets('creating a trip opens the ready screen', (tester) async {
    useTallPhone(tester);
    final popped = await pushFromHost(
      tester,
      CreateTripScreen(group: _group),
    );

    await tester.enterText(field('trip-name'), 'Siargao Getaway');

    // Destination: search → pick → Confirm Location.
    await tester.tap(field('trip-destination'));
    await tester.pumpAndSettle();
    expect(find.text('Select Destination'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('destination-search')),
      'siar',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Siargao Island').last);
    await tester.pumpAndSettle();
    expect(find.text('Selected Location'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('confirm-destination')));
    await tester.pumpAndSettle();
    expect(find.text('Siargao Island'), findsOneWidget);

    await pickDate(tester, 'trip-start');
    await pickDate(tester, 'trip-end');
    await tester.enterText(field('trip-meeting'), 'Cebu Airport');
    await tester.tap(find.byKey(const ValueKey('trip-continue')));
    await tester.pumpAndSettle();

    // Who's coming: two quick taps must both stick.
    expect(find.text('Who\'s coming?'), findsOneWidget);
    expect(find.text('Select all members'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('participant-hannah')));
    await tester.tap(find.byKey(const ValueKey('participant-elle')));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('trip-create')));
    await tester.pumpAndSettle();

    expect(find.text('Your trip is ready!'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Plan Itinerary'), findsOneWidget);
    await tester.tap(find.widgetWithText(AppButton, 'View Trip'));
    await tester.pumpAndSettle();

    final result = popped.single as CreateTripResult;
    expect(result.action, TripReadyAction.viewTrip);
    expect(result.trip.title, 'Siargao Getaway');
    expect(result.trip.location, 'Siargao Island');
    expect(result.trip.meetingPlace, 'Cebu Airport');
    expect(
      result.trip.memberNames,
      [GroupMember.me.name, 'Hannah Labandero', 'Elle Bernante'],
    );
    await settleFonts(tester);
  });

  testWidgets('Edit Trip validates and saves changes', (tester) async {
    useTallPhone(tester);
    final trip = _group.trips.first;
    final popped = await pushFromHost(
      tester,
      EditTripScreen(group: _group, trip: trip),
    );

    expect(find.text('Edit Trip'), findsOneWidget);
    expect(find.text(trip.title), findsOneWidget);

    await tester.enterText(field('trip-name'), '');
    await tester.tap(find.byKey(const ValueKey('trip-save')));
    await tester.pumpAndSettle();
    expect(find.text('Trip name is required'), findsOneWidget);
    expect(popped, isEmpty);

    await tester.enterText(field('trip-name'), 'Renamed Trip');
    await tester.enterText(field('trip-meeting'), 'Pier 3');
    await tester.tap(find.byKey(const ValueKey('trip-save')));
    await tester.pumpAndSettle();

    final updated = popped.single as GroupTrip;
    expect(updated.id, trip.id);
    expect(updated.title, 'Renamed Trip');
    expect(updated.meetingPlace, 'Pier 3');
    expect(updated.location, trip.location);
    await settleFonts(tester);
  });
}
