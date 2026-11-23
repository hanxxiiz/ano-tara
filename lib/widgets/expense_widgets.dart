import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../app_routes.dart';
import '../components/atoms/app_button.dart';
import '../components/organisms/app_bottom_navigation.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';

/// Shared bottom navigation bar pinned to the "Trips" tab (index 1)
/// across all expense screens.
class ExpensesBottomNav extends StatelessWidget {
  const ExpensesBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBottomNavigation(
      currentIndex: 1, // Always stays on "Trips" in expense screens
      onTabSelected: (index) {
        if (index == 1) return;
        if (index == 0) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          return;
        }
        if (index == 3) {
          Navigator.of(context).pushNamed(AppRoutes.messages);
          return;
        }
        const destinations = ['Home', 'Trips', 'Create trip', 'Groups', 'Profile'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${destinations[index]} tapped')),
        );
      },
    );
  }
}

/// Top bar matching the Figma expense screens: white background, back arrow,
/// bold dark title, optional trailing widget, and a crisp 1.2px ink divider.
class ExpenseTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? leading;
  final Widget? titleWidget;
  final List<Widget>? actions;

  const ExpenseTopBar({
    super.key,
    required this.title,
    this.onBack,
    this.leading,
    this.titleWidget,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(58.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    leading ??
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.secondaryDark,
                            size: 22,
                          ),
                          onPressed:
                              onBack ?? () => Navigator.of(context).maybePop(),
                          splashRadius: 22,
                        ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: titleWidget ??
                          Text(
                            title,
                            style: AppTypography.h4.copyWith(
                              color: AppColors.secondaryDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 19,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                    ),
                    if (actions != null) ...[
                      ...actions!,
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
            ),
            const Divider(
              height: 1.2,
              thickness: 1.2,
              color: AppColors.secondaryDark,
            ),
          ],
        ),
      ),
    );
  }
}

/// Rounded square hard-shadow icon button (used for `<`, `>`, and `×` close).
class HardShadowSquareButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final double iconSize;
  final bool muted;

  const HardShadowSquareButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.backgroundColor = AppColors.secondaryLight,
    this.iconColor = AppColors.secondaryDark,
    this.size = 38,
    this.iconSize = 20,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = muted ? AppColors.shayne : AppColors.secondaryDark;
    return GestureDetector(
      onTap: muted ? null : onTap,
      child: Opacity(
        opacity: muted ? 0.55 : 1.0,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 1.8),
            boxShadow: [
              BoxShadow(
                color: borderColor,
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Icon(icon, size: iconSize, color: iconColor),
        ),
      ),
    );
  }
}

/// Dashed-border "+ Add Expense" button matching Figma 10.02.
class DashedAddExpenseButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;

  const DashedAddExpenseButton({
    super.key,
    required this.onTap,
    this.label = 'Add Expense',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedRoundedRectPainter(
          color: AppColors.shayne,
          strokeWidth: 1.6,
          radius: 14,
          dashWidth: 6,
          dashSpace: 4,
        ),
        child: Container(
          height: 54,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.secondaryLight.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, color: AppColors.carla, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.buttonMedium.copyWith(
                  color: AppColors.carla,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRoundedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  const _DashedRoundedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = math.min(distance + dashWidth, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius;
  }
}

/// Orange hexagon exclamation badge matching Figma 10.11 & 10.12.
class HexagonAlertBadge extends StatelessWidget {
  final Color color;
  final IconData icon;
  final double size;

  const HexagonAlertBadge({
    super.key,
    this.color = AppColors.primaryOrange,
    this.icon = Icons.priority_high_rounded,
    this.size = 76,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _HexagonPainter(color: color),
          ),
          Icon(icon, color: AppColors.white, size: size * 0.48),
        ],
      ),
    );
  }
}

class _HexagonPainter extends CustomPainter {
  final Color color;
  const _HexagonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.46;

    final points = <Offset>[];
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 2;
      points.add(Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)));
    }

    final path = Path();
    const cornerRatio = 0.2;
    for (int i = 0; i < 6; i++) {
      final prev = points[(i + 5) % 6];
      final curr = points[i];
      final next = points[(i + 1) % 6];
      final start = Offset.lerp(curr, prev, cornerRatio)!;
      final end = Offset.lerp(curr, next, cornerRatio)!;
      if (i == 0) {
        path.moveTo(start.dx, start.dy);
      } else {
        path.lineTo(start.dx, start.dy);
      }
      path.quadraticBezierTo(curr.dx, curr.dy, end.dx, end.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HexagonPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Shows the Delete Expense (single, 10.12) or Delete Expenses (multiple, 10.11)
/// confirmation bottom sheet matching Figma.
Future<bool> showDeleteExpenseSheet(
  BuildContext context, {
  required int count,
  String? singleExpenseName,
}) async {
  final isMultiple = count > 1;
  final title = isMultiple ? 'Delete Expenses' : 'Delete Expense';
  final description = isMultiple
      ? 'The selected expenses will be permanently removed from this trip, including their individual split details. This action cannot be undone.'
      : '${singleExpenseName ?? 'This expense'} will be permanently removed from this trip, including its associated split details. This action cannot be undone.';

  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: AppColors.secondaryDark, width: 2),
            left: BorderSide(color: AppColors.secondaryDark, width: 2),
            right: BorderSide(color: AppColors.secondaryDark, width: 2),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.secondaryDark,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 8),
              // Close button aligned right
              Align(
                alignment: Alignment.centerRight,
                child: HardShadowSquareButton(
                  icon: Icons.close_rounded,
                  backgroundColor: AppColors.white,
                  size: 36,
                  iconSize: 20,
                  onTap: () => Navigator.of(sheetContext).pop(false),
                ),
              ),
              const HexagonAlertBadge(),
              const SizedBox(height: 14),
              Text(
                title,
                style: AppTypography.h2.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.shayne,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Delete',
                variant: AppButtonVariant.primaryOrange,
                borderRadius: 16,
                onPressed: () => Navigator.of(sheetContext).pop(true),
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'Cancel',
                variant: AppButtonVariant.secondary,
                borderRadius: 16,
                onPressed: () => Navigator.of(sheetContext).pop(false),
              ),
            ],
          ),
        ),
      );
    },
  );
  return result == true;
}

/// Shows the Mark as Settled confirmation dialog matching the Ano Tara sheet style.
Future<bool> showMarkAsSettledDialog(
  BuildContext context, {
  required String memberName,
  required String amountLabel,
  required String expenseTitle,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: AppColors.secondaryDark, width: 2),
            left: BorderSide(color: AppColors.secondaryDark, width: 2),
            right: BorderSide(color: AppColors.secondaryDark, width: 2),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.secondaryDark,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: HardShadowSquareButton(
                  icon: Icons.close_rounded,
                  backgroundColor: AppColors.white,
                  size: 36,
                  iconSize: 20,
                  onTap: () => Navigator.of(sheetContext).pop(false),
                ),
              ),
              const HexagonAlertBadge(
                color: AppColors.primaryNavy,
                icon: Icons.check_rounded,
              ),
              const SizedBox(height: 14),
              Text(
                'Mark as Settled',
                style: AppTypography.h2.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Confirm that $memberName has paid their $amountLabel share for $expenseTitle?',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.shayne,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Mark as Settled',
                variant: AppButtonVariant.primaryNavy,
                borderRadius: 16,
                onPressed: () => Navigator.of(sheetContext).pop(true),
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'Cancel',
                variant: AppButtonVariant.secondary,
                borderRadius: 16,
                onPressed: () => Navigator.of(sheetContext).pop(false),
              ),
            ],
          ),
        ),
      );
    },
  );
  return result == true;
}
