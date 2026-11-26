import 'package:anotara/models/trip_participant.dart';
import 'package:anotara/screens/view_trip_members_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sampleParticipants = [
    TripParticipant(
      id: '1',
      name: 'Louielyn Abella',
      username: 'blackxswann',
      status: TripResponseStatus.going,
    ),
    TripParticipant(
      id: '2',
      name: 'Hannah S. Labandero',
      username: 'hannah.l',
      status: TripResponseStatus.going,
    ),
    TripParticipant(
      id: '3',
      name: 'Carla Santos',
      username: 'carla.s',
      status: TripResponseStatus.notGoing,
    ),
    TripParticipant(
      id: '4',
      name: 'Jessa',
      username: 'jessa.c',
      status: TripResponseStatus.pending,
      isNudged: true,
    ),
    TripParticipant(
      id: '5',
      name: 'Nico',
      username: 'nico.t',
      status: TripResponseStatus.pending,
    ),
  ];

  Widget buildTestApp({bool isOrganizer = true}) {
    return MaterialApp(
      home: ViewTripMembersScreen(
        initialParticipants: sampleParticipants,
        isOrganizer: isOrganizer,
      ),
    );
  }

  testWidgets(
    'displays responded count and Going, Not Going, Pending counts',
    (tester) async {
      await tester.pumpWidget(buildTestApp());

      expect(find.text('View Trip Members'), findsOneWidget);
      expect(find.text('3'), findsOneWidget); // responded count
      expect(find.text('of 5'), findsOneWidget);
      expect(find.text('members have responded'), findsOneWidget);
      expect(find.text('Going'), findsWidgets);
      expect(find.text('Not Going'), findsWidgets);
      expect(find.text('Pending'), findsWidgets);
      expect(find.text('2'), findsNWidgets(2)); // Going: 2, Pending: 2
      expect(find.text('1'), findsOneWidget); // Not Going: 1
      expect(find.text('Nudge Members'), findsOneWidget);
    },
  );

  testWidgets(
    'Filter By sheet filters Invitation Responses and resets to All',
    (tester) async {
      await tester.pumpWidget(buildTestApp());

      // Open Filter By sheet
      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();

      expect(find.text('Filter By'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
      expect(find.text('Apply'), findsOneWidget);

      // Select Not Going and Apply
      await tester.tap(find.text('Not Going').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      // Only Carla Santos (Not Going) should be shown in the list
      expect(find.text('Carla Santos'), findsOneWidget);
      expect(find.text('Louielyn Abella'), findsNothing);
      expect(find.text('Nico'), findsNothing);

      // Reopen Filter By, tap Reset then Apply
      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      // All participants visible again
      expect(find.text('Louielyn Abella'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Carla Santos'), 120);
      expect(find.text('Carla Santos'), findsOneWidget);
    },
  );

  testWidgets(
    'Nudge button changes to Nudged after tap and persists across reopen',
    (tester) async {
      await tester.pumpWidget(buildTestApp());

      // Open Nudge Members sheet
      await tester.tap(find.text('Nudge Members'));
      await tester.pumpAndSettle();

      expect(find.text('Jessa'), findsWidgets);
      expect(find.text('Nico'), findsWidgets);
      expect(find.text('Nudged'), findsOneWidget); // Jessa already nudged
      expect(find.text('Nudge'), findsOneWidget); // Nico not yet nudged

      // Tap Nudge for Nico
      await tester.tap(find.text('Nudge'));
      await tester.pumpAndSettle();

      expect(find.text('Nudge'), findsNothing);
      expect(find.text('Nudged'), findsNWidgets(2));

      // Close sheet and reopen to verify state persisted
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nudge Members'));
      await tester.pumpAndSettle();

      expect(find.text('Nudge'), findsNothing);
      expect(find.text('Nudged'), findsNWidgets(2));
    },
  );

  testWidgets(
    'Organizer removal requires confirmation and updates list and counts',
    (tester) async {
      await tester.pumpWidget(buildTestApp(isOrganizer: true));

      final removeLouielyn = find.byTooltip('Remove Louielyn Abella');
      expect(removeLouielyn, findsOneWidget);

      // Tap remove -> confirmation dialog appears
      await tester.tap(removeLouielyn);
      await tester.pumpAndSettle();

      expect(find.text('Remove Trip Participant'), findsOneWidget);
      expect(
        find.text(
          'They will no longer be part of this trip or receive trip updates. They will remain a member of the group.',
        ),
        findsOneWidget,
      );
      expect(find.text('Remove Member'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Tapping Cancel keeps the participant
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Louielyn Abella'), findsOneWidget);
      expect(find.text('of 5'), findsOneWidget);

      // Tap remove again and confirm
      await tester.tap(removeLouielyn);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove Member'));
      await tester.pumpAndSettle();

      expect(find.text('Louielyn Abella'), findsNothing);
      expect(find.text('of 4'), findsOneWidget);
    },
  );

  testWidgets(
    'Non-organizer cannot see or trigger participant removal',
    (tester) async {
      await tester.pumpWidget(buildTestApp(isOrganizer: false));

      expect(find.byTooltip('Remove Louielyn Abella'), findsNothing);
      expect(find.byTooltip('Remove Carla Santos'), findsNothing);
      expect(find.text('Louielyn Abella'), findsOneWidget);
    },
  );

  testWidgets(
    'Remove Participant modal close button is aligned in top-right corner',
    (tester) async {
      await tester.pumpWidget(buildTestApp(isOrganizer: true));

      await tester.tap(find.byTooltip('Remove Louielyn Abella'));
      await tester.pumpAndSettle();

      final closeIcon = find.byIcon(Icons.close_rounded);
      final title = find.text('Remove Trip Participant');
      final headerStack = find
          .ancestor(of: closeIcon, matching: find.byType(Stack))
          .first;
      expect(closeIcon, findsOneWidget);
      expect(title, findsOneWidget);

      final closeRect = tester.getRect(closeIcon);
      final titleRect = tester.getRect(title);
      final stackRect = tester.getRect(headerStack);

      // Close icon (centered inside 40x40 tap target) should align to top-right
      expect(closeRect.center.dx, closeTo(stackRect.right - 20, 1.0));
      expect(closeRect.bottom, lessThan(titleRect.top));

      // Tapping close dismisses the modal without removing the participant
      await tester.tap(closeIcon);
      await tester.pumpAndSettle();
      expect(find.text('Remove Trip Participant'), findsNothing);
      expect(find.text('Louielyn Abella'), findsOneWidget);
    },
  );
}
