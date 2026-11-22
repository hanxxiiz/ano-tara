import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anotara/features/itinerary/data/ai_itinerary_service.dart';
import 'package:anotara/features/itinerary/presentation/screens/ai_itinerary_flow_screen.dart';
import 'package:anotara/features/itinerary/presentation/widgets/generate_with_ai_sheet.dart';
import 'package:anotara/features/trips/data/trip_repository.dart';

/// Answers each request with the next queued outcome (a list or an error).
class _FakeService implements AiItineraryService {
  final List<Object> outcomes;
  int calls = 0;
  _FakeService(this.outcomes);

  @override
  Future<List<AiItinerarySuggestion>> generate(AiItineraryRequest r) async {
    final outcome = outcomes[calls++];
    if (outcome is AiItineraryException) throw outcome;
    return outcome as List<AiItinerarySuggestion>;
  }
}

AiItinerarySuggestion _s(String id, String title, {int day = 1}) =>
    AiItinerarySuggestion(
      id: id,
      dayNumber: day,
      category: 'Food',
      title: title,
      location: 'Santa Fe, Bantayan',
      startTime: '9:00 AM',
      endTime: '10:00 AM',
    );

const _request = AiItineraryRequest(
  destination: 'Bantayan',
  dayCount: 3,
  selectedDay: 1,
  scope: AiPlanScope.thisDay,
);

void main() {
  Future<void> pumpFlow(
    WidgetTester tester, {
    required AiItineraryService service,
    required List<List<ItineraryItemModel>> saved,
  }) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      home: AiItineraryFlowScreen(
        request: _request,
        service: service,
        stepInterval: const Duration(milliseconds: 10),
        saveItems: (items) async {
          saved.add(items);
          return items;
        },
      ),
    ));
    // Let the generation resolve and the 400ms completion pause elapse.
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
  }

  testWidgets('failure shows a clear message and Try Again retries',
      (tester) async {
    final service = _FakeService([
      const AiItineraryException('The AI is unavailable right now.'),
      [_s('a', 'Eat at Jollibee')],
    ]);
    await pumpFlow(tester, service: service, saved: []);

    expect(find.text('We couldn\'t create your itinerary'), findsOneWidget);
    expect(find.text('The AI is unavailable right now.'), findsOneWidget);

    await tester.tap(find.text('Try Again'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(service.calls, 2);
    expect(find.text('Eat at Jollibee'), findsOneWidget);
  });

  testWidgets('removed suggestions are not saved', (tester) async {
    final saved = <List<ItineraryItemModel>>[];
    await pumpFlow(
      tester,
      service: _FakeService([
        [_s('a', 'Eat at Jollibee'), _s('b', 'Island hopping')],
      ]),
      saved: saved,
    );

    await tester.tap(find.byKey(const ValueKey('remove-b')));
    await tester.pumpAndSettle();
    expect(find.text('Island hopping'), findsNothing);

    // Let the "Removed … / Undo" snackbar expire so it can't cover Save.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(saved, hasLength(1));
    expect(saved.single.map((i) => i.title), ['Eat at Jollibee']);
    expect(find.text('AI Suggestions Added'), findsOneWidget);
  });

  testWidgets('sheet shows the existing-entries notice only when relevant',
      (tester) async {
    Future<void> openSheet(List<ItineraryItemModel> existing) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GenerateWithAiSheet(
            selectedDay: 2,
            dayCount: 3,
            existingItems: existing,
          ),
        ),
      ));
      await tester.pumpAndSettle();
    }

    await openSheet(const []);
    expect(find.text('Existing Entries Detected'), findsNothing);

    await openSheet([
      _s('x', 'Check-in', day: 1).toItineraryItem(),
    ]);
    // Day 2 has nothing, so "This Day" shows no notice…
    expect(find.text('Existing Entries Detected'), findsNothing);
    // …but the whole trip does.
    await tester.tap(find.text('Whole Trip'));
    await tester.pumpAndSettle();
    expect(find.text('Existing Entries Detected'), findsOneWidget);
  });
}
