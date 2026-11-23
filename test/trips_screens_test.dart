import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anotara/features/trips/data/trip_repository.dart';
import 'package:anotara/features/trips/presentation/screens/trips_list_screen.dart';
import 'package:anotara/features/trips/presentation/screens/trip_overview_screen.dart';
import 'package:anotara/features/trips/presentation/widgets/filter_trips_sheet.dart';
import 'package:anotara/features/trips/presentation/widgets/trip_actions_sheet.dart';

void main() {
  testWidgets(
    'TripsListScreen renders trips with status pills, searches, and opens Filter Trips sheet',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TripsListScreen()));
      await tester.pumpAndSettle();

      expect(find.text('El Nido Escape'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Bantayan Trip'), findsOneWidget);
      expect(find.text('Ongoing'), findsOneWidget);

      // Scroll down to verify Completed & Cancelled status pills
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);

      // Search filters the list
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 500));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Bantayan');
      await tester.pumpAndSettle();
      expect(find.text('Bantayan Trip'), findsOneWidget);
      expect(find.text('El Nido Escape'), findsNothing);
    },
  );

  testWidgets('FilterTripsSheet displays all status, role, and sort options', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FilterTripsSheet(initialFilter: TripFilterState()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Filter Trips'), findsOneWidget);
    expect(find.text('Trip Status'), findsOneWidget);
    expect(find.text('Your Role'), findsOneWidget);
    expect(find.text('Sort By'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
    expect(find.text('Apply Filters'), findsOneWidget);
  });

  testWidgets(
    'TripOverviewScreen shows organizer overview, Day X of Y, cards, and Happening Now / Up Next',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: TripOverviewScreen(tripId: 'seed-trip-1')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bantayan Trip'), findsOneWidget);
      expect(find.text('Ongoing'), findsOneWidget);
      expect(find.text('ABOUT THIS TRIP'), findsOneWidget);
      expect(find.text('Itinerary'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Members'), findsOneWidget);
      expect(find.text('Map'), findsOneWidget);
      expect(find.text('Happening Now'), findsOneWidget);
      expect(find.text('Up Next'), findsOneWidget);
      expect(find.text('Island Hopping'), findsOneWidget);
      expect(find.text('Check in at Kota Resort'), findsOneWidget);
    },
  );

  testWidgets('TripActionsSheet, CancelTripDialog, and DeleteTripDialog render properly', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TripActionsSheet())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Trip Actions'), findsOneWidget);
    expect(find.text('Edit Trip'), findsOneWidget);
    expect(find.text('Cancel Trip'), findsOneWidget);
    expect(find.text('Delete Trip'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CancelTripDialog())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Cancel Trip'), findsNWidgets(2));

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: DeleteTripDialog())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Delete Trip'), findsNWidgets(2));
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('Trip actions show only to the Organizer', (tester) async {
    final nonOrgTrip = TripModel(
      id: 'non-org-trip',
      groupName: 'Friends',
      name: 'Bohol Weekend',
      destination: 'Panglao, Bohol',
      startDate: 'Dec 28',
      endDate: 'Dec 30',
      meetingPlace: 'Pier 1',
      description: 'Joined trip test.',
      isAiGenerated: false,
      status: TripStatus.upcoming,
      isOrganizer: false,
      members: const [TripMemberModel(name: 'Maya Reyes', role: 'Organizer')],
      itineraryItems: const [],
    );

    TripRepository.instance.tripsNotifier.value = [
      ...TripRepository.instance.tripsNotifier.value,
      nonOrgTrip,
    ];

    await tester.pumpWidget(
      const MaterialApp(home: TripOverviewScreen(tripId: 'non-org-trip')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bohol Weekend'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);

    // Clean up test trip
    await TripRepository.instance.deleteTrip('non-org-trip');
  });

  testWidgets('No RenderFlex overflows on narrow 360x640 viewport across all trip screens and sheets', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. TripsListScreen
    await tester.pumpWidget(const MaterialApp(home: TripsListScreen()));
    await tester.pumpAndSettle();

    // 2. Open FilterTripsSheet via modal bottom sheet
    final filterBtn = find.byType(GestureDetector).at(3);
    expect(filterBtn, findsOneWidget);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (ctx) => Scaffold(
            body: ElevatedButton(
              onPressed: () => FilterTripsSheet.show(
                ctx,
                initialFilter: const TripFilterState(),
              ),
              child: const Text('Open Filter'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open Filter'));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.text('Filter Trips'))).pop();
    await tester.pumpAndSettle();

    // 3. TripOverviewScreen
    await tester.pumpWidget(
      const MaterialApp(home: TripOverviewScreen(tripId: 'seed-trip-1')),
    );
    await tester.pumpAndSettle();

    // 4. TripActionsSheet via modal bottom sheet
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (ctx) => Scaffold(
            body: Column(
              children: [
                ElevatedButton(
                  onPressed: () => TripActionsSheet.show(ctx),
                  child: const Text('Open Actions'),
                ),
                ElevatedButton(
                  onPressed: () => CancelTripDialog.show(ctx),
                  child: const Text('Open Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => DeleteTripDialog.show(ctx),
                  child: const Text('Open Delete'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open Actions'));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.text('Trip Actions'))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Cancel'));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.text('Cancel Trip').first)).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Delete'));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.text('Delete Trip').first)).pop();
    await tester.pumpAndSettle();
  });
}
