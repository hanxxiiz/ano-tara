import 'package:anotara/components/atoms/app_switch.dart';
import 'package:anotara/features/trips/domain/trip_view_models.dart';
import 'package:anotara/features/trips/presentation/screens/trip_edit_expense_screen.dart';
import 'package:anotara/features/trips/presentation/screens/trip_expense_settlements_screen.dart';
import 'package:anotara/features/trips/presentation/screens/trip_itinerary_readonly_screen.dart';
import 'package:anotara/features/trips/presentation/screens/trip_map_screen.dart';
import 'package:anotara/features/trips/presentation/screens/trip_members_screen.dart';
import 'package:anotara/features/trips/presentation/screens/trip_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax/iconsax.dart';

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

  testWidgets(
      'Completed Trip Overview has delete icon, defaults View Itinerary to Day 1, and opens Members',
      (tester) async {
    final completed = TripDetailData.completedSample();

    await tester.pumpWidget(
      MaterialApp(
        home: TripOverviewScreen(trip: completed),
      ),
    );

    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Bantayan Trip'), findsOneWidget);
    expect(find.byKey(const Key('delete_trip_button')), findsOneWidget);

    // Navigate to View Itinerary and verify Day 1 is displayed by default
    await tester.tap(find.text('Itinerary'));
    await tester.pumpAndSettle();

    expect(find.byType(TripItineraryReadOnlyScreen), findsOneWidget);
    expect(find.text('Day 1 of 3'), findsOneWidget);

    // Return to Overview and navigate to Members
    await tester.tap(find.byIcon(Iconsax.arrow_left));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Members'));
    await tester.pumpAndSettle();

    expect(find.byType(TripMembersScreen), findsOneWidget);
    expect(find.text('members responded'), findsOneWidget);
  });

  testWidgets(
      'Cancelled Trip Overview has delete icon, edit icon on cancelled card, Day 1 itinerary, and Members label',
      (tester) async {
    final cancelled = TripDetailData.cancelledSample();

    await tester.pumpWidget(
      MaterialApp(
        home: TripOverviewScreen(trip: cancelled),
      ),
    );

    expect(find.text('Cancelled'), findsOneWidget);
    expect(find.text('This trip is off'), findsOneWidget);
    expect(find.byKey(const Key('delete_trip_button')), findsOneWidget);
    expect(
      find.byKey(const Key('edit_cancelled_announcement_button')),
      findsOneWidget,
    );

    // Tap edit icon on cancelled card and verify Edit Cancellation Reason modal
    await tester.ensureVisible(
      find.byKey(const Key('edit_cancelled_announcement_button')),
    );
    await tester.tap(
      find.byKey(const Key('edit_cancelled_announcement_button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Cancellation Reason'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Navigate to View Itinerary and verify Day 1 is displayed by default
    await tester.ensureVisible(find.text('Itinerary'));
    await tester.tap(find.text('Itinerary'));
    await tester.pumpAndSettle();

    expect(find.byType(TripItineraryReadOnlyScreen), findsOneWidget);
    expect(find.text('Day 1 of 3'), findsOneWidget);

    await tester.tap(find.byIcon(Iconsax.arrow_left));
    await tester.pumpAndSettle();

    // Navigate to Members
    await tester.tap(find.text('Members'));
    await tester.pumpAndSettle();

    expect(find.byType(TripMembersScreen), findsOneWidget);
    expect(
      find.text('members responded before trip was cancelled'),
      findsOneWidget,
    );
  });

  testWidgets(
      'Member Settlements shows only Settled / Mark as Settled, confirms via modal, locks Settled, and opens Edit Expense screens',
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
    expect(find.text('Member settlements'), findsOneWidget);

    // No "Paid" status should exist; only "Settled" and "Mark as Settled"
    expect(find.text('Paid'), findsNothing);
    expect(find.text('Settled'), findsNWidgets(2)); // Lizzie + Hannah
    expect(find.text('Mark as Settled'), findsNWidgets(3)); // Olivia, Elle, Izzie

    // Tapping an already-Settled pill does nothing
    await tester.tap(find.text('Settled').first);
    await tester.pumpAndSettle();
    expect(find.text('Confirm Settlement'), findsNothing);
    expect(find.text('Settled'), findsNWidgets(2));

    // Tapping "Mark as Settled" opens the confirmation modal with expected values
    await tester.tap(find.text('Mark as Settled').first);
    await tester.pumpAndSettle();

    expect(
      find.text(
        "Confirm that you've received ₱120.00 from Olivia for the Balut expense.",
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'After confirmation, your remaining amount to receive will be ₱240.00.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('confirm_settlement_button')), findsOneWidget);

    // Confirm settlement
    await tester.tap(find.byKey(const Key('confirm_settlement_button')));
    await tester.pumpAndSettle();

    expect(find.text('Settled'), findsNWidgets(3));
    expect(find.text('Mark as Settled'), findsNWidgets(2));
    expect(find.text('₱240.00'), findsOneWidget);

    // Edit Expense button is present and navigates to Edit Expense & Edit Split screens
    await tester.scrollUntilVisible(
      find.byKey(const Key('edit_expense_button')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('edit_expense_button')));
    await tester.pumpAndSettle();

    expect(find.byType(TripEditExpenseScreen), findsOneWidget);
    expect(find.text('Edit Expense'), findsOneWidget);

    // Open Edit Split screen
    await tester.scrollUntilVisible(
      find.byKey(const Key('edit_split_button')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('edit_split_button')));
    await tester.pumpAndSettle();

    expect(find.byType(TripEditExpenseSplitScreen), findsOneWidget);
    expect(find.text('Edit Split'), findsOneWidget);
  });
}
