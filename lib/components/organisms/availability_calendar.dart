import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/group_models.dart';
import '../atoms/app_avatar.dart';

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// How one day cell is painted.
class AvailabilityDayStyle {
  final Color fill;
  final bool outlined;
  final Color textColor;

  const AvailabilityDayStyle({
    required this.fill,
    this.outlined = false,
    this.textColor = AppColors.white,
  });

  static const empty = AvailabilityDayStyle(
    fill: AppColors.calendarEmpty,
    textColor: AppColors.slate,
  );

  /// Heat-map shade for how much of the group is free (05.04).
  static AvailabilityDayStyle heat(int available, int total) {
    if (available == 0 || total == 0) return empty;
    final ratio = available / total;
    final alpha = ratio >= 0.8 ? 1.0 : (ratio >= 0.5 ? 0.75 : 0.5);
    return AvailabilityDayStyle(
      fill: AppColors.primaryOrange.withValues(alpha: alpha),
    );
  }
}

/// Navy month pill with previous / next arrows (05.04, 05.13).
class AvailabilityMonthNav extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const AvailabilityMonthNav({
    super.key,
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final name = _monthNames[month.month - 1];
    final label = month.year == DateTime.now().year
        ? name
        : '$name ${month.year}';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: '$name ${month.year}',
          excludeSemantics: true,
          child: Container(
            height: 30,
            constraints: const BoxConstraints(minWidth: 80),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryNavy,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.secondaryDark),
            ),
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        _ArrowButton(
          icon: Iconsax.arrow_left_2,
          label: 'Previous month',
          onTap: onPrevious,
        ),
        _ArrowButton(
          icon: Iconsax.arrow_right_3,
          label: 'Next month',
          onTap: onNext,
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ArrowButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      container: true,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 44,
          child: Center(
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.secondaryLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.shayne),
              ),
              child: Icon(icon, size: 16, color: AppColors.shayne),
            ),
          ),
        ),
      ),
    );
  }
}

/// Month grid (Mon–Sun) of rounded day cells inside an inked card.
/// Days outside [month] are left blank.
class AvailabilityCalendar extends StatelessWidget {
  final DateTime month;
  final AvailabilityDayStyle Function(DateTime day) dayStyle;
  final ValueChanged<DateTime>? onDayTap;

  /// Extra screen-reader text per day, e.g. "4 of 6 available".
  final String Function(DateTime day)? dayLabel;

  const AvailabilityCalendar({
    super.key,
    required this.month,
    required this.dayStyle,
    this.onDayTap,
    this.dayLabel,
  });

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const double _gap = 3;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month);
    final leading = first.weekday - DateTime.monday;
    final days = daysInMonth(month);
    final rows = ((leading + days) / 7).ceil();

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.secondaryDark, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.secondaryDark,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cell = (constraints.maxWidth - _gap * 6) / 7;
          return Column(
            children: [
              Row(
                children: [
                  for (var i = 0; i < 7; i++) ...[
                    if (i > 0) const SizedBox(width: _gap),
                    SizedBox(
                      width: cell,
                      child: Text(
                        _weekdays[i],
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.secondaryDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              for (var r = 0; r < rows; r++) ...[
                if (r > 0) const SizedBox(height: _gap),
                Row(
                  children: [
                    for (var c = 0; c < 7; c++) ...[
                      if (c > 0) const SizedBox(width: _gap),
                      _buildCell(r * 7 + c - leading + 1, days, cell),
                    ],
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildCell(int dayNumber, int days, double size) {
    if (dayNumber < 1 || dayNumber > days) {
      return SizedBox(width: size, height: size);
    }
    final day = DateTime(month.year, month.month, dayNumber);
    final style = dayStyle(day);
    final extra = dayLabel?.call(day);

    return Semantics(
      container: true,
      button: onDayTap != null,
      selected: style.outlined,
      label:
          '${_monthNames[month.month - 1]} $dayNumber'
          '${extra == null ? '' : ', $extra'}',
      excludeSemantics: true,
      onTap: onDayTap == null ? null : () => onDayTap!(day),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onDayTap == null ? null : () => onDayTap!(day),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: style.fill,
            borderRadius: BorderRadius.circular(5),
            border: style.outlined
                ? Border.all(color: AppColors.secondaryDark, width: 2)
                : null,
          ),
          child: Text(
            '$dayNumber',
            style: AppTypography.titleMedium.copyWith(
              color: style.textColor,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

/// "Best Dates" row: orange date block + who is available (05.04).
class BestDateCard extends StatelessWidget {
  final DateTime date;
  final List<String> availableNames;
  final int totalMembers;

  const BestDateCard({
    super.key,
    required this.date,
    required this.availableNames,
    required this.totalMembers,
  });

  @override
  Widget build(BuildContext context) {
    final monthAbbr = _monthNames[date.month - 1].substring(0, 3).toUpperCase();

    return Semantics(
      label:
          '${_monthNames[date.month - 1]} ${date.day}, '
          '${availableNames.length} of $totalMembers available',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.secondaryDark, width: 2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.secondaryDark,
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    monthAbbr,
                    style: AppTypography.badge.copyWith(
                      color: AppColors.white,
                      fontSize: 10,
                      letterSpacing: 0,
                    ),
                  ),
                  Text(
                    date.day.toString().padLeft(2, '0'),
                    style: AppTypography.h1.copyWith(
                      color: AppColors.white,
                      fontSize: 30,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.secondaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: AppInitialsTokenRow(
                      names: availableNames,
                      maxVisible: 5,
                      size: 29,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
