import 'package:anotara/features/profile/presentation/screens/subscription_screen.dart';
import 'package:anotara/models/subscription_usage.dart';
import 'package:anotara/services/subscription_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Same shape as the JSON returned by anotara_get_subscription_usage().
const _freeUserAtLimit = <String, dynamic>{
  'plan_id': 'free',
  'plan_name': 'Free',
  'period_start': null,
  'period_end': null,
  'groups': {'used': 1, 'limit': 1},
  'active_trips': {'used': 0, 'limit': 1},
  'ai_generations': {
    'used': 2,
    'limit': 3,
    'period_start': '2026-11-01T00:00:00+08:00',
    'resets_at': '2026-12-01T00:00:00+08:00',
  },
  'members_per_group': {
    'limit': 8,
    'groups': [
      {'group_id': 'g1', 'group_name': 'Barkada', 'used': 5},
    ],
  },
};

class _FakeService extends SubscriptionService {
  _FakeService(this._result);

  final Future<SubscriptionUsage> Function() _result;

  @override
  Future<SubscriptionUsage> fetchUsage() => _result();
}

Future<void> _pumpScreen(WidgetTester tester, SubscriptionService service) async {
  tester.view.physicalSize = const Size(375, 1300);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: SubscriptionScreen(service: service)));
  // Let google_fonts finish loading bundled fonts before settling. The usage
  // list appears after the first settle and requests more font weights, so
  // wait twice.
  for (var i = 0; i < 2; i++) {
    await tester.runAsync(() async {
      await GoogleFonts.pendingFonts();
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();
  }
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('SubscriptionUsage.fromMap', () {
    test('reads every quota from the database JSON', () {
      final usage = SubscriptionUsage.fromMap(_freeUserAtLimit);

      expect(usage.isFree, isTrue);
      expect(usage.groups.used, 1);
      expect(usage.groups.limit, 1);
      expect(usage.groups.isAtLimit, isTrue);
      expect(usage.activeTrips.isAtLimit, isFalse);
      expect(usage.aiGenerations.label, '2 of 3');
      expect(usage.aiResetsAt, isNotNull);
      expect(usage.membersPerGroupLimit, 8);
      expect(usage.groupMembers.single.groupName, 'Barkada');
      expect(usage.groupMembers.single.members.label, '5 of 8');
    });

    test('a null limit means unlimited', () {
      const quota = QuotaUsage(used: 12);
      expect(quota.isUnlimited, isTrue);
      expect(quota.isAtLimit, isFalse);
      expect(quota.fraction, 0);
      expect(quota.label, '12 used');
    });
  });

  group('QuotaExceededException.from', () {
    test('recognises a plan-limit error from the database', () {
      const error = PostgrestException(
        message: 'Your Free plan allows 1 active group(s).',
        code: 'P0001',
        hint: 'quota_exceeded:groups',
      );
      final quota = QuotaExceededException.from(error);
      expect(quota, isNotNull);
      expect(quota!.quota, 'groups');
    });

    test('ignores other errors', () {
      const error = PostgrestException(message: 'boom', code: 'P0001');
      expect(QuotaExceededException.from(error), isNull);
      expect(QuotaExceededException.from(Exception('x')), isNull);
    });
  });

  group('SubscriptionScreen', () {
    testWidgets('shows plan usage and flags reached limits', (tester) async {
      await _pumpScreen(
        tester,
        _FakeService(() async => SubscriptionUsage.fromMap(_freeUserAtLimit)),
      );

      expect(find.text('Free Plan'), findsOneWidget);
      expect(find.text('Expires: Never'), findsOneWidget);
      expect(find.byKey(const ValueKey('usage-groups')), findsOneWidget);
      expect(find.text('1 of 1'), findsOneWidget);
      expect(find.text('2 of 3'), findsOneWidget);
      expect(find.text('5 of 8'), findsOneWidget);
      expect(find.text('Limit reached. Upgrade to add more.'), findsOneWidget);
    });

    testWidgets('falls back gracefully when usage cannot load', (tester) async {
      await _pumpScreen(
        tester,
        _FakeService(() async => throw Exception('offline')),
      );

      expect(
        find.text('Usage is unavailable right now. Pull down to try again.'),
        findsOneWidget,
      );
    });
  });
}
