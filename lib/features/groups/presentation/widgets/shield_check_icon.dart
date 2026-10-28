import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Renders the white shield with an orange checkmark as shown in the confirmation mockup.
class ShieldCheckIcon extends StatelessWidget {
  final double size;

  const ShieldCheckIcon({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ShieldPainter(),
      ),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Shield path
    final shieldPath = Path()
      ..moveTo(w * 0.5, h * 0.1)
      ..lineTo(w * 0.85, h * 0.22)
      ..quadraticBezierTo(w * 0.88, h * 0.60, w * 0.5, h * 0.90)
      ..quadraticBezierTo(w * 0.12, h * 0.60, w * 0.15, h * 0.22)
      ..close();

    final whiteFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawPath(shieldPath, whiteFill);

    // Orange checkmark
    final checkPaint = Paint()
      ..color = AppColors.primaryOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final checkPath = Path()
      ..moveTo(w * 0.38, h * 0.52)
      ..lineTo(w * 0.48, h * 0.62)
      ..lineTo(w * 0.64, h * 0.42);

    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
