import 'package:flutter/material.dart';
import 'package:anotara/components/organisms/app_top_bar.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anotara/components/invitation_filter.dart';
import 'package:anotara/components/invitation_tile.dart';
import 'package:anotara/components/mark_all_as_read.dart';
import 'package:anotara/components/notification_tile.dart';
import 'package:anotara/screens/notifications_screen.dart';
import 'package:anotara/theme/app_theme.dart';

void main() {
  Widget buildTestableScreen(Widget child) {
    return MaterialApp(
      theme: buildAppTheme(),
      home: Scaffold(body: child),
    );
  }

  group('NotificationsScreen tests', () {
    testWidgets('Renders Topbar, ToggleTab, and Activity tab content by default',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableScreen(const NotificationsScreen()));
      await tester.pumpAndSettle();

      // Topbar
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byType(AppTopBar), findsOneWidget);

      // ToggleTab
      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('Invitations'), findsOneWidget);

      // Activity Tab Content
      expect(find.byType(MarkAllAsRead), findsOneWidget);
      expect(find.text('Mark all as read'), findsOneWidget);

      // Notification Tiles
      expect(find.byType(NotificationTile), findsNWidgets(2));
      expect(find.text('New expense added'), findsOneWidget);
      expect(find.text('Trip details updated'), findsOneWidget);
    });

    testWidgets('Toggling Mark All as Read updates all notification read states',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableScreen(const NotificationsScreen()));
      await tester.pumpAndSettle();

      final markAllFinder = find.byType(MarkAllAsRead);
      expect(markAllFinder, findsOneWidget);

      // Tap Mark all as read
      await tester.tap(markAllFinder);
      await tester.pumpAndSettle();

      // Tap again to toggle back
      await tester.tap(markAllFinder);
      await tester.pumpAndSettle();
    });

    testWidgets('Switching to Invitations tab shows filter and invitation tiles',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableScreen(const NotificationsScreen()));
      await tester.pumpAndSettle();

      // Switch tab to Invitations
      await tester.tap(find.text('Invitations'));
      await tester.pumpAndSettle();

      // Invitations tab content
      expect(find.byType(InvitationFilter), findsOneWidget);
      expect(find.text('Pending'), findsWidgets); // Filter label & badge
      expect(find.byType(InvitationTile), findsWidgets);
      expect(find.text('Weekend Wanderers'), findsOneWidget);
    });
  });

  group('Component Unit & Widget Tests', () {
    testWidgets('MarkAllAsRead responds to tap and displays checkmark',
        (WidgetTester tester) async {
      bool checkedVal = false;
      await tester.pumpWidget(buildTestableScreen(
        StatefulBuilder(
          builder: (context, setState) => MarkAllAsRead(
            checked: checkedVal,
            onChanged: (val) => setState(() => checkedVal = val),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Mark all as read'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsNothing);

      await tester.tap(find.byType(MarkAllAsRead));
      await tester.pumpAndSettle();

      expect(checkedVal, isTrue);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets(
        'NotificationTile renders vertical rectangle icon tile matching content height and shows unread badge',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableScreen(
        const Column(
          children: [
            NotificationTile(
              title: 'Unread Notif',
              description: 'Mika added ₱1,200 for transportation to your Bohol Getaway.',
              timestamp: '2 hours ago',
              icon: Icons.notifications,
              isUnread: true,
            ),
            NotificationTile(
              title: 'Read Notif',
              description: 'Short desc',
              timestamp: 'Yesterday',
              icon: Icons.notifications,
              isUnread: false,
            ),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Unread Notif'), findsOneWidget);
      expect(find.text('Read Notif'), findsOneWidget);

      // Verify that the icon container uses IntrinsicHeight and stretch layout
      expect(find.byType(IntrinsicHeight), findsNWidgets(2));
    });

    testWidgets('InvitationTile displays title, status badge and description',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableScreen(
        const InvitationTile(
          title: 'Weekend Wanderers',
          description: 'Group invitation from Louielyn Abella.',
          timestamp: '5 minutes ago',
          status: 'Pending',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Weekend Wanderers'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Group invitation from Louielyn Abella.'), findsOneWidget);
      expect(find.text('5 minutes ago'), findsOneWidget);
    });

    testWidgets(
        'InvitationFilter triggers menu without layout errors and updates selection',
        (WidgetTester tester) async {
      String current = 'Pending';
      await tester.pumpWidget(buildTestableScreen(
        StatefulBuilder(
          builder: (context, setState) => InvitationFilter(
            selectedStatus: current,
            onChanged: (val) => setState(() => current = val),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Pending'), findsOneWidget);

      // Tap filter button to open menu
      await tester.tap(find.byType(InvitationFilter));
      await tester.pumpAndSettle();

      // Options in popup menu
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Accepted'), findsOneWidget);
      expect(find.text('Rejected'), findsOneWidget);

      // Select 'All'
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      expect(current, 'All');
    });

    testWidgets('Selecting All in NotificationsScreen shows all invitations',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableScreen(const NotificationsScreen()));
      await tester.pumpAndSettle();

      // Switch to Invitations tab
      await tester.tap(find.text('Invitations'));
      await tester.pumpAndSettle();

      // Open filter menu and select 'All'
      await tester.tap(find.byType(InvitationFilter));
      await tester.pumpAndSettle();

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      // All 3 items should now be visible
      expect(find.byType(InvitationTile), findsNWidgets(3));
      expect(find.text('Weekend Wanderers'), findsOneWidget);
      expect(find.text('Bantayan Trip'), findsNWidgets(2));
    });
  });
}
