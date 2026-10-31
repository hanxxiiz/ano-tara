import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../models/trip.dart';
import '../theme/app_theme.dart';

/// Colors used only by the trips screens (from the Figma exports).
class TripColors {
  TripColors._();

  static const yellow = Color(0xFFF9CF09);
  static const chip = Color(0xFF89A3C1);
  static const lightNavy = Color(0xFFC4D1E0);
  static const purple = Color(0xFF4B4265);
  static const navIdle = Color(0xFF868097);
  static const expenseChip = Color(0xFFF0A492);
  static const avatar = Color(0xFFFFBD12);
}

// ---------------------------------------------------------------------------
// Formatting

const _monthsShort = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Uppercase labels used on the itinerary date tabs ("SEPT" in the design).
const _monthsTab = [
  'JAN',
  'FEB',
  'MAR',
  'APR',
  'MAY',
  'JUNE',
  'JULY',
  'AUG',
  'SEPT',
  'OCT',
  'NOV',
  'DEC',
];

String formatShortDate(DateTime d) => '${_monthsShort[d.month - 1]} ${d.day}';

String formatTabMonth(DateTime d) => _monthsTab[d.month - 1];

String formatDateRange(DateTime start, DateTime end) =>
    '${formatShortDate(start)} - ${formatShortDate(end)}';

String formatTime(DateTime t) {
  final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final minute = t.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${t.hour < 12 ? 'AM' : 'PM'}';
}

String formatTimeRange(DateTime start, DateTime end) =>
    '${formatTime(start)} - ${formatTime(end)}';

// ---------------------------------------------------------------------------
// Building blocks

/// White (or [color]) box with a 2px ink border and the flat offset shadow
/// used throughout the designs.
class OutlinedCard extends StatelessWidget {
  const OutlinedCard({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.radius = 15,
    this.onTap,
    this.padding,
  });

  final Widget child;
  final Color color;
  final double radius;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: const [
          BoxShadow(color: AppColors.ink, offset: Offset(0, 4)),
        ],
      ),
      child: Material(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: const BorderSide(color: AppColors.ink, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
        ),
      ),
    );
  }
}

/// Icon + label line ("📍 Bantayan, Philippines").
class IconLabel extends StatelessWidget {
  const IconLabel({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor = AppColors.navy,
    this.fontSize = 11,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: fontSize + 3, color: iconColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: fontSize, color: AppColors.ink),
          ),
        ),
      ],
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
    );
  }
}

/// White top bar on the main tabs: avatar on the left, bell and settings on
/// the right, hairline underneath.
class TripsTopBar extends StatelessWidget implements PreferredSizeWidget {
  const TripsTopBar({super.key, this.leading});

  /// Replaces the avatar (e.g. with a back button).
  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.black)),
        ),
        child: Row(
          children: [
            leading ??
                const Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.ink,
                  ),
                ),
            const Spacer(),
            IconButton(
              tooltip: 'Notifications',
              onPressed: () => showComingSoon(context, 'Notifications'),
              icon: const Icon(
                Icons.notifications_rounded,
                color: AppColors.ink,
              ),
            ),
            IconButton(
              tooltip: 'Settings',
              onPressed: () => showComingSoon(context, 'Settings'),
              icon: const Icon(Icons.settings_rounded, color: AppColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}

class TitleBar extends StatelessWidget implements PreferredSizeWidget {
  const TitleBar({super.key, required this.title, this.onAdd});

  final String title;

  /// Shows the light-navy "+ Add" button when set.
  final VoidCallback? onAdd;

  @override
  Size get preferredSize => const Size.fromHeight(62);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 62,
        padding: const EdgeInsets.only(left: 4, right: 9),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.black)),
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
            ),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
            if (onAdd != null)
              OutlinedCard(
                color: TripColors.lightNavy,
                radius: 12,
                onTap: onAdd,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 18, color: AppColors.ink),
                    SizedBox(width: 6),
                    Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
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

/// Yellow strip of day buttons; the selected day sits in a red circle.
class DateTabStrip extends StatelessWidget {
  const DateTabStrip({
    super.key,
    required this.days,
    required this.selected,
    required this.onSelected,
  });

  final List<DateTime> days;
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    return OutlinedCard(
      color: TripColors.yellow,
      radius: 12,
      child: SizedBox(
        height: 66,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Five days fit the card width like the design; more scroll.
            final tabWidth =
                constraints.maxWidth / (days.length < 5 ? days.length : 5);
            return ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final day in days)
                  SizedBox(
                    width: tabWidth,
                    child: _DateTab(
                      day: day,
                      selected: day == selected,
                      onTap: () => onSelected(day),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DateTab extends StatelessWidget {
  const _DateTab({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: formatShortDate(day),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ExcludeSemantics(
              child: Text(
                formatTabMonth(day),
                style: const TextStyle(fontSize: 11, color: AppColors.ink),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.accent : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: ExcludeSemantics(
                child: Text(
                  '${day.day}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showComingSoon(BuildContext context, String feature) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('$feature is coming soon.')));
}

enum AppTab { home, trips, groups, profile }

/// Home / Trips / (+) / Groups / Profile. The center button plans a trip.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.current,
    required this.onTabSelected,
    required this.onPlanTrip,
  });

  final AppTab current;
  final ValueChanged<AppTab> onTabSelected;
  final VoidCallback onPlanTrip;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 78,
          child: Row(
            children: [
              _tab(AppTab.home, Icons.home_rounded, 'Home'),
              _tab(AppTab.trips, Icons.send_rounded, 'Trips'),
              Expanded(
                child: Center(
                  child: Semantics(
                    button: true,
                    label: 'Plan a trip',
                    child: InkResponse(
                      onTap: onPlanTrip,
                      radius: 28,
                      child: const Icon(
                        Icons.add_circle_rounded,
                        size: 46,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ),
              ),
              _tab(AppTab.groups, Icons.groups_rounded, 'Groups'),
              _tab(AppTab.profile, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(AppTab tab, IconData icon, String label) {
    final selected = tab == current;
    final color = selected ? AppColors.navy : TripColors.navIdle;
    return Expanded(
      child: InkResponse(
        onTap: () => onTabSelected(tab),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small rounded pill on top of an activity card ("Food", "Check-in").
class CategoryChip extends StatelessWidget {
  const CategoryChip(this.label, {super.key, this.color = TripColors.chip});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          fontStyle: FontStyle.italic,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Itinerary entry: navy thumbnail, category chip, title, place, time.
class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key, required this.item, this.onTap});

  final ItineraryItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 81,
            height: 81,
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.category.icon, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoryChip(item.category.label),
                const SizedBox(height: 6),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                IconLabel(
                  icon: Icons.location_on_rounded,
                  label: item.location,
                ),
                const SizedBox(height: 4),
                IconLabel(
                  icon: Icons.timer_rounded,
                  label: formatTimeRange(item.start, item.end),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.ink),
        ],
      ),
    );
  }
}

/// Empty-state message in the same card style.
class EmptyCard extends StatelessWidget {
  const EmptyCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return OutlinedCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: TripColors.navIdle),
        ),
      ),
    );
  }
}

/// Full-width navy button with the hard shadow ("Add Expense", "Continue").
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.trailing,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? trailing;

  /// Shows a spinner in place of the label (and ignores taps).
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null || busy;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: OutlinedCard(
        color: AppColors.navy,
        radius: 16,
        onTap: busy ? null : onPressed,
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (busy)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              if (trailing != null && !busy) ...[
                const SizedBox(width: 12),
                Icon(trailing, color: Colors.white, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-width grey button ("Cancel", "View Expenses").
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedCard(
      color: AppColors.field,
      radius: 16,
      onTap: onPressed,
      child: SizedBox(
        height: 50,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

/// Yellow circle with a person icon, used for trip members.
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({
    super.key,
    this.size = 44,
    this.color = TripColors.yellow,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(Icons.person_rounded, color: Colors.white, size: size * 0.5),
    );
  }
}

/// Expense entry: red thumbnail, category chip, title, amount, payer.
class ExpenseCard extends StatelessWidget {
  const ExpenseCard({
    super.key,
    required this.expense,
    required this.payerName,
    this.onTap,
  });

  final Expense expense;
  final String payerName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 81,
            height: 81,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(expense.category.icon, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoryChip(
                  expense.category.label,
                  color: TripColors.expenseChip,
                ),
                const SizedBox(height: 6),
                Text(
                  expense.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                IconLabel(
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: AppColors.accent,
                  label: formatPeso(expense.amountCents),
                ),
                const SizedBox(height: 4),
                IconLabel(
                  icon: Icons.person_rounded,
                  iconColor: AppColors.accent,
                  label: 'Paid by: $payerName',
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.ink),
        ],
      ),
    );
  }
}

/// Loading placeholder in the card style.
class LoadingCard extends StatelessWidget {
  const LoadingCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return OutlinedCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: TripColors.navIdle),
          ),
        ],
      ),
    );
  }
}

/// Error message with a Try again button.
class ErrorCard extends StatelessWidget {
  const ErrorCard({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return OutlinedCard(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.accent,
            size: 32,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.ink),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Try again',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
