import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

/// Standard Neo-brutalist hard shadow used across Ano Tara trip cards.
const List<BoxShadow> kTripHardShadow = [
  BoxShadow(
    color: AppColors.secondaryDark,
    offset: Offset(0, 4),
    blurRadius: 0,
  ),
];

/// Subtle hard shadow for smaller buttons/pills.
const List<BoxShadow> kTripSmallHardShadow = [
  BoxShadow(
    color: AppColors.secondaryDark,
    offset: Offset(0, 2.5),
    blurRadius: 0,
  ),
];

/// Top bar matching Figma 11.02–11.16 with back arrow, bold title, optional
/// trailing action, and crisp 1.5px dark ink bottom divider.
class TripSubTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  const TripSubTopBar({
    super.key,
    required this.title,
    this.actions,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.secondaryDark,
            width: 1.5,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(
                  Iconsax.arrow_left,
                  color: AppColors.secondaryDark,
                  size: 22,
                ),
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: Text(
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
              ...?actions,
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// Day stepper header matching Figma 11.02, 11.05, 11.11, 11.14:
/// `[<]   Day X of Y / Date subtitle   [>]` + segmented progress pills.
class TripDayStepperHeader extends StatelessWidget {
  final int currentDay;
  final int totalDays;
  final String dateSubtitle;
  final ValueChanged<int> onDayChanged;

  const TripDayStepperHeader({
    super.key,
    required this.currentDay,
    required this.totalDays,
    required this.dateSubtitle,
    required this.onDayChanged,
  });

  @override
  Widget build(BuildContext context) {
    final canGoBack = currentDay > 1;
    final canGoForward = currentDay < totalDays;

    return Column(
      children: [
        Row(
          children: [
            _StepArrowButton(
              icon: Icons.chevron_left_rounded,
              enabled: canGoBack,
              onTap: canGoBack ? () => onDayChanged(currentDay - 1) : null,
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Day $currentDay of $totalDays',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.secondaryDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateSubtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.shayne,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            _StepArrowButton(
              icon: Icons.chevron_right_rounded,
              enabled: canGoForward,
              onTap: canGoForward ? () => onDayChanged(currentDay + 1) : null,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalDays, (index) {
            final isActive = (index + 1) == currentDay;
            return GestureDetector(
              onTap: () => onDayChanged(index + 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 48,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.secondaryDark
                      : const Color(0xFFE8E6E3),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.secondaryDark,
                    width: 1.2,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _StepArrowButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  const _StepArrowButton({
    required this.icon,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.45,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.secondaryLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.secondaryDark,
              width: 1.8,
            ),
            boxShadow: kTripSmallHardShadow,
          ),
          child: Center(
            child: Icon(
              icon,
              color: AppColors.secondaryDark,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

/// Dashed circular icon container matching Figma summary cards (11.01, 11.06, 11.07, 11.15, 11.16).
class DashedCircleIconBadge extends StatelessWidget {
  final Widget child;
  final double size;
  final Color dashColor;

  const DashedCircleIconBadge({
    super.key,
    required this.child,
    this.size = 54,
    this.dashColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedCirclePainter(color: dashColor),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(child: child),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;

  const _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final radius = (math.min(size.width, size.height) / 2) - 1;
    final center = Offset(size.width / 2, size.height / 2);
    const dashCount = 16;
    const sweepAngle = (2 * math.pi) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sweepAngle,
        sweepAngle * 0.55,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Dashed horizontal divider used inside the Navy Completed Trip Day card (11.01).
class DashedDivider extends StatelessWidget {
  final Color color;
  final double height;

  const DashedDivider({
    super.key,
    this.color = AppColors.white,
    this.height = 1.2,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 5.0;
        const dashSpace = 5.0;
        final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count.clamp(1, 200),
            (_) => Container(
              width: dashWidth,
              height: height,
              color: color.withValues(alpha: 0.65),
            ),
          ),
        );
      },
    );
  }
}

/// Overlapping circular member initials cluster matching Figma 11.01 & 11.10
/// (Yellow, Orange, Navy, Light-Gray with dark ink border + "+3").
class TripInitialsAvatarStack extends StatelessWidget {
  final List<String> initials;
  final int extraCount;
  final double size;

  const TripInitialsAvatarStack({
    super.key,
    required this.initials,
    this.extraCount = 0,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    const palette = [
      AppColors.semanticYellow,
      AppColors.primaryOrange,
      AppColors.primaryNavy,
      Color(0xFFDDE3EE),
    ];
    const textColors = [
      AppColors.secondaryDark,
      AppColors.secondaryDark,
      AppColors.secondaryDark,
      AppColors.secondaryDark,
    ];

    final step = size * 0.68;
    final stackWidth = size + (initials.length - 1) * step;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: stackWidth,
          height: size,
          child: Stack(
            children: [
              for (int i = 0; i < initials.length; i++)
                Positioned(
                  left: i * step,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: palette[i % palette.length],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.secondaryDark,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initials[i],
                        style: TextStyle(
                          fontSize: size * 0.36,
                          fontWeight: FontWeight.w800,
                          color: textColors[i % textColors.length],
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (extraCount > 0) ...[
          const SizedBox(width: 4),
          Text(
            '+$extraCount',
            style: AppTypography.caption.copyWith(
              color: AppColors.secondaryDark,
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
            ),
          ),
        ],
      ],
    );
  }
}

/// Rounded square close ("X") button matching the Ano Tara modal sheets.
class TripModalCloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const TripModalCloseButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.secondaryDark,
            width: 1.8,
          ),
          boxShadow: kTripSmallHardShadow,
        ),
        child: const Center(
          child: Icon(
            Icons.close_rounded,
            color: AppColors.secondaryDark,
            size: 18,
          ),
        ),
      ),
    );
  }
}
