import 'package:anotara/components/invitation_filter.dart';
import 'package:anotara/components/invitation_tile.dart';
import 'package:anotara/components/mark_all_as_read.dart';
import 'package:anotara/components/notification_tile.dart';
import 'package:anotara/components/organisms/app_top_bar.dart';
import 'package:anotara/screens/group_invitation_screen.dart';
import 'package:anotara/screens/invitation_result_screen.dart';
import 'package:anotara/screens/notifications_screen.dart';
import 'package:anotara/screens/trip_invitation_screen.dart';
import 'package:anotara/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestableScreen(Widget child) {
    return MaterialApp(
      theme: buildAppTheme(),
      home: child,
    );
  }

  void setPhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('NotificationsScreen Activity Tab tests', () {
    testWidgets(
      'Renders TopBar, SegmentedTabs, Mark all as read, Filter, and unread dot',
      (WidgetTester tester) async {
        setPhoneViewport(tester);

        await tester.pumpWidget(buildTestableScreen(const NotificationsScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Notifications'), findsOneWidget);
        expect(find.byType(AppTopBar), findsOneWidget);
        expect(find.text('Activity'), findsOneWidget);
        expect(find.text('Invitations'), findsOneWidget);

        expect(find.byType(MarkAllAsRead), findsOneWidget);
        expect(find.text('Mark all as read'), findsOneWidget);
        expect(find.byKey(const Key('activity_filter')), findsOneWidget);
        expect(find.text('Filter'), findsOneWidget);

        expect(find.byType(NotificationTile), findsNWidgets(2));
        expect(find.text('New expense added'), findsOneWidget);
        expect(find.text('Trip details updated'), findsOneWidget);
        // Only the first notification is unread
        expect(find.byKey(const Key('unread_dot')), findsOneWidget);
      },
    );

    testWidgets(
      'Clicking Filter opens Filter Activity modal and applies/resets filters',
      (WidgetTester tester) async {
        setPhoneViewport(tester);

        await tester.pumpWidget(buildTestableScreen(const NotificationsScreen()));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('unread_dot')), findsOneWidget);

        // Tap Filter -> opens Filter Activity modal
        await tester.tap(find.byKey(const Key('activity_filter')));
        await tester.pumpAndSettle();

        expect(find.text('Filter Activity'), findsOneWidget);
        expect(find.text('Read Status'), findsOneWidget);
        expect(find.text('All Notifications'), findsOneWidget);
        expect(find.text('Activity Type'), findsOneWidget);
        expect(find.text('All Activities'), findsOneWidget);
        expect(find.text('Sort By'), findsOneWidget);
        expect(find.text('Reset'), findsOneWidget);
        expect(find.text('Apply Filters'), findsOneWidget);

        // Select Unread and Apply Filters
        await tester.tap(find.text('Unread'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Apply Filters'));
        await tester.pumpAndSettle();

        expect(find.byType(NotificationTile), findsOneWidget);
        expect(find.text('New expense added'), findsOneWidget);

        // Open modal again -> Reset -> Apply Filters
        await tester.tap(find.byKey(const Key('activity_filter')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Reset'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Apply Filters'));
        await tester.pumpAndSettle();

        expect(find.byType(NotificationTile), findsNWidgets(2));

        // Tap Mark all as read -> unread dot disappears
        await tester.tap(find.byType(MarkAllAsRead));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('unread_dot')), findsNothing);
      },
    );
  });

  group('NotificationsScreen Invitations Tab & Flows', () {
    testWidgets(
      'Clicking Filter opens Filter Invitations modal and filters by status & type',
      (WidgetTester tester) async {
        setPhoneViewport(tester);

        await tester.pumpWidget(buildTestableScreen(const NotificationsScreen()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Invitations'));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('invitation_filter')), findsOneWidget);
        expect(find.text('Filter'), findsOneWidget);
        expect(find.byType(InvitationTile), findsNWidgets(4));
        expect(find.text('Weekend Wanderers'), findsOneWidget);

        // Open Filter Invitations modal
        await tester.tap(find.byKey(const Key('invitation_filter')));
        await tester.pumpAndSettle();

        expect(find.text('Filter Invitations'), findsOneWidget);
        expect(find.text('Invitation Status'), findsOneWidget);
        expect(find.text('All Statuses'), findsOneWidget);
        expect(find.text('Invitation Type'), findsOneWidget);
        expect(find.text('All Invitations'), findsOneWidget);
        expect(find.text('Group Invitations'), findsOneWidget);
        expect(find.text('Trip Invitations'), findsOneWidget);

        // Filter by Declined and Apply
        await tester.tap(find.text('Declined').last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Apply Filters'));
        await tester.pumpAndSettle();

        expect(find.byType(InvitationTile), findsOneWidget);

        // Open modal, Reset, filter by Group Invitations only
        await tester.tap(find.byKey(const Key('invitation_filter')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Reset'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Group Invitations'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Apply Filters'));
        await tester.pumpAndSettle();

        expect(find.byType(InvitationTile), findsOneWidget);
        expect(find.text('Weekend Wanderers'), findsOneWidget);
      },
    );

    testWidgets(
      'Group Invitation displays Figma layout and Accept shows accepted result screen',
      (WidgetTester tester) async {
        setPhoneViewport(tester);

        await tester.pumpWidget(
          buildTestableScreen(const NotificationsScreen(initialTabIndex: 1)),
        );
        await tester.pumpAndSettle();

        // Tap Weekend Wanderers (Group Invitation)
        await tester.tap(find.text('Weekend Wanderers'));
        await tester.pumpAndSettle();

        expect(find.byType(GroupInvitationScreen), findsOneWidget);
        expect(find.text('Group Invitation'), findsOneWidget);
        expect(find.text("You're invited!"), findsOneWidget);
        expect(find.text('GROUP DETAILS'), findsOneWidget);
        expect(find.text('Organizer'), findsOneWidget);
        expect(find.text('Members'), findsOneWidget);
        expect(find.text('8 members'), findsOneWidget);
        expect(find.text('Your status'), findsOneWidget);
        expect(find.text('Accept Invitation'), findsOneWidget);
        expect(find.text('Decline'), findsOneWidget);

        // Tap Accept Invitation
        await tester.tap(find.text('Accept Invitation'));
        await tester.pumpAndSettle();

        expect(find.byType(InvitationResultScreen), findsOneWidget);
        expect(find.text('Group Invitation Accepted'), findsOneWidget);
        expect(find.text('View Group'), findsOneWidget);

        // Tap View Group -> returns to Invitations list with updated status
        await tester.tap(find.text('View Group'));
        await tester.pumpAndSettle();

        expect(find.byType(NotificationsScreen), findsOneWidget);
        expect(find.text('Accepted'), findsNWidgets(2));
      },
    );

    testWidgets(
      'Group Invitation Decline shows Group Invitation Declined result screen',
      (WidgetTester tester) async {
        setPhoneViewport(tester);

        await tester.pumpWidget(
          buildTestableScreen(const NotificationsScreen(initialTabIndex: 1)),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Weekend Wanderers'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Decline'));
        await tester.pumpAndSettle();

        expect(find.byType(InvitationResultScreen), findsOneWidget);
        expect(find.text('Group Invitation Declined'), findsOneWidget);
        expect(find.text('Back to Invitations'), findsOneWidget);

        await tester.tap(find.text('Back to Invitations'));
        await tester.pumpAndSettle();

        expect(find.byType(NotificationsScreen), findsOneWidget);
        expect(find.text('Declined'), findsNWidgets(2));
      },
    );

    testWidgets(
      'Trip Invitation displays Figma layout and Accept shows accepted result screen',
      (WidgetTester tester) async {
        setPhoneViewport(tester);

        await tester.pumpWidget(
          buildTestableScreen(const NotificationsScreen(initialTabIndex: 1)),
        );
        await tester.pumpAndSettle();

        // Tap the first Bantayan Trip (Pending Trip Invitation)
        await tester.tap(find.text('Bantayan Trip').first);
        await tester.pumpAndSettle();

        expect(find.byType(TripInvitationScreen), findsOneWidget);
        expect(find.text('Trip Invitation'), findsOneWidget);
        expect(find.text("You're invited!"), findsOneWidget);
        expect(find.text('TRIP DETAILS'), findsOneWidget);
        expect(find.text('Organizer'), findsOneWidget);
        expect(find.text('Destination'), findsOneWidget);
        expect(find.text('Bantayan Island, Cebu'), findsOneWidget);
        expect(find.text('Dates'), findsOneWidget);
        expect(find.text('June 8 - June 10'), findsOneWidget);
        expect(find.text('Your status'), findsOneWidget);
        expect(find.text('Accept Invitation'), findsOneWidget);
        expect(find.text('Decline'), findsOneWidget);

        await tester.tap(find.text('Accept Invitation'));
        await tester.pumpAndSettle();

        expect(find.byType(InvitationResultScreen), findsOneWidget);
        expect(find.text('Trip Invitation Accepted'), findsOneWidget);
        expect(find.text('View Group'), findsOneWidget);
      },
    );

    testWidgets(
      'Trip Invitation Decline shows Invitation Declined result screen',
      (WidgetTester tester) async {
        setPhoneViewport(tester);

        await tester.pumpWidget(
          buildTestableScreen(const NotificationsScreen(initialTabIndex: 1)),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Bantayan Trip').first);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Decline'));
        await tester.pumpAndSettle();

        expect(find.byType(InvitationResultScreen), findsOneWidget);
        expect(find.text('Invitation Declined'), findsOneWidget);
        expect(
          find.textContaining('Your response has been updated to Not Going.'),
          findsOneWidget,
        );
        expect(find.text('Back to Invitations'), findsOneWidget);
      },
    );
  });

  group('Component Unit & Widget Tests', () {
    testWidgets('MarkAllAsRead responds to tap and displays checkmark', (
      WidgetTester tester,
    ) async {
      bool checkedVal = false;
      await tester.pumpWidget(
        buildTestableScreen(
          Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => MarkAllAsRead(
                checked: checkedVal,
                onChanged: (val) => setState(() => checkedVal = val),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mark all as read'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsNothing);

      await tester.tap(find.byType(MarkAllAsRead));
      await tester.pumpAndSettle();

      expect(checkedVal, isTrue);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('InvitationFilter displays Filter label and triggers onTap', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestableScreen(
          Scaffold(
            body: InvitationFilter(
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Filter'), findsOneWidget);

      await tester.tap(find.byType(InvitationFilter));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}
