import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/constants/app_colors.dart';
import '../../theme/app_theme.dart' show AppFonts;
import '../atoms/app_icon.dart';

/// Navy blue summary card at the top of the View Trip Members screen.
/// Matches Figma "07.07 · Trip participants — invitation responses.png".
class TripMembersSummaryCard extends StatefulWidget {
  final int respondedCount;
  final int totalCount;
  final int goingCount;
  final int notGoingCount;
  final int pendingCount;
  final VoidCallback onNudgeMembersTap;

  const TripMembersSummaryCard({
    super.key,
    required this.respondedCount,
    required this.totalCount,
    required this.goingCount,
    required this.notGoingCount,
    required this.pendingCount,
    required this.onNudgeMembersTap,
  });

  @override
  State<TripMembersSummaryCard> createState() => _TripMembersSummaryCardState();
}

class _TripMembersSummaryCardState extends State<TripMembersSummaryCard> {
  bool _isNudgePressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.secondaryDark,
          width: 2.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.secondaryDark,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: responded count + dashed circular group icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${widget.respondedCount}',
                          style: const TextStyle(
                            fontFamily: AppFonts.urbanist,
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            color: AppColors.semanticYellow,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'of ${widget.totalCount}',
                          style: const TextStyle(
                            fontFamily: AppFonts.urbanist,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'members have responded',
                      style: TextStyle(
                        fontFamily: AppFonts.openSans,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white.withValues(alpha: 0.92),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const _DashedGroupBadge(),
            ],
          ),
          const SizedBox(height: 18),

          // Middle row: Going | Not Going | Pending
          Row(
            children: [
              Expanded(
                child: _StatColumn(
                  label: 'Going',
                  count: widget.goingCount,
                  valueColor: AppColors.white,
                ),
              ),
              Container(
                width: 1,
                height: 44,
                color: AppColors.white.withValues(alpha: 0.35),
              ),
              Expanded(
                child: _StatColumn(
                  label: 'Not Going',
                  count: widget.notGoingCount,
                  valueColor: AppColors.white,
                ),
              ),
              Container(
                width: 1,
                height: 44,
                color: AppColors.white.withValues(alpha: 0.35),
              ),
              Expanded(
                child: _StatColumn(
                  label: 'Pending',
                  count: widget.pendingCount,
                  valueColor: AppColors.semanticYellow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Bottom CTA button: Nudge Members
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => setState(() => _isNudgePressed = true),
            onTapCancel: () => setState(() => _isNudgePressed = false),
            onTapUp: (_) {
              setState(() => _isNudgePressed = false);
              widget.onNudgeMembersTap();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: _isNudgePressed
                    ? const Color(0xFFD6D3CE)
                    : AppColors.secondaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.secondaryDark,
                  width: 1.8,
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Nudge Members',
                style: TextStyle(
                  fontFamily: AppFonts.urbanist,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondaryDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final int count;
  final Color valueColor;

  const _StatColumn({
    required this.label,
    required this.count,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.openSans,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.white.withValues(alpha: 0.92),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: TextStyle(
            fontFamily: AppFonts.urbanist,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: valueColor,
            height: 1.05,
          ),
        ),
      ],
    );
  }
}

class _DashedGroupBadge extends StatelessWidget {
  const _DashedGroupBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: CustomPaint(
        painter: _DashedCirclePainter(
          color: AppColors.white.withValues(alpha: 0.85),
          strokeWidth: 1.6,
          dashCount: 16,
        ),
        child: const Center(
          child: AppIcon(
            Iconsax.profile_2user5,
            color: AppColors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashCount;

  const _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );

    final step = (2 * math.pi) / dashCount;
    final sweep = step * 0.52;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(rect, i * step, sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashCount != dashCount;
}
