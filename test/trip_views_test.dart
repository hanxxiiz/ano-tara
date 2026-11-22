import 'package:anotara/components/atoms/app_switch.dart';
import 'package:anotara/features/trips/domain/trip_view_models.dart';
import 'package:anotara/features/trips/presentation/screens/trip_expense_settlements_screen.dart';
import 'package:anotara/features/trips/presentation/screens/trip_map_screen.dart';
import 'package:anotara/features/trips/presentation/screens/trip_members_screen.dart';
import 'package:anotara/features/trips/presentation/screens/trip_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Trip Map displays meeting point, markers, sharing card, and toggle',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TripMapScreen(trip: TripDetailData.activeMapSample()),
      ),
    );

    expect(find.text('Trip Map'), findsOneWidget);
    expect(find.text('Meeting Point'), findsOneWidget);
    expect(find.text('MEETING POINT'), findsOneWidget);
    expect(find.text('Share My Live Location'), findsOneWidget);
    expect(find.text('4 of 5 sharing'), findsOneWidget);

    // Toggle location sharing off
    await tester.tap(find.byType(AppSwitch));
    await tester.pumpAndSettle();

    expect(find.text('3 of 5 sharing'), findsOneWidget);
  });

  testWidgets('Completed Trip Overview & Members are read-only and match Figma',
      (tester) async {
    final completed = TripDetailData.completedSample();

    await tester.pumpWidget(
      MaterialApp(
        home: TripOverviewScreen(trip: completed),
      ),
    );

    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Bantayan Trip'), findsOneWidget);
    expect(find.text('Edit'), findsNothing);

    // Navigate to Members
    await tester.tap(find.text('Members'));
    await tester.pumpAndSettle();

    expect(find.byType(TripMembersScreen), findsOneWidget);
    expect(find.text('members responded'), findsOneWidget);
  });

  testWidgets(
      'Cancelled Trip Overview is non-editable and Members shows cancelled label',
      (tester) async {
    final cancelled = TripDetailData.cancelledSample();

    await tester.pumpWidget(
      MaterialApp(
        home: TripOverviewScreen(trip: cancelled),
      ),
    );

    expect(find.text('Cancelled'), findsOneWidget);
    expect(find.text('This trip is off'), findsOneWidget);
    expect(find.text('Edit'), findsNothing);

    // Navigate to Members
    await tester.tap(find.text('Members'));
    await tester.pumpAndSettle();

    expect(find.byType(TripMembersScreen), findsOneWidget);
    expect(
      find.text('members responded before trip was cancelled'),
      findsOneWidget,
    );
  });

  testWidgets('Expense settlements has no Edit button for Completed/Cancelled trips',
      (tester) async {
    final completed = TripDetailData.completedSample();

    await tester.pumpWidget(
      MaterialApp(
        home: TripExpenseSettlementsScreen(
          expense: completed.expenses.first,
          tripStatus: completed.status,
        ),
      ),
    );

    expect(find.text('View Expense Details'), findsOneWidget);
    expect(find.text('Edit'), findsNothing);
    expect(find.text('Member settlements'), findsOneWidget);
  });
}
