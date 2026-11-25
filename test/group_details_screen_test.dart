import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anotara/components/organisms/availability_calendar.dart';
import 'package:anotara/components/organisms/group_header_organism.dart';
import 'package:anotara/components/organisms/group_trip_card.dart';
import 'package:anotara/components/organisms/group_member_card.dart';
import 'package:anotara/models/group_models.dart';
import 'package:anotara/screens/groups/edit_group_screen.dart';
import 'package:anotara/screens/groups/group_details_screen.dart';
import 'package:anotara/theme/app_theme.dart';

void main() {
  Future<void> pumpScreen(WidgetTester tester, GroupDetails group) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GroupDetailsScreen(group: group),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  final organizerGroup = GroupDetails.sample('The Group');
  final memberGroup = GroupDetails.sample('The Group', role: GroupRole.member);

  testWidgets('organizer sees the Group Actions menu', (tester) async {
    await pumpScreen(tester, organizerGroup);

    expect(find.text('Organizer'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Group actions'));
    await tester.pumpAndSettle();

    expect(find.text('Group Actions'), findsOneWidget);
    expect(find.text('Edit Group'), findsOneWidget);
    expect(find.text('Invite Members'), findsOneWidget);
    expect(find.text('Group Invite Code'), findsOneWidget);
    expect(find.text('Delete Group'), findsOneWidget);
  });

  testWidgets('selected trip replaces the group name in the header', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: GroupDetailsScreen(
          group: organizerGroup,
          focusedTripId: 'baguio',
        ),
      ),
    );
    await tester.pumpAndSettle();

    Finder inHeader(String text) => find.descendant(
      of: find.byType(GroupHeaderOrganism),
      matching: find.text(text),
    );
    expect(inHeader('Baguio Retreat'), findsOneWidget);
    expect(inHeader('The Group'), findsNothing);

    await tester.tap(find.text('Siargao Getaway'));
    await tester.pumpAndSettle();
    expect(inHeader('Siargao Getaway'), findsOneWidget);
    expect(find.text('Group Actions'), findsNothing);
  });

  testWidgets('trip arrow opens Group Actions for organizers', (tester) async {
    await pumpScreen(tester, organizerGroup);

    final arrow = find.bySemanticsLabel('Bantayan Trip options');
    await tester.ensureVisible(arrow);
    await tester.pumpAndSettle();
    await tester.tap(arrow);
    await tester.pumpAndSettle();
    expect(find.text('Group Actions'), findsOneWidget);
  });

  testWidgets('Availability tab shows the heat map and best dates', (
    tester,
  ) async {
    await pumpScreen(tester, organizerGroup);
    await tester.tap(find.text('Availability'));
    await tester.pumpAndSettle();

    expect(find.byType(AvailabilityCalendar), findsOneWidget);
    expect(find.text('Edit Availability'), findsOneWidget);
    expect(find.text('Best Dates'), findsOneWidget);
    expect(find.byType(BestDateCard), findsNWidgets(3));
  });

  testWidgets('Edit Availability saves the dates I pick', (tester) async {
    await pumpScreen(tester, organizerGroup);
    await tester.tap(find.text('Availability'));
    await tester.pumpAndSettle();

    // Sample data: on the 4th, 3 of the 6 joined members are free (not me).
    final day4 = RegExp(r'^[A-Za-z]+ 4, ');
    expect(
      find.bySemanticsLabel(RegExp('${day4.pattern}3 of 6 available\$')),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Edit Availability'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Availability'));
    await tester.pumpAndSettle();
    expect(find.text('My Availability'), findsOneWidget);

    await tester.tap(
      find.bySemanticsLabel(RegExp('${day4.pattern}not available\$')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Update Availability'));
    await tester.pumpAndSettle();

    expect(find.text('Your availability was updated'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('${day4.pattern}4 of 6 available\$')),
      findsOneWidget,
    );
  });

  testWidgets('members do not see organizer-only actions', (tester) async {
    await pumpScreen(tester, memberGroup);

    expect(find.text('Member'), findsOneWidget);
    expect(find.bySemanticsLabel('Group actions'), findsNothing);
    expect(find.text('Plan a Trip'), findsOneWidget);
  });

  testWidgets('tabs swap content in place without pushing routes', (
    tester,
  ) async {
    await pumpScreen(tester, organizerGroup);
    expect(find.byType(GroupTripCard), findsNWidgets(3));

    await tester.tap(find.text('Availability'));
    await tester.pumpAndSettle();
    expect(find.byType(GroupMemberCard), findsNothing);
    expect(find.byType(GroupTripCard), findsNothing);

    await tester.tap(find.text('Members'));
    await tester.pumpAndSettle();
    expect(find.byType(GroupMemberCard), findsWidgets);

    // Still a single pushed route: one back press returns to the launcher.
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pop();
    await tester.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('Filter Trips sheet filters by status', (tester) async {
    await pumpScreen(tester, organizerGroup);

    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();
    expect(find.text('Filter Trips'), findsOneWidget);
    expect(find.text('Trip Date (Newest First)'), findsOneWidget);

    await tester.tap(find.text('Completed').last);
    await tester.tap(find.text('Apply Filters'));
    await tester.pumpAndSettle();

    expect(find.byType(GroupTripCard), findsOneWidget);
    expect(find.text('Baguio Retreat'), findsOneWidget);
  });

  testWidgets('Share Group Code shows each code character', (tester) async {
    await pumpScreen(tester, organizerGroup);

    await tester.tap(find.bySemanticsLabel('Group actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Group Invite Code'));
    await tester.pumpAndSettle();

    expect(find.text('Share Group Code'), findsOneWidget);
    for (final char in 'BTN73'.split('')) {
      expect(find.text(char), findsOneWidget);
    }
  });

  Future<void> openMembersTab(WidgetTester tester) async {
    await tester.tap(find.text('Members'));
    await tester.pumpAndSettle();
  }

  testWidgets('Members tab lists members with organizer remove actions', (
    tester,
  ) async {
    await pumpScreen(tester, organizerGroup);
    await openMembersTab(tester);

    expect(find.byType(GroupMemberCard), findsNWidgets(7));
    expect(find.text('Pending'), findsOneWidget);
    // Every member except the organizer themselves can be removed.
    expect(find.bySemanticsLabel(RegExp(r'^Remove ')), findsNWidgets(6));
  });

  testWidgets('members cannot remove other members', (tester) async {
    await pumpScreen(tester, memberGroup);
    await openMembersTab(tester);

    expect(find.byType(GroupMemberCard), findsNWidgets(7));
    expect(find.bySemanticsLabel(RegExp(r'^Remove ')), findsNothing);
  });

  testWidgets('member search narrows the list', (tester) async {
    await pumpScreen(tester, organizerGroup);
    await openMembersTab(tester);

    await tester.enterText(find.byType(TextField), 'hannah');
    await tester.pumpAndSettle();

    expect(find.byType(GroupMemberCard), findsOneWidget);
    expect(find.text('Hannah Labandero'), findsOneWidget);
  });

  testWidgets('Filter Members sheet filters by membership status', (
    tester,
  ) async {
    await pumpScreen(tester, organizerGroup);
    await openMembersTab(tester);

    await tester.tap(find.bySemanticsLabel('Filter'));
    await tester.pumpAndSettle();
    expect(find.text('Filter Members'), findsOneWidget);
    expect(find.text('Membership Status'), findsOneWidget);

    await tester.tap(find.text('Pending Invitation'));
    await tester.tap(find.text('Apply Filters'));
    await tester.pumpAndSettle();

    expect(find.byType(GroupMemberCard), findsOneWidget);
    expect(find.text('Louielyn Abella'), findsOneWidget);
  });

  testWidgets('confirming Remove Member removes them from the list', (
    tester,
  ) async {
    await pumpScreen(tester, organizerGroup);
    await openMembersTab(tester);

    final removeHannah = find.bySemanticsLabel('Remove Hannah Labandero');
    await tester.ensureVisible(removeHannah);
    await tester.pumpAndSettle();
    await tester.tap(removeHannah);
    await tester.pumpAndSettle();
    expect(find.text('Remove Group Member'), findsOneWidget);

    await tester.tap(find.text('Remove Member'));
    await tester.pumpAndSettle();

    expect(find.byType(GroupMemberCard), findsNWidgets(6));
    expect(find.text('Hannah Labandero'), findsNothing);
  });

  Future<void> openGroupAction(WidgetTester tester, String action) async {
    await tester.tap(find.bySemanticsLabel('Group actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(action));
    await tester.pumpAndSettle();
  }

  testWidgets('Invite Members sheet searches and invites selected people', (
    tester,
  ) async {
    await pumpScreen(tester, organizerGroup);
    await openGroupAction(tester, 'Invite Members');

    expect(
      find.text('Find and select people to join the group.'),
      findsOneWidget,
    );
    expect(find.text('6 results'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'jane');
    await tester.pumpAndSettle();
    expect(find.text('1 result'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Select Jane Doe'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Deselect Jane Doe'), findsOneWidget);
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Invitation sent to Jane Doe'), findsOneWidget);
    await openMembersTab(tester);
    await tester.enterText(find.byType(TextField), 'jane');
    await tester.pumpAndSettle();
    expect(find.byType(GroupMemberCard), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();

    // Already-invited people no longer appear as candidates.
    await openGroupAction(tester, 'Invite Members');
    expect(find.text('5 results'), findsOneWidget);
    expect(find.bySemanticsLabel('Select Jane Doe'), findsNothing);
  });

  testWidgets('Edit Group saves the new name and description', (tester) async {
    await pumpScreen(tester, organizerGroup);
    await openGroupAction(tester, 'Edit Group');

    expect(find.text('Edit Group Details'), findsOneWidget);
    expect(find.text('Pasyara mi plss.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'AnoTara?');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(find.byType(EditGroupScreen), findsNothing);
    expect(find.text('AnoTara?'), findsOneWidget);
    expect(find.text('Group details updated'), findsOneWidget);
  });

  testWidgets('Edit Group requires a name and Cancel discards edits', (
    tester,
  ) async {
    await pumpScreen(tester, organizerGroup);
    await openGroupAction(tester, 'Edit Group');

    await tester.enterText(find.byType(TextFormField).first, '   ');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(find.text('Group name is required'), findsOneWidget);
    expect(find.byType(EditGroupScreen), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(EditGroupScreen), findsNothing);
    expect(find.text('The Group'), findsOneWidget);
  });

  testWidgets('Edit Group can invite members into the draft', (tester) async {
    await pumpScreen(tester, organizerGroup);
    await openGroupAction(tester, 'Edit Group');

    await tester.tap(find.bySemanticsLabel('Invite members'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Select Bea Tan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.byType(GroupMemberCard), findsWidgets);
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    await openMembersTab(tester);
    expect(find.text('Bea Tan'), findsOneWidget);
  });

  testWidgets('confirming Delete Group leaves the screen', (tester) async {
    await pumpScreen(tester, organizerGroup);

    await tester.tap(find.bySemanticsLabel('Group actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete Group'));
    await tester.pumpAndSettle();

    expect(find.textContaining('cannot be undone'), findsOneWidget);
    await tester.tap(find.widgetWithText(GestureDetector, 'Delete Group').last);
    await tester.pumpAndSettle();

    expect(find.byType(GroupDetailsScreen), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });
}
