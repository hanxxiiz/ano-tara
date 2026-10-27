import 'package:flutter_test/flutter_test.dart';
import 'package:anotara/main.dart';

void main() {
  testWidgets('AnoTara app smoke test and landing buttons verification', (WidgetTester tester) async {
    await tester.pumpWidget(const AnoTaraApp());

    // Verify initial landing screen buttons render
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });
}
