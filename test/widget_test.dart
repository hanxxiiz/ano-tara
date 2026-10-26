import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anotara/main.dart';

void main() {
  testWidgets('Start screen leads to log in', (WidgetTester tester) async {
    await tester.pumpWidget(const AnoTaraApp());

    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);

    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('Forgot password flow reaches verification', (WidgetTester tester) async {
    await tester.pumpWidget(const AnoTaraApp());
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    expect(find.text('Forgot Password'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'me@example.com');
    await tester.tap(find.text('Send Code'));
    await tester.pumpAndSettle();

    expect(find.text('Verification Code'), findsOneWidget);
  });
}
