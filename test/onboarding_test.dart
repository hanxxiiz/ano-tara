import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anotara/app_routes.dart';
import 'package:anotara/models/member_preferences.dart';
import 'package:anotara/screens/onboarding/onboarding_flow.dart';
import 'package:anotara/services/preferences_service.dart';

class _FakeService extends PreferencesService {
  MemberPreferences? saved;
  MemberPreferences? stored;

  @override
  Future<MemberPreferences?> load() async => stored;

  @override
  Future<void> save(MemberPreferences preferences) async => saved = preferences;
}

Widget _app(Widget home) => MaterialApp(
      home: home,
      routes: {AppRoutes.home: (_) => const Scaffold(body: Text('HOME'))},
    );

Future<void> _tapNext(WidgetTester tester) async {
  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Full onboarding saves answers and lands on Home', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final service = _FakeService();
    await tester.pumpWidget(_app(OnboardingFlow(service: service)));

    expect(find.text('1/7'), findsOneWidget);

    // Step 1 needs a choice before moving on.
    await _tapNext(tester);
    expect(find.text('1/7'), findsOneWidget);

    await tester.tap(find.text('Hiking'));
    await tester.tap(find.text('Others'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Surfing');
    await _tapNext(tester);

    expect(find.text('2/7'), findsOneWidget);
    await tester.tap(find.text('Vegan'));
    await _tapNext(tester);

    // Back arrow returns to the previous step with answers kept.
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('2/7'), findsOneWidget);
    await _tapNext(tester);

    expect(find.text('3/7'), findsOneWidget);
    await _tapNext(tester);

    expect(find.text('4/7'), findsOneWidget);
    await tester.tap(find.text('5,000'));
    await tester.pumpAndSettle();
    expect(find.text('₱5,000'), findsOneWidget);
    await _tapNext(tester);

    expect(find.text('5/7'), findsOneWidget);
    await tester.tap(find.text('Balanced'));
    await _tapNext(tester);

    expect(find.text('6/7'), findsOneWidget);
    await tester.tap(find.text('Saturday'));
    await tester.tap(find.text('Sunday'));
    await _tapNext(tester);

    expect(find.text('7/7'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'No early flights');
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    final saved = service.saved!;
    expect(saved.activities, ['Hiking', 'Surfing']);
    expect(saved.dietaryPreferences, ['Vegan']);
    expect(saved.allergies, isEmpty);
    expect(saved.budget, 5000);
    expect(saved.travelPace, 'balanced');
    expect(saved.availableDays, ['Saturday', 'Sunday']);
    expect(saved.notes, 'No early flights');
  });

  testWidgets('Edit mode loads saved answers', (tester) async {
    final service = _FakeService()
      ..stored = const MemberPreferences(activities: ['Museums', 'Surfing']);
    await tester.pumpWidget(_app(OnboardingFlow(editing: true, service: service)));
    await tester.pumpAndSettle();

    final surfing = tester.widget<TextField>(find.byType(TextField));
    expect(surfing.controller!.text, 'Surfing');
  });
}
