import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// MarkAllAsRead component matching Figma `04.01 · Notifications — all activity`.
///
/// Compact pill button with light gray fill, dark navy border, circular
/// status-dot icon (or checkmark when all read), and "Mark all as read" label.
class MarkAllAsRead extends StatelessWidget {
  const MarkAllAsRead({
    super.key,
    required this.checked,
    required this.onChanged,
    this.label = 'Mark all as read',
  });

  final bool checked;
  final ValueChanged<bool> onChanged;
  final String label;

  static const Color backgroundColor = Color(0xFFE9E7E7);
  static const Color darkNavy = Color(0xFF10052F);
  static const Color primaryBlue = Color(0xFF144885);
  static const Color textColor = Color(0xFF0F0331);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!checked),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: darkNavy,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (checked)
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    size: 13,
                    color: Colors.white,
                  ),
                ),
              )
            else
              const SizedBox(
                width: 18,
                height: 18,
                child: CustomPaint(
                  painter: _NotificationRingIconPainter(color: darkNavy),
                ),
              ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppFonts.urbanist,
                color: textColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws the circular ring with a small dot at the top-right matching Figma.
class _NotificationRingIconPainter extends CustomPainter {
  const _NotificationRingIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width * 0.46, size.height * 0.54);
    final radius = size.width * 0.39;

    // Open circular arc leaving room for the top-right status dot
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.08,
      math.pi * 1.65,
      false,
      strokePaint,
    );

    // Small circle dot at the top-right
    final dotCenter = Offset(size.width * 0.78, size.height * 0.24);
    canvas.drawCircle(dotCenter, size.width * 0.14, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _NotificationRingIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
