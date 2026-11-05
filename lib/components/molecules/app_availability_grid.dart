import 'package:flutter/material.dart';
import 'app_availability_pill.dart';

/// Three pairs of weekdays with Sunday centered at the same button width.
class AppAvailabilityGrid extends StatelessWidget {
  const AppAvailabilityGrid({
    super.key,
    required this.selectedDays,
    required this.onDayTap,
  });

  final Set<String> selectedDays;
  final ValueChanged<String> onDayTap;

  static const days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    Widget button(String day) => AppAvailabilityPill(
      day: day,
      isSelected: selectedDays.contains(day),
      onTap: () => onDayTap(day),
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 24) / 2;
            return Column(
              children: [
                for (var index = 0; index < 6; index += 2) ...[
                  Row(
                    children: [
                      Expanded(child: button(days[index])),
                      const SizedBox(width: 24),
                      Expanded(child: button(days[index + 1])),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
                SizedBox(width: width, child: button(days.last)),
              ],
            );
          },
        ),
      ),
    );
  }
}
