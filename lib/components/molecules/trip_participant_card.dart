import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/trip_participant.dart';
import '../../theme/app_theme.dart' show AppFonts;
import '../atoms/app_avatar.dart';

/// Card representing a trip participant and their invitation response status.
/// Matches Figma "07.07 · Trip participants — invitation responses.png".
///
/// The remove icon button is rendered only when [canRemove] is `true`
/// (Organizer only).
class TripParticipantCard extends StatelessWidget {
  final TripParticipant participant;
  final bool canRemove;
  final VoidCallback? onRemoveTap;

  const TripParticipantCard({
    super.key,
    required this.participant,
    required this.canRemove,
    this.onRemoveTap,
  });

  Color get _pillColor {
    switch (participant.status) {
      case TripResponseStatus.pending:
        return const Color(0xFFF4DC6D);
      case TripResponseStatus.notGoing:
        return const Color(0xFFE77555);
      case TripResponseStatus.going:
        return const Color(0xFF7D9BBF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
      child: Row(
        children: [
          AppAvatar.singleUser(size: 50),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  participant.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppFonts.urbanist,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryDark,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  participant.handle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppFonts.openSans,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.carla,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  constraints: const BoxConstraints(minWidth: 88),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _pillColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    participant.status.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppFonts.urbanist,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (canRemove) ...[
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              child: IconButton(
                tooltip: 'Remove ${participant.name}',
                onPressed: onRemoveTap,
                splashRadius: 22,
                icon: const _RemoveParticipantIcon(
                  color: AppColors.primaryOrange,
                  size: 24,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Custom vector icon matching the Figma red-orange user silhouette with an "x"
/// inside the head.
class _RemoveParticipantIcon extends StatelessWidget {
  final Color color;
  final double size;

  const _RemoveParticipantIcon({
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RemoveParticipantIconPainter(color: color),
      ),
    );
  }
}

class _RemoveParticipantIconPainter extends CustomPainter {
  final Color color;

  const _RemoveParticipantIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;

    // Head circle
    final headCenter = Offset(w * 0.5, h * 0.28);
    final headRadius = w * 0.22;
    canvas.drawCircle(headCenter, headRadius, fillPaint);

    // White "x" inside head
    final xPaint = Paint()
      ..color = AppColors.white
      ..strokeWidth = w * 0.085
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final xOffset = headRadius * 0.38;
    canvas.drawLine(
      Offset(headCenter.dx - xOffset, headCenter.dy - xOffset),
      Offset(headCenter.dx + xOffset, headCenter.dy + xOffset),
      xPaint,
    );
    canvas.drawLine(
      Offset(headCenter.dx + xOffset, headCenter.dy - xOffset),
      Offset(headCenter.dx - xOffset, headCenter.dy + xOffset),
      xPaint,
    );

    // Shoulders arc/body
    final bodyPath = Path()
      ..moveTo(w * 0.14, h * 0.88)
      ..cubicTo(
        w * 0.14,
        h * 0.60,
        w * 0.86,
        h * 0.60,
        w * 0.86,
        h * 0.88,
      )
      ..quadraticBezierTo(w * 0.86, h * 0.94, w * 0.78, h * 0.94)
      ..lineTo(w * 0.22, h * 0.94)
      ..quadraticBezierTo(w * 0.14, h * 0.94, w * 0.14, h * 0.88)
      ..close();

    canvas.drawPath(bodyPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _RemoveParticipantIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
