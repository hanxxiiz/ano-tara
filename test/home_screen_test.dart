import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anotara/screens/home_screen.dart';
import 'package:anotara/theme/app_theme.dart';
import 'package:anotara/widgets/home_placeholders.dart';

void main() {
  Widget buildTestableHomeScreen() {
    return MaterialApp(
      theme: buildAppTheme(),
      home: const HomeScreen(),
    );
  }

  testWidgets('HomeScreen renders all sections and placeholder components with correct typography',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestableHomeScreen());
    await tester.pumpAndSettle();

    // A. Topbar placeholder check
    expect(find.byType(TopbarPlaceholder), findsOneWidget);

    // B. Greeting section check (Urbanist Bold)
    final greetingFinder = find.textContaining('Good day,');
    expect(greetingFinder, findsOneWidget);
    final greetingText = tester.widget<Text>(greetingFinder);
    expect(greetingText.style?.fontFamily, AppFonts.urbanist);
    expect(greetingText.style?.fontWeight, FontWeight.bold);

    // C. Promotional banner:
    // - "Tara? Let's\nmake it happen" in Urbanist ExtraBold #0F0331
    final bannerHeadingFinder = find.text("Tara? Let's\nmake it happen");
    expect(bannerHeadingFinder, findsOneWidget);
    final bannerHeadingText = tester.widget<Text>(bannerHeadingFinder);
    expect(bannerHeadingText.style?.fontFamily, AppFonts.urbanist);
    expect(bannerHeadingText.style?.fontWeight, FontWeight.w800);
    expect(bannerHeadingText.style?.color, const Color(0xFF0F0331));

    // - "Get the group together and start planning what's next." in Open Sans Regular #0F0331
    final bannerDescFinder = find.text("Get the group together and start planning what's next.");
    expect(bannerDescFinder, findsOneWidget);
    final bannerDescText = tester.widget<Text>(bannerDescFinder);
    expect(bannerDescText.style?.fontFamily, AppFonts.openSans);
    expect(bannerDescText.style?.fontWeight, FontWeight.normal);
    expect(bannerDescText.style?.color, const Color(0xFF0F0331));

    // Button placeholder
    expect(find.byType(ButtonPlaceholder), findsOneWidget);
    expect(find.text('Plan a Trip'), findsOneWidget);

    // D. Groups section check (Urbanist Bold heading)
    final groupsHeadingFinder = find.text('Groups');
    expect(groupsHeadingFinder, findsOneWidget);
    final groupsHeadingText = tester.widget<Text>(groupsHeadingFinder);
    expect(groupsHeadingText.style?.fontFamily, AppFonts.urbanist);
    expect(groupsHeadingText.style?.fontWeight, FontWeight.bold);

    expect(find.byType(GroupsTilePlaceholder), findsNWidgets(4));
    expect(find.text('The Group'), findsWidgets);
    expect(find.text('Blackpink'), findsOneWidget);
    expect(find.text('Twice'), findsOneWidget);
    expect(find.text('Group 4'), findsOneWidget);

    // E. Upcoming Trips section check (Urbanist Bold heading)
    final upcomingTripsHeadingFinder = find.text('Upcoming Trips');
    expect(upcomingTripsHeadingFinder, findsOneWidget);
    final upcomingTripsHeadingText = tester.widget<Text>(upcomingTripsHeadingFinder);
    expect(upcomingTripsHeadingText.style?.fontFamily, AppFonts.urbanist);
    expect(upcomingTripsHeadingText.style?.fontWeight, FontWeight.bold);

    expect(find.byType(UpcomingTripsTilePlaceholder), findsWidgets);
    expect(find.text('Bantayan Trip'), findsOneWidget);
    expect(find.text('Bantayan, Philippines'), findsOneWidget);
    expect(find.text('The Group (6 going)'), findsOneWidget);
    expect(find.text('Oct 10 - Oct 15'), findsOneWidget);

    // F. Action Needed section check (Urbanist Bold heading)
    final actionNeededHeadingFinder = find.text('Action Needed');
    expect(actionNeededHeadingFinder, findsOneWidget);
    final actionNeededHeadingText = tester.widget<Text>(actionNeededHeadingFinder);
    expect(actionNeededHeadingText.style?.fontFamily, AppFonts.urbanist);
    expect(actionNeededHeadingText.style?.fontWeight, FontWeight.bold);

    expect(find.byType(ActionNeededTilePlaceholder), findsNWidgets(3));
    expect(find.text('Pending Invitations'), findsOneWidget);
    expect(find.text('Unsettled Expenses'), findsOneWidget);
    expect(find.text('Waiting for Responses'), findsOneWidget);

    // G. Navbar placeholder check
    expect(find.byType(NavbarPlaceholder), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Trips'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
