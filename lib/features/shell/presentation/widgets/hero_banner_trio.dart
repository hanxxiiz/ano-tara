import 'package:flutter/material.dart';

/// Custom illustration matching the 3-friend group in the Figma hero banner.
class HeroBannerTrio extends StatelessWidget {
  const HeroBannerTrio({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 175,
      child: CustomPaint(
        painter: _TrioPainter(),
      ),
    );
  }
}

class _TrioPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = const Color(0xFF0F0331)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final thinStroke = Paint()
      ..color = const Color(0xFF0F0331)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final fillWhite = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final fillDark = Paint()
      ..color = const Color(0xFF0F0331)
      ..style = PaintingStyle.fill;

    // --- CHARACTER 1 (Back Center / Fedora Hat Guy) ---
    final centerBackX = size.width * 0.58;
    final centerBackY = size.height * 0.32;

    // Hat brim
    final hatBrim = Path()
      ..moveTo(centerBackX - 34, centerBackY - 14)
      ..quadraticBezierTo(centerBackX, centerBackY - 24, centerBackX + 34, centerBackY - 14)
      ..quadraticBezierTo(centerBackX, centerBackY - 8, centerBackX - 34, centerBackY - 14);
    canvas.drawPath(hatBrim, fillDark);
    canvas.drawPath(hatBrim, strokePaint);

    // Hat crown
    final hatCrown = Path()
      ..moveTo(centerBackX - 22, centerBackY - 18)
      ..quadraticBezierTo(centerBackX - 18, centerBackY - 48, centerBackX - 4, centerBackY - 45)
      ..quadraticBezierTo(centerBackX, centerBackY - 41, centerBackX + 4, centerBackY - 45)
      ..quadraticBezierTo(centerBackX + 18, centerBackY - 48, centerBackX + 22, centerBackY - 18)
      ..close();
    canvas.drawPath(hatCrown, fillDark);
    canvas.drawPath(hatCrown, strokePaint);

    // Guy face
    final hatGuyFace = Rect.fromCenter(
      center: Offset(centerBackX, centerBackY + 12),
      width: 38,
      height: 44,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(hatGuyFace, const Radius.circular(16)), fillWhite);
    canvas.drawRRect(RRect.fromRectAndRadius(hatGuyFace, const Radius.circular(16)), strokePaint);

    // Hat guy glasses
    canvas.drawCircle(Offset(centerBackX - 8, centerBackY + 6), 5, strokePaint);
    canvas.drawCircle(Offset(centerBackX + 8, centerBackY + 6), 5, strokePaint);
    canvas.drawLine(Offset(centerBackX - 3, centerBackY + 6), Offset(centerBackX + 3, centerBackY + 6), strokePaint);
    // pupils
    canvas.drawCircle(Offset(centerBackX - 8, centerBackY + 6), 1.5, fillDark);
    canvas.drawCircle(Offset(centerBackX + 8, centerBackY + 6), 1.5, fillDark);

    // Mustache & Beard
    final mustache = Path()
      ..moveTo(centerBackX - 10, centerBackY + 18)
      ..quadraticBezierTo(centerBackX - 4, centerBackY + 14, centerBackX, centerBackY + 17)
      ..quadraticBezierTo(centerBackX + 4, centerBackY + 14, centerBackX + 10, centerBackY + 18)
      ..quadraticBezierTo(centerBackX, centerBackY + 22, centerBackX - 10, centerBackY + 18);
    canvas.drawPath(mustache, fillDark);

    // Smile in beard
    canvas.drawArc(
      Rect.fromCenter(center: Offset(centerBackX, centerBackY + 23), width: 10, height: 6),
      0,
      3.14,
      false,
      thinStroke,
    );

    // --- CHARACTER 2 (Right Guy / Hoodie Guy) ---
    final rightX = size.width * 0.82;
    final rightY = size.height * 0.58;

    // Hair
    final hairRight = Path()
      ..moveTo(rightX - 22, rightY - 26)
      ..quadraticBezierTo(rightX - 10, rightY - 44, rightX + 6, rightY - 38)
      ..quadraticBezierTo(rightX + 24, rightY - 36, rightX + 24, rightY - 14)
      ..quadraticBezierTo(rightX + 20, rightY + 4, rightX + 16, rightY + 8)
      ..lineTo(rightX - 16, rightY - 12)
      ..close();
    canvas.drawPath(hairRight, fillDark);

    // Face
    final rightFace = Rect.fromCenter(
      center: Offset(rightX, rightY),
      width: 44,
      height: 48,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(rightFace, const Radius.circular(20)), fillWhite);
    canvas.drawRRect(RRect.fromRectAndRadius(rightFace, const Radius.circular(20)), strokePaint);

    // Right guy hair bangs
    final rightBangs = Path()
      ..moveTo(rightX - 20, rightY - 18)
      ..quadraticBezierTo(rightX - 6, rightY - 22, rightX + 4, rightY - 16)
      ..quadraticBezierTo(rightX + 14, rightY - 22, rightX + 20, rightY - 12);
    canvas.drawPath(rightBangs, strokePaint);

    // Eyes
    canvas.drawArc(
      Rect.fromCenter(center: Offset(rightX - 9, rightY - 6), width: 9, height: 7),
      3.14,
      3.14,
      false,
      strokePaint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(rightX + 9, rightY - 6), width: 9, height: 7),
      3.14,
      3.14,
      false,
      strokePaint,
    );

    // Big Smile
    final smileRight = Path()
      ..moveTo(rightX - 10, rightY + 8)
      ..quadraticBezierTo(rightX, rightY + 20, rightX + 10, rightY + 8)
      ..close();
    canvas.drawPath(smileRight, fillDark);

    // Beard outline
    final beardPath = Path()
      ..moveTo(rightX - 16, rightY + 6)
      ..quadraticBezierTo(rightX - 14, rightY + 24, rightX, rightY + 26)
      ..quadraticBezierTo(rightX + 14, rightY + 24, rightX + 16, rightY + 6);
    canvas.drawPath(beardPath, thinStroke);

    // Hoodie shoulders
    final hoodie = Path()
      ..moveTo(rightX - 22, rightY + 26)
      ..lineTo(rightX - 26, size.height)
      ..lineTo(size.width + 4, size.height)
      ..lineTo(rightX + 28, rightY + 24)
      ..close();
    canvas.drawPath(hoodie, fillWhite);
    canvas.drawPath(hoodie, strokePaint);

    // --- CHARACTER 3 (Foreground Front Girl with Bob Hair & Round Glasses) ---
    final frontX = size.width * 0.38;
    final frontY = size.height * 0.65;

    // Bob Hair behind/around
    final bobHair = Path()
      ..moveTo(frontX - 32, frontY - 16)
      ..quadraticBezierTo(frontX - 36, frontY + 24, frontX - 22, frontY + 36)
      ..lineTo(frontX + 24, frontY + 36)
      ..quadraticBezierTo(frontX + 36, frontY + 24, frontX + 32, frontY - 16)
      ..quadraticBezierTo(frontX, frontY - 42, frontX - 32, frontY - 16)
      ..close();
    canvas.drawPath(bobHair, fillDark);

    // Face
    final girlFace = Rect.fromCenter(
      center: Offset(frontX, frontY + 4),
      width: 48,
      height: 48,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(girlFace, const Radius.circular(22)), fillWhite);
    canvas.drawRRect(RRect.fromRectAndRadius(girlFace, const Radius.circular(22)), strokePaint);

    // Bangs
    final bangs = Path()
      ..moveTo(frontX - 24, frontY - 14)
      ..quadraticBezierTo(frontX - 10, frontY - 6, frontX, frontY - 12)
      ..quadraticBezierTo(frontX + 12, frontY - 6, frontX + 24, frontY - 14)
      ..quadraticBezierTo(frontX, frontY - 26, frontX - 24, frontY - 14)
      ..close();
    canvas.drawPath(bangs, fillDark);

    // Round Glasses
    final leftGlass = Rect.fromCenter(center: Offset(frontX - 10, frontY + 2), width: 17, height: 17);
    final rightGlass = Rect.fromCenter(center: Offset(frontX + 10, frontY + 2), width: 17, height: 17);
    canvas.drawOval(leftGlass, strokePaint);
    canvas.drawOval(rightGlass, strokePaint);
    canvas.drawLine(Offset(frontX - 2, frontY + 2), Offset(frontX + 2, frontY + 2), strokePaint);

    // Eyes behind glasses
    canvas.drawCircle(Offset(frontX - 10, frontY + 2), 2.2, fillDark);
    canvas.drawCircle(Offset(frontX + 10, frontY + 2), 2.2, fillDark);

    // Smile
    final girlSmile = Path()
      ..moveTo(frontX - 8, frontY + 16)
      ..quadraticBezierTo(frontX, frontY + 23, frontX + 8, frontY + 16);
    canvas.drawPath(girlSmile, strokePaint);

    // Black Top
    final blackShirt = Path()
      ..moveTo(frontX - 24, frontY + 28)
      ..quadraticBezierTo(frontX, frontY + 34, frontX + 24, frontY + 28)
      ..lineTo(frontX + 38, size.height)
      ..lineTo(frontX - 38, size.height)
      ..close();
    canvas.drawPath(blackShirt, fillDark);
    canvas.drawPath(blackShirt, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
