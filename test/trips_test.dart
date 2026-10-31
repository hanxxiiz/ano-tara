import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anotara/models/expense.dart';
import 'package:anotara/models/trip.dart';
import 'package:anotara/screens/trips/trips_screen.dart';
import 'package:anotara/services/expenses_service.dart';
import 'package:anotara/services/trips_repository.dart';
import 'package:anotara/widgets/trip_widgets.dart';

Future<void> _pumpTrips(WidgetTester tester) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  // Start from a fresh navigator each time.
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(
    MaterialApp(home: TripsScreen(repository: TripsRepository.instance)),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('search narrows the trips list', (tester) async {
    await _pumpTrips(tester);
    expect(find.text('Trip to Bantayan'), findsOneWidget);
    expect(find.text('Baguio Getaway'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'baguio');
    await tester.pumpAndSettle();
    expect(find.text('Trip to Bantayan'), findsNothing);
    expect(find.text('Baguio Getaway'), findsOneWidget);
  });

  testWidgets('filter by status', (tester) async {
    await _pumpTrips(tester);
    await tester.tap(find.byTooltip('Filter trips'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Past'));
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(find.text('Siargao Surf Week'), findsOneWidget);
    expect(find.text('Trip to Bantayan'), findsNothing);
  });

  testWidgets('overview shows shortcuts, happening now and opens itinerary', (
    tester,
  ) async {
    await _pumpTrips(tester);
    await tester.tap(find.text('Trip to Bantayan'));
    await tester.pumpAndSettle();

    for (final label in ['Itinerary', 'Expenses', 'Members', 'Map']) {
      expect(find.text(label), findsOneWidget);
    }
    await tester.scrollUntilVisible(find.text('Up Next'), 200);
    expect(find.text('Island Hopping'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Itinerary'), -200);
    await tester.tap(find.text('Itinerary'));
    await tester.pumpAndSettle();
    expect(find.text('View Itinerary'), findsOneWidget);
    expect(find.text('Island Hopping'), findsOneWidget);
  });

  testWidgets('plan a trip asks for a group first', (tester) async {
    await _pumpTrips(tester);
    await tester.tap(find.bySemanticsLabel('Plan a trip'));
    await tester.pumpAndSettle();

    expect(
      find.text('Which group are you planning this trip with?'),
      findsOneWidget,
    );
    await tester.tap(find.text('Family'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Plan a Trip'), findsOneWidget);
    expect(find.text('With Family (4 members)'), findsOneWidget);
  });

  expenseTests();
  mapAndRoleTests();
  wideScreenTests();
  detailsTests();
  renameTests();
}

final _formScroll = find.byWidgetPredicate(
  (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
);
final _addExpenseButton = find.widgetWithText(PrimaryButton, 'Add Expense');

Future<void> _openExpenses(WidgetTester tester) async {
  await _pumpTrips(tester);
  await tester.tap(find.text('Trip to Bantayan'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Expenses'));
  await tester.pumpAndSettle();
}

Future<void> _startAddExpense(WidgetTester tester, String category) async {
  await tester.tap(find.text('Add'));
  await tester.pumpAndSettle();
  expect(
    find.text('Which category does this expense belong to?'),
    findsOneWidget,
  );
  await tester.tap(find.text(category));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
  expect(find.text('Expense Details'), findsOneWidget);
}

class _FakeExpensesService extends ExpensesService {
  final saved = <Expense>[];

  @override
  Future<String> insert(Trip trip, Expense expense) async {
    saved.add(expense);
    return 'remote-1';
  }
}

void expenseTests() {
  test('equal split hands out leftover centavos so shares add up', () {
    final shares = splitEqually(100000, ['a', 'b', 'c']);
    expect(shares, {'a': 33334, 'b': 33333, 'c': 33333});
    expect(shares.values.reduce((x, y) => x + y), 100000);
    expect(parsePesoCents('1,250.50'), 125050);
    expect(formatPeso(250000), '₱2,500.00');
  });

  testWidgets('view expenses lists the day\'s expenses with payer', (
    tester,
  ) async {
    await _openExpenses(tester);
    expect(find.text('View Expenses'), findsOneWidget);
    expect(find.text('Breakfast at Jollibee'), findsOneWidget);
    expect(find.text('Paid by: Hannah'), findsOneWidget);
    expect(find.text('₱600.00'), findsOneWidget);
  });

  testWidgets('add an equally split expense, then view expenses', (
    tester,
  ) async {
    await _openExpenses(tester);
    await _startAddExpense(tester, 'Food');

    await tester.enterText(find.byType(TextFormField).at(0), 'Lechon');
    await tester.enterText(find.byType(TextFormField).at(1), '3000');
    await tester.pumpAndSettle();
    expect(find.text('₱500.00'), findsNWidgets(6));

    await tester.scrollUntilVisible(
      _addExpenseButton,
      200,
      scrollable: _formScroll,
    );
    await tester.pumpAndSettle();
    await tester.tap(_addExpenseButton);
    await tester.pumpAndSettle();
    expect(find.text('Expense Added!'), findsOneWidget);

    await tester.tap(find.text('View Expenses'));
    await tester.pumpAndSettle();
    expect(find.text('Lechon'), findsOneWidget);
  });

  testWidgets('custom split must assign the whole amount', (tester) async {
    await _openExpenses(tester);
    await _startAddExpense(tester, 'Shopping');

    await tester.enterText(find.byType(TextFormField).at(0), 'Pasalubong');
    await tester.enterText(find.byType(TextFormField).at(1), '1000');
    await tester.tap(find.text('Custom Split'));
    await tester.pumpAndSettle();
    expect(find.text('Assigned'), findsOneWidget);
    expect(find.text('₱1,000.00'), findsOneWidget); // remaining

    await tester.scrollUntilVisible(
      find.text('Set each amount'),
      200,
      scrollable: _formScroll,
    );
    await tester.pumpAndSettle();
    final inputs = find.byType(TextField);
    // Fields after title and amount are per-person amounts.
    await tester.enterText(inputs.at(2), '600');
    await tester.pumpAndSettle();
    expect(find.text('₱400.00'), findsOneWidget);

    await tester.scrollUntilVisible(
      _addExpenseButton,
      200,
      scrollable: _formScroll,
    );
    await tester.pumpAndSettle();
    await tester.tap(_addExpenseButton);
    await tester.pumpAndSettle();
    expect(find.text('₱400.00 still needs to be assigned.'), findsOneWidget);
    expect(find.text('Expense Added!'), findsNothing);

    await tester.ensureVisible(inputs.at(3));
    await tester.enterText(inputs.at(3), '400');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      _addExpenseButton,
      200,
      scrollable: _formScroll,
    );
    await tester.pumpAndSettle();
    await tester.tap(_addExpenseButton);
    await tester.pumpAndSettle();
    expect(find.text('Expense Added!'), findsOneWidget);
  });

  test('trips stored in Supabase save through the expenses service', () async {
    final repo = TripsRepository.instance;
    final original = repo.expensesService;
    final fake = _FakeExpensesService();
    repo.expensesService = fake;
    addTearDown(() => repo.expensesService = original);

    final local = repo.trips.first;
    final remoteTrip = Trip(
      id: 'x',
      remoteId: 'trip-uuid',
      title: 't',
      destination: 'd',
      group: local.group,
      startDate: local.startDate,
      endDate: local.endDate,
      description: '',
      isOrganizer: true,
    );
    final online = await repo.addExpense(
      remoteTrip,
      title: 'Van',
      category: ExpenseCategory.transport,
      amountCents: 90000,
      paidById: 'm1',
      splitMethod: SplitMethod.equal,
      sharesCents: splitEqually(90000, ['m1', 'm2']),
      occurredAt: DateTime.now(),
    );
    expect(online, isTrue);
    expect(fake.saved.single.sharesCents, {'m1': 45000, 'm2': 45000});
    expect(remoteTrip.expenses.single.id, 'remote-1');

    final offline = await repo.addExpense(
      local,
      title: 'Snacks',
      category: ExpenseCategory.food,
      amountCents: 1000,
      paidById: 'm1',
      splitMethod: SplitMethod.equal,
      sharesCents: const {'m1': 1000},
      occurredAt: DateTime.now(),
    );
    expect(offline, isFalse);
    expect(fake.saved, hasLength(1));
  });
}

Future<void> _openTrip(WidgetTester tester, String title) async {
  await _pumpTrips(tester);
  // Search so the card is at the top, clear of the bottom bar.
  await tester.enterText(find.byType(TextField), title);
  await tester.pumpAndSettle();
  // The search field also shows the title; the card is the last match.
  await tester.tap(find.text(title).last);
  await tester.pumpAndSettle();
}

void mapAndRoleTests() {
  testWidgets('map shows sharing members, meeting point and organizer edit', (
    tester,
  ) async {
    await _openTrip(tester, 'Trip to Bantayan');
    expect(find.byTooltip('Rename trip'), findsOneWidget);
    await tester.tap(find.text('Map'));
    await tester.pumpAndSettle();

    expect(find.text('View Map'), findsOneWidget);
    expect(find.text('3 members sharing their location'), findsOneWidget);
    expect(find.text('Meeting point: Santa Fe Pier'), findsOneWidget);
    for (final name in ['You', 'Hannah', 'Louielyn', 'Meeting point']) {
      expect(find.text(name), findsWidgets);
    }

    await tester.tap(find.byTooltip('Edit meeting point'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Kota Beach');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Meeting point: Kota Beach'), findsOneWidget);
  });

  testWidgets('every organized trip can be renamed and has a map', (
    tester,
  ) async {
    for (final title in ['Baguio Getaway', 'Siargao Surf Week']) {
      await _openTrip(tester, title);
      expect(find.byTooltip('Rename trip'), findsOneWidget);
      expect(find.text("You're the organizer"), findsOneWidget);
      await tester.tap(find.text('Map'));
      await tester.pumpAndSettle();
      expect(find.textContaining('sharing their location'), findsOneWidget);
      expect(find.byTooltip('Edit meeting point'), findsOneWidget);
    }
  });

  testWidgets('members see no edit controls', (tester) async {
    await _openTrip(tester, 'Cebu Food Crawl');
    expect(find.byTooltip('Rename trip'), findsNothing);
    expect(find.text('Member · Organized by Hannah'), findsOneWidget);
    await tester.tap(find.text('Members'));
    await tester.pumpAndSettle();
    expect(find.text('Organizer'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Map'));
    await tester.pumpAndSettle();

    expect(find.text('2 members sharing their location'), findsOneWidget);
    expect(find.text('Meeting point: Larsian BBQ'), findsOneWidget);
    expect(find.byTooltip('Set meeting point'), findsNothing);
    expect(find.byTooltip('Edit meeting point'), findsNothing);
  });
}

void wideScreenTests() {
  testWidgets('category grid fits on a wide browser window', (tester) async {
    tester.view.physicalSize = const Size(1880, 880);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(home: TripsScreen(repository: TripsRepository.instance)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trip to Bantayan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Expenses'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Continue'), findsOneWidget);
  });
}

void renameTests() {
  testWidgets('pencil renames the trip everywhere', (tester) async {
    await _openTrip(tester, 'Trip to Bantayan');
    await tester.tap(find.byTooltip('Rename trip'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Bantayan Weekend');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Bantayan Weekend'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    // Clear the search used to open the trip.
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    expect(find.text('Bantayan Weekend'), findsOneWidget);
    expect(find.text('Trip to Bantayan'), findsNothing);
  });
}

void detailsTests() {
  testWidgets('activity card opens details; organizer can edit and delete', (
    tester,
  ) async {
    await _openTrip(tester, 'Trip to Bantayan');
    await tester.tap(find.text('Itinerary'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Island Hopping'));
    await tester.pumpAndSettle();
    expect(find.text('Edit'), findsOneWidget);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit activity'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).first,
      'Sunset Island Hopping',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Sunset Island Hopping'), findsOneWidget);

    await tester.tap(find.text('Sunset Island Hopping'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete activity?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Sunset Island Hopping'), findsNothing);
  });

  testWidgets('members can view activity details but not change them', (
    tester,
  ) async {
    await _openTrip(tester, 'Cebu Food Crawl');
    await tester.tap(find.text('Itinerary'));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Lechon lunch at Rico's"));
    await tester.pumpAndSettle();
    expect(find.text('Mabolo, Cebu City'), findsWidgets);
    expect(find.text('Edit'), findsNothing);
    expect(
      find.text('Only the organizer can change the itinerary.'),
      findsOneWidget,
    );
  });

  testWidgets('expense card shows split, can be renamed and deleted', (
    tester,
  ) async {
    await _openExpenses(tester);
    await tester.tap(find.text('Breakfast at Jollibee'));
    await tester.pumpAndSettle();
    expect(find.text('Split'), findsOneWidget);
    expect(find.text('₱200.00'), findsNWidgets(3));

    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Jollibee breakfast');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Jollibee breakfast'), findsOneWidget);

    await tester.tap(find.text('Jollibee breakfast'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Jollibee breakfast'), findsNothing);
  });
}
