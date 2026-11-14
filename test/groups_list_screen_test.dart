import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax/iconsax.dart';

import 'package:anotara/components/organisms/group_list_card.dart';
import 'package:anotara/models/group_models.dart';
import 'package:anotara/screens/groups/create_group_screen.dart';
import 'package:anotara/screens/groups/group_details_screen.dart';
import 'package:anotara/screens/groups/groups_list_screen.dart';
import 'package:anotara/theme/app_theme.dart';

void main() {
  Future<void> pumpList(WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: buildAppTheme(), home: const GroupsListScreen()),
    );
    await tester.pumpAndSettle();
  }

  List<String> cardNames(WidgetTester tester) => [
    for (final card in tester.widgetList<GroupListCard>(
      find.byType(GroupListCard),
    ))
      card.group.name,
  ];

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  group('GroupFilter', () {
    final groups = GroupSummary.sampleList();

    test('defaults to newest first', () {
      expect(const GroupFilter().isDefault, isTrue);
      expect(const GroupFilter().apply(groups).map((g) => g.name), [
        'Group 4',
        'Twice',
        'Blackpink',
        'The Group',
      ]);
    });

    test('filters by role, activity and search', () {
      expect(
        const GroupFilter(
          role: GroupRole.organizer,
        ).apply(groups).map((g) => g.name),
        ['Group 4', 'The Group'],
      );
      expect(
        const GroupFilter(
          activity: GroupActivity.upcomingTrip,
          sort: GroupSort.nameAz,
        ).apply(groups).map((g) => g.name),
        ['Blackpink', 'Twice'],
      );
      expect(
        const GroupFilter().apply(groups, query: 'BLACK').map((g) => g.name),
        ['Blackpink'],
      );
    });
  });

  testWidgets('lists groups and searches by name', (tester) async {
    await pumpList(tester);

    expect(cardNames(tester), ['Group 4', 'Twice', 'Blackpink', 'The Group']);
    expect(find.text('Next: Bantayan Trip'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'twi');
    await tester.pumpAndSettle();
    expect(cardNames(tester), ['Twice']);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('No groups match your search or filters.'), findsOne);
  });

  testWidgets('Filter Groups sheet applies, resets and closes', (tester) async {
    await pumpList(tester);

    await tester.tap(find.bySemanticsLabel('Filter'));
    await tester.pumpAndSettle();
    expect(find.text('Filter Groups'), findsOneWidget);
    expect(find.text('Group Activity'), findsOneWidget);
    expect(find.text('Your Role'), findsOneWidget);

    // The cards behind the sheet also say "Organizer"; the sheet is on top.
    await tapVisible(tester, find.text('Organizer').last);
    await tapVisible(tester, find.text('Group Name (A-Z)'));
    await tapVisible(tester, find.text('Apply Filters'));

    expect(find.text('Filter Groups'), findsNothing);
    expect(cardNames(tester), ['Group 4', 'The Group']);

    await tester.tap(find.bySemanticsLabel('Filter'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Reset'));
    await tapVisible(tester, find.text('Apply Filters'));
    expect(cardNames(tester), ['Group 4', 'Twice', 'Blackpink', 'The Group']);
  });

  test('invite codes resolve case-insensitively', () {
    final match = GroupDetails.findByInviteCode(' trip5 ');
    expect(match?.group.name, 'Weekend Wanderers');
    expect(match?.group.isOrganizer, isFalse);
    expect(match?.organizerName, 'Bea Tan');
    expect(GroupDetails.findByInviteCode('ZZZZZ'), isNull);
  });

  Future<void> enterCode(WidgetTester tester, String code) async {
    await tester.tap(find.text('Join with Code'));
    await tester.pumpAndSettle();
    expect(find.text('Join a Group'), findsOneWidget);
    // The sheet's hidden code field is the last TextField on screen.
    await tester.enterText(find.byType(TextField).last, code);
    await tester.pump();
  }

  testWidgets('Join Group needs all five characters; Cancel closes', (
    tester,
  ) async {
    await pumpList(tester);
    await enterCode(tester, 'tr!p');

    // Lowercase is upper-cased and symbols are dropped.
    expect(find.text('T'), findsOneWidget);
    expect(find.text('R'), findsOneWidget);
    expect(find.text('P'), findsOneWidget);
    await tester.tap(find.text('Join Group'));
    await tester.pumpAndSettle();
    expect(find.text('Join a Group'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Join a Group'), findsNothing);
  });

  testWidgets('invalid code offers Try Again, then a valid code joins', (
    tester,
  ) async {
    await pumpList(tester);
    await enterCode(tester, 'ZZZZZ');
    await tester.tap(find.text('Join Group'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid Invitation Code'), findsOneWidget);
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(find.text('Invalid Invitation Code'), findsNothing);
    expect(find.text('Join a Group'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'TRIP5');
    await tester.pump();
    await tester.tap(find.text('Join Group'));
    await tester.pumpAndSettle();

    expect(find.text('Successfully Joined!'), findsOneWidget);
    expect(find.textContaining("You've joined Weekend Wanderers!"), findsOne);

    await tester.tap(find.text('View Group'));
    await tester.pumpAndSettle();
    final details = tester.widget<GroupDetailsScreen>(
      find.byType(GroupDetailsScreen),
    );
    expect(details.group.name, 'Weekend Wanderers');
    expect(details.group.isOrganizer, isFalse);
  });

  testWidgets('Back to Groups stays on the list with the joined group', (
    tester,
  ) async {
    await pumpList(tester);
    await enterCode(tester, 'BORA8');
    await tester.tap(find.text('Join Group'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back to Groups'));
    await tester.pumpAndSettle();

    expect(find.byType(GroupDetailsScreen), findsNothing);
    expect(cardNames(tester).first, 'Boracay Barkada');

    // Joining the same group again does not add a duplicate card.
    await enterCode(tester, 'BORA8');
    await tester.tap(find.text('Join Group'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back to Groups'));
    await tester.pumpAndSettle();
    expect(
      cardNames(tester).where((n) => n == 'Boracay Barkada'),
      hasLength(1),
    );
  });

  testWidgets('Cancel on an invalid code goes back to the list', (
    tester,
  ) async {
    await pumpList(tester);
    await enterCode(tester, 'ZZZZZ');
    await tester.tap(find.text('Join Group'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid Invitation Code'), findsNothing);
    expect(find.text('Join a Group'), findsNothing);
    expect(cardNames(tester), hasLength(4));
  });

  testWidgets('tapping a group card opens its details', (tester) async {
    await pumpList(tester);

    await tapVisible(tester, find.bySemanticsLabel('Blackpink, Member'));
    expect(find.byType(GroupDetailsScreen), findsOneWidget);
    expect(find.text('Blackpink'), findsWidgets);
  });

  testWidgets('create group: name required, invite, review, success', (
    tester,
  ) async {
    await pumpList(tester);

    await tester.tap(find.text('Create Group'));
    await tester.pumpAndSettle();
    expect(find.byType(CreateGroupScreen), findsOneWidget);
    expect(find.text('Every adventure starts here!'), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);

    // Step 1: name is required, description is optional.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Group name is required'), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Weekend Wanderers');
    await tester.pumpAndSettle();
    expect(find.text('Group name is required'), findsNothing);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 2: pick people from the Invite Members sheet.
    expect(find.text("Who's in your travel crew?"), findsOneWidget);
    expect(find.text('2/3'), findsOneWidget);
    expect(find.text('0 people selected'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Search people to invite'));
    await tester.pumpAndSettle();
    expect(find.text('Invite Members'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Select Jane Doe'));
    await tester.pump();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Invite Members'), findsNothing);
    expect(find.text('1 person selected'), findsOneWidget);
    expect(find.text('Jane Doe'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 3: review, with Edit links back to earlier steps.
    expect(find.text('Ready to make it official!'), findsOneWidget);
    expect(find.text('3/3'), findsOneWidget);
    expect(find.text('Weekend Wanderers'), findsOneWidget);
    expect(find.text('No description'), findsOneWidget);
    expect(find.text('Jane Doe'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Edit group members'));
    await tester.pumpAndSettle();
    expect(find.text('2/3'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create Group').last);
    await tester.pumpAndSettle();
    expect(find.text('Your group is ready!'), findsOneWidget);

    await tester.tap(find.text('View Group'));
    await tester.pumpAndSettle();

    // Lands on the new group's details; it is also in the list now.
    expect(find.byType(GroupDetailsScreen), findsOneWidget);
    final details = tester.widget<GroupDetailsScreen>(
      find.byType(GroupDetailsScreen),
    );
    expect(details.group.name, 'Weekend Wanderers');
    expect(details.group.isOrganizer, isTrue);
    expect(details.group.members.map((m) => m.name), [
      'Marco Reyes',
      'Jane Doe',
    ]);

    Navigator.of(tester.element(find.byType(GroupDetailsScreen))).pop();
    await tester.pumpAndSettle();
    expect(cardNames(tester).first, 'Weekend Wanderers');
  });

  testWidgets('back steps through the flow before leaving it', (tester) async {
    await pumpList(tester);

    await tester.tap(find.text('Create Group'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Crew');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();
    expect(find.text('3/3'), findsOneWidget);
    expect(find.text('Just you for now'), findsOneWidget);

    await tester.tap(find.byIcon(Iconsax.arrow_left));
    await tester.pumpAndSettle();
    expect(find.text('2/3'), findsOneWidget);
    await tester.tap(find.byIcon(Iconsax.arrow_left));
    await tester.pumpAndSettle();
    expect(find.text('1/3'), findsOneWidget);
    expect(find.text('Crew'), findsOneWidget);
    await tester.tap(find.byIcon(Iconsax.arrow_left));
    await tester.pumpAndSettle();

    expect(find.byType(CreateGroupScreen), findsNothing);
    expect(cardNames(tester), hasLength(4));
  });
}
