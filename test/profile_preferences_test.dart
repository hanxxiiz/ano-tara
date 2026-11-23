import 'package:anotara/app_routes.dart';
import 'package:anotara/features/profile/data/profile_repository.dart';
import 'package:anotara/features/profile/presentation/screens/preference_detail_screens.dart';
import 'package:anotara/features/profile/presentation/screens/preference_screens.dart';
import 'package:anotara/features/profile/presentation/screens/profile_screen.dart';
import 'package:anotara/features/profile/presentation/screens/subscription_screen.dart';
import 'package:anotara/features/profile/presentation/widgets/preference_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  late ProfileRepository repo;

  setUp(() => repo = ProfileRepository());

  Future<void> pumpApp(WidgetTester tester, Widget home) async {
    tester.view.physicalSize = const Size(375, 1300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: home,
        routes: {AppRoutes.subscription: (_) => const SubscriptionScreen()},
      ),
    );
    // Let google_fonts finish loading bundled fonts before settling.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('Profile shows header, stats, plan and preferences', (
    tester,
  ) async {
    await pumpApp(tester, ProfileScreen(repository: repo));

    expect(find.text('Lucy Hayden Halilia'), findsOneWidget);
    expect(find.text('@lucyheartfilia_123'), findsOneWidget);
    expect(find.text('276'), findsOneWidget);
    expect(find.text('Active Trips'), findsOneWidget);
    expect(find.text('Plus Plan'), findsOneWidget);
    expect(find.text('Expires: Jan 12, 2027'), findsOneWidget);
    for (final title in [
      'Preferred Activities',
      'Dietary Preferences',
      'Allergies',
      'Budget Preference',
      'Travel Pace',
      'Additional Notes',
    ]) {
      expect(find.text(title), findsOneWidget);
    }
    expect(find.text('Sightseeing, Hiking'), findsOneWidget);
    expect(find.text('₱5,000'), findsOneWidget);
    expect(find.text('Relaxed'), findsOneWidget);
  });

  testWidgets('Manage Subscription opens the subscription screen', (
    tester,
  ) async {
    await pumpApp(tester, ProfileScreen(repository: repo));
    await tapAndSettle(
      tester,
      find.byKey(const ValueKey('manage-subscription')),
    );
    expect(find.byType(SubscriptionScreen), findsOneWidget);
    expect(find.text('Manage Subscription'), findsOneWidget);
  });

  testWidgets('Edit activities, save, and the view + profile update', (
    tester,
  ) async {
    await pumpApp(tester, ProfileScreen(repository: repo));
    await tapAndSettle(
      tester,
      find.byKey(const ValueKey('profile-pref-Preferred Activities')),
    );
    expect(find.byType(PreferenceViewScreen), findsOneWidget);
    expect(find.text('Please specify...'), findsOneWidget);

    await tapAndSettle(tester, find.byKey(const ValueKey('pref-edit')));
    expect(find.text('Edit Preferred Activities'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tapAndSettle(tester, find.byKey(const ValueKey('pref-tile-Beaches')));
    await tapAndSettle(tester, find.byKey(const ValueKey('pref-tile-Hiking')));
    await tapAndSettle(tester, find.byKey(const ValueKey('pref-save')));

    expect(repo.preferences.value.activities, ['Beaches', 'Sightseeing']);
    expect(find.byType(PreferenceViewScreen), findsOneWidget);
    final beaches = tester.widget<Semantics>(
      find
          .ancestor(
            of: find.text('Beaches'),
            matching: find.byWidgetPredicate(
              (w) => w is Semantics && w.properties.label == 'Beaches',
            ),
          )
          .first,
    );
    expect(beaches.properties.selected, isTrue);

    await tester.tap(find.byIcon(Iconsax.arrow_left));
    await tester.pumpAndSettle();
    expect(find.text('Beaches, Sightseeing'), findsOneWidget);
  });

  testWidgets('Cancel discards edits', (tester) async {
    await pumpApp(
      tester,
      PreferenceViewScreen(
        category: PreferenceCategory.dietary,
        repository: repo,
      ),
    );
    await tapAndSettle(tester, find.byKey(const ValueKey('pref-edit')));
    expect(find.text('Edit Dietary Preference'), findsOneWidget);
    await tapAndSettle(tester, find.byKey(const ValueKey('pref-tile-Keto')));
    await tapAndSettle(tester, find.byKey(const ValueKey('pref-cancel')));

    expect(repo.preferences.value.dietaryPreferences, [
      'Gluten-free',
      'Vegetarian',
    ]);
    expect(find.byType(PreferenceEditScreen), findsNothing);
  });

  testWidgets('Budget row opens view, edit changes the amount', (tester) async {
    await pumpApp(tester, ProfileScreen(repository: repo));
    await tapAndSettle(
      tester,
      find.byKey(const ValueKey('profile-pref-Budget Preference')),
    );
    expect(find.byType(PreferenceDetailViewScreen), findsOneWidget);
    expect(find.text('₱5,000'), findsOneWidget);

    await tapAndSettle(tester, find.byKey(const ValueKey('pref-edit')));
    expect(find.text('Edit Budget Preference'), findsOneWidget);
    await tapAndSettle(tester, find.byKey(const ValueKey('budget-stop-1000')));
    expect(find.text('₱1,000'), findsOneWidget);
    await tapAndSettle(tester, find.byKey(const ValueKey('pref-save')));

    expect(repo.preferences.value.budget, 1000);
    expect(find.byType(PreferenceDetailViewScreen), findsOneWidget);
    expect(find.text('₱1,000'), findsOneWidget);
  });

  testWidgets('Travel pace cancel keeps the old pace', (tester) async {
    await pumpApp(
      tester,
      PreferenceDetailEditScreen(
        detail: PreferenceDetail.pace,
        repository: repo,
      ),
    );
    expect(find.text('Edit Travel Pace'), findsOneWidget);
    await tapAndSettle(tester, find.byKey(const ValueKey('pace-packed')));
    await tapAndSettle(tester, find.byKey(const ValueKey('pref-cancel')));
    expect(repo.preferences.value.travelPace, 'relaxed');
  });

  testWidgets('Travel pace save stores the new pace', (tester) async {
    await pumpApp(
      tester,
      PreferenceDetailEditScreen(
        detail: PreferenceDetail.pace,
        repository: repo,
      ),
    );
    await tapAndSettle(tester, find.byKey(const ValueKey('pace-packed')));
    await tapAndSettle(tester, find.byKey(const ValueKey('pref-save')));
    expect(repo.preferences.value.travelPace, 'packed');
  });

  testWidgets('Notes edit saves trimmed text', (tester) async {
    await pumpApp(
      tester,
      PreferenceDetailEditScreen(
        detail: PreferenceDetail.notes,
        repository: repo,
      ),
    );
    expect(find.text('Edit Additional Notes'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('pref-notes')),
      '  Window seats please  ',
    );
    await tapAndSettle(tester, find.byKey(const ValueKey('pref-save')));
    expect(repo.preferences.value.notes, 'Window seats please');
  });

  testWidgets('Allergies "Others" saves the specified text', (tester) async {
    await pumpApp(
      tester,
      PreferenceEditScreen(
        category: PreferenceCategory.allergies,
        repository: repo,
      ),
    );
    await tapAndSettle(tester, find.byKey(const ValueKey('pref-tile-Others')));
    await tester.enterText(find.byKey(const ValueKey('pref-specify')), 'Mango');
    await tapAndSettle(tester, find.byKey(const ValueKey('pref-save')));

    expect(repo.preferences.value.allergies, [
      'Dairy',
      'Gluten',
      'Eggs',
      'Sesame',
      'Mango',
    ]);
    expect(
      PreferenceCategory.allergies.selectedLabels(repo.preferences.value),
      contains(preferenceOthersLabel),
    );
    expect(
      PreferenceCategory.allergies.otherText(repo.preferences.value),
      'Mango',
    );
  });
}
