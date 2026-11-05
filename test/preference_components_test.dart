import 'package:anotara/components/molecules/app_availability_grid.dart';
import 'package:anotara/core/constants/app_preference_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Preference SVG assets are bundled and decode', (tester) async {
    for (final path in AppPreferenceIcons.assets.values.toSet()) {
      final data = await rootBundle.loadString(path);
      await vg.loadPicture(SvgStringLoader(data), null);
    }
  });

  testWidgets('Availability pairs days and centers Sunday on narrow screens', (
    tester,
  ) async {
    String? tapped;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 280,
            child: AppAvailabilityGrid(
              selectedDays: const {'Monday'},
              onDayTap: (day) => tapped = day,
            ),
          ),
        ),
      ),
    ));
    final monday = tester.getCenter(find.text('Monday'));
    final tuesday = tester.getCenter(find.text('Tuesday'));
    final sunday = tester.getCenter(find.text('Sunday'));
    expect(monday.dy, tuesday.dy);
    expect(sunday.dx, (monday.dx + tuesday.dx) / 2);
    expect(sunday.dy, greaterThan(tester.getCenter(find.text('Saturday')).dy));
    await tester.tap(find.text('Sunday'));
    await tester.pumpAndSettle();
    expect(tapped, 'Sunday');
    expect(tester.takeException(), isNull);
  });
}
