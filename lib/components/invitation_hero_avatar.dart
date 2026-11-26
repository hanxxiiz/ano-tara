import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Centered circular illustrated inviter avatar with a tilted bottom-right
/// icon badge, matching the Group Invitation and Trip Invitation Figma designs.
class InvitationHeroAvatar extends StatelessWidget {
  const InvitationHeroAvatar({
    super.key,
    required this.badgeIcon,
    this.size = 112,
  });

  final IconData badgeIcon;
  final double size;

  static const Color _darkNavy = Color(0xFF10052F);
  static const Color _avatarBg = Color(0xFF144885);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 16,
      height: size + 12,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Circular illustrated portrait
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: _avatarBg,
              shape: BoxShape.circle,
              border: Border.all(color: _darkNavy, width: 3.0),
            ),
            child: ClipOval(
              child: CustomPaint(
                size: Size.square(size),
                painter: const _InviterIllustrationPainter(),
              ),
            ),
          ),

          // Tilted bottom-right badge
          Positioned(
            right: 0,
            bottom: 0,
            child: Transform.rotate(
              angle: 0.16,
              child: Container(
                width: 44,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _darkNavy, width: 2.4),
                  boxShadow: const [
                    BoxShadow(
                      color: _darkNavy,
                      offset: Offset(0, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    badgeIcon,
                    size: 18,
                    color: _darkNavy,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InviterIllustrationPainter extends CustomPainter {
  const _InviterIllustrationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final inkStroke = Paint()
      ..color = const Color(0xFF10052F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.022
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final hairPaint = Paint()
      ..color = const Color(0xFFFF1A0E)
      ..style = PaintingStyle.fill;

    final skinPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shirtPaint = Paint()
      ..color = const Color(0xFFE24B27)
      ..style = PaintingStyle.fill;

    // Back hair volume
    final backHairPath = Path()
      ..moveTo(w * 0.27, h * 0.44)
      ..quadraticBezierTo(w * 0.24, h * 0.20, w * 0.48, h * 0.17)
      ..quadraticBezierTo(w * 0.74, h * 0.17, w * 0.76, h * 0.44)
      ..quadraticBezierTo(w * 0.77, h * 0.67, w * 0.68, h * 0.75)
      ..lineTo(w * 0.30, h * 0.75)
      ..quadraticBezierTo(w * 0.25, h * 0.65, w * 0.27, h * 0.44)
      ..close();
    canvas.drawPath(backHairPath, hairPaint);

    // Shoulders / neck
    final shoulderPath = Path()
      ..moveTo(w * 0.12, h * 0.92)
      ..quadraticBezierTo(w * 0.28, h * 0.75, w * 0.42, h * 0.74)
      ..lineTo(w * 0.42, h * 0.65)
      ..lineTo(w * 0.58, h * 0.65)
      ..lineTo(w * 0.58, h * 0.74)
      ..quadraticBezierTo(w * 0.74, h * 0.76, w * 0.88, h * 0.92)
      ..lineTo(w * 0.88, h * 1.02)
      ..lineTo(w * 0.12, h * 1.02)
      ..close();
    canvas.drawPath(shoulderPath, skinPaint);

    // Terracotta off-shoulder top
    final shirtRect = Rect.fromLTWH(w * 0.10, h * 0.84, w * 0.80, h * 0.22);
    canvas.drawRect(shirtRect, shirtPaint);

    // Subtle collarbone/shoulder outline
    final shoulderOutline = Path()
      ..moveTo(w * 0.16, h * 0.84)
      ..quadraticBezierTo(w * 0.32, h * 0.76, w * 0.43, h * 0.75)
      ..moveTo(w * 0.57, h * 0.75)
      ..quadraticBezierTo(w * 0.68, h * 0.76, w * 0.84, h * 0.84);
    canvas.drawPath(
      shoulderOutline,
      Paint()
        ..color = const Color(0xFFE24B27)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.018
        ..strokeCap = StrokeCap.round,
    );

    // Head / face oval
    final faceRect = Rect.fromCenter(
      center: Offset(w * 0.53, h * 0.51),
      width: w * 0.35,
      height: h * 0.39,
    );
    canvas.drawOval(faceRect, skinPaint);

    // Left ear
    canvas.drawCircle(Offset(w * 0.35, h * 0.52), w * 0.04, skinPaint);

    // Front bangs & side hair
    final bangsPath = Path()
      ..moveTo(w * 0.33, h * 0.42)
      ..quadraticBezierTo(w * 0.36, h * 0.24, w * 0.54, h * 0.24)
      ..quadraticBezierTo(w * 0.71, h * 0.25, w * 0.72, h * 0.42)
      ..lineTo(w * 0.64, h * 0.40)
      ..lineTo(w * 0.60, h * 0.43)
      ..lineTo(w * 0.53, h * 0.39)
      ..lineTo(w * 0.45, h * 0.42)
      ..lineTo(w * 0.37, h * 0.40)
      ..close();
    canvas.drawPath(bangsPath, hairPaint);

    // Hair highlight streaks
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.014
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromLTWH(w * 0.34, h * 0.24, w * 0.14, h * 0.12),
      math.pi * 1.05,
      math.pi * 0.32,
      false,
      highlightPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(w * 0.56, h * 0.24, w * 0.12, h * 0.10),
      -math.pi * 0.35,
      math.pi * 0.28,
      false,
      highlightPaint,
    );

    // Glasses frames
    final leftLensCenter = Offset(w * 0.49, h * 0.50);
    final rightLensCenter = Offset(w * 0.64, h * 0.50);
    final lensRadius = w * 0.068;

    final glassesPaint = Paint()
      ..color = const Color(0xFF10052F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025;

    canvas.drawCircle(leftLensCenter, lensRadius, glassesPaint);
    canvas.drawCircle(rightLensCenter, lensRadius, glassesPaint);
    // Bridge
    canvas.drawLine(
      Offset(leftLensCenter.dx + lensRadius, leftLensCenter.dy - w * 0.01),
      Offset(rightLensCenter.dx - lensRadius, rightLensCenter.dy - w * 0.01),
      glassesPaint,
    );
    // Temple arm
    canvas.drawLine(
      Offset(w * 0.33, h * 0.49),
      Offset(leftLensCenter.dx - lensRadius, leftLensCenter.dy - w * 0.01),
      glassesPaint,
    );

    // Eyes
    final eyePaint = Paint()
      ..color = const Color(0xFF10052F)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.50, h * 0.50), w * 0.016, eyePaint);
    canvas.drawCircle(Offset(w * 0.64, h * 0.50), w * 0.016, eyePaint);

    // Nose
    final nosePath = Path()
      ..moveTo(w * 0.58, h * 0.50)
      ..quadraticBezierTo(w * 0.60, h * 0.55, w * 0.57, h * 0.56);
    canvas.drawPath(nosePath, inkStroke);

    // Smile
    final smileRect = Rect.fromCenter(
      center: Offset(w * 0.55, h * 0.59),
      width: w * 0.09,
      height: h * 0.07,
    );
    canvas.drawArc(smileRect, 0.2, math.pi * 0.72, false, inkStroke);

    // Chin contour
    final chinArc = Rect.fromCenter(
      center: Offset(w * 0.53, h * 0.52),
      width: w * 0.35,
      height: h * 0.37,
    );
    canvas.drawArc(
      chinArc,
      0.35,
      math.pi * 0.45,
      false,
      Paint()
        ..color = const Color(0xFFE24B27)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.016
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
