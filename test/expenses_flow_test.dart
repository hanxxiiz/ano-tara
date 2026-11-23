import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anotara/app_routes.dart';
import 'package:anotara/components/atoms/app_button.dart';
import 'package:anotara/components/organisms/app_bottom_navigation.dart';
import 'package:anotara/models/expense_models.dart';
import 'package:anotara/screens/expenses/expense_details_screen.dart';
import 'package:anotara/screens/expenses/expense_form_screen.dart';
import 'package:anotara/screens/expenses/view_expenses_screen.dart';

void main() {
  setUp(() {
    ExpensesStore.instance.reset();
  });

  Widget wrapWithApp(Widget child) {
    return MaterialApp(
      home: child,
      routes: {
        AppRoutes.expenses: (_) => const ViewExpensesScreen(),
      },
    );
  }

  test('computeEqualSplit divides amount evenly and sums to exact total', () {
    final even = computeEqualSplit(600.0, ['a', 'b', 'c', 'd', 'e']);
    expect(even.values.every((v) => v == 120.0), isTrue);

    final withRemainder = computeEqualSplit(100.0, ['a', 'b', 'c']);
    final sum = withRemainder.values.fold(0.0, (a, b) => a + b);
    expect(sum, closeTo(100.0, 0.001));
    expect(withRemainder['a'], 33.34);
    expect(withRemainder['b'], 33.33);
    expect(withRemainder['c'], 33.33);
  });

  testWidgets('View Expenses shows empty state on Day 1 and entries on Day 2',
      (tester) async {
    await tester.pumpWidget(wrapWithApp(const ViewExpensesScreen()));

    expect(find.text('View Expenses'), findsOneWidget);
    expect(find.text('Day 1 of 3'), findsOneWidget);
    expect(find.text('No expenses yet'), findsOneWidget);

    // Bottom nav stays on Trips (index 1)
    final nav = tester.widget<AppBottomNavigation>(
      find.byType(AppBottomNavigation),
    );
    expect(nav.currentIndex, 1);

    // Navigate to Day 2
    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Day 2 of 3'), findsOneWidget);
    expect(find.text('Balut'), findsOneWidget);
    expect(find.text('Seafood Dinner'), findsOneWidget);
  });

  testWidgets('Select mode & Delete Expense confirmation removes selected item',
      (tester) async {
    await tester.pumpWidget(
      wrapWithApp(const ViewExpensesScreen(initialDayIndex: 1)),
    );

    // Enter select mode
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();
    expect(find.text('0 selected'), findsOneWidget);

    // Select Balut
    await tester.tap(find.text('Balut'));
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsOneWidget);
    expect(find.text('Delete (1)'), findsOneWidget);

    // Tap Delete (1) -> singular dialog
    await tester.tap(find.text('Delete (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Delete Expense'), findsOneWidget);
    expect(
      find.textContaining('Balut will be permanently removed'),
      findsOneWidget,
    );

    // Confirm Delete
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Balut'), findsNothing);
  });

  testWidgets('Custom split cannot be saved unless Remaining is ₱0.00',
      (tester) async {
    await tester.pumpWidget(
      wrapWithApp(
        const ExpenseFormScreen(
          dayIndex: 0,
          category: ExpenseCategory.food,
        ),
      ),
    );

    // Verify bottom nav stays on Trips
    final nav = tester.widget<AppBottomNavigation>(
      find.byType(AppBottomNavigation),
    );
    expect(nav.currentIndex, 1);

    await tester.enterText(
      find.byKey(const Key('expense_title_field')),
      'Bantayan Snacks',
    );
    await tester.enterText(
      find.byKey(const Key('expense_amount_field')),
      '500',
    );
    await tester.pumpAndSettle();

    // Equal split should show ₱100.00 for each of the 5 members
    expect(find.text('₱100.00'), findsNWidgets(5));

    // Switch to Custom Split (pre-fills 100.00 each -> Remaining ₱0.00)
    await tester.ensureVisible(find.byKey(const Key('custom_split_tab')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('custom_split_tab')));
    await tester.pumpAndSettle();

    AppButton saveBtn = tester.widget<AppButton>(
      find.byKey(const Key('expense_save_button')),
    );
    expect(saveBtn.isDisabled, isFalse);

    // Change Olivia's custom split to 50 -> Remaining becomes ₱50.00 -> disabled!
    await tester.ensureVisible(
      find.byKey(const Key('custom_split_input_m_olivia')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('custom_split_input_m_olivia')),
      '50',
    );
    await tester.pumpAndSettle();

    expect(find.text('₱50.00'), findsOneWidget);
    saveBtn = tester.widget<AppButton>(
      find.byKey(const Key('expense_save_button')),
    );
    expect(saveBtn.isDisabled, isTrue);

    // Restore Olivia's split to 100 -> Remaining ₱0.00 -> enabled!
    await tester.enterText(
      find.byKey(const Key('custom_split_input_m_olivia')),
      '100',
    );
    await tester.pumpAndSettle();

    saveBtn = tester.widget<AppButton>(
      find.byKey(const Key('expense_save_button')),
    );
    expect(saveBtn.isDisabled, isFalse);
  });

  testWidgets('Expense Details marks member settled via dialog',
      (tester) async {
    await tester.pumpWidget(
      wrapWithApp(const ExpenseDetailsScreen(expenseId: 'exp_1')),
    );

    expect(find.text('View Expense Details'), findsOneWidget);
    expect(find.text('1 of 4 settled'), findsOneWidget);

    // Bottom nav stays on Trips
    final nav = tester.widget<AppBottomNavigation>(
      find.byType(AppBottomNavigation),
    );
    expect(nav.currentIndex, 1);

    // Tap Mark as Settled for Olivia
    await tester.tap(find.byKey(const Key('mark_settled_m_olivia')));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Confirm that Olivia has paid'),
      findsOneWidget,
    );

    // Confirm in dialog
    await tester.tap(find.text('Mark as Settled').last);
    await tester.pumpAndSettle();

    expect(find.text('2 of 4 settled'), findsOneWidget);
  });
}
