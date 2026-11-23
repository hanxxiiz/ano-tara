import 'package:flutter/material.dart';

/// Stylized lavender-and-periwinkle vector street map matching the Ano Tara
/// Figma mockups (11.01, 11.04, 11.10, 11.13, and Trip Map).
class StyledMapCanvas extends StatelessWidget {
  final Widget? child;
  final bool denseRoads;

  const StyledMapCanvas({
    super.key,
    this.child,
    this.denseRoads = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StylizedStreetMapPainter(denseRoads: denseRoads),
      child: child ?? const SizedBox.expand(),
    );
  }
}

class _StylizedStreetMapPainter extends CustomPainter {
  final bool denseRoads;

  const _StylizedStreetMapPainter({required this.denseRoads});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFF0F1FF);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final w = size.width;
    final h = size.height;

    final minorRoad = Paint()
      ..color = const Color(0xFF939FFF)
      ..strokeWidth = denseRoads ? 2.0 : 1.7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final majorRoad = Paint()
      ..color = const Color(0xFF8392FF)
      ..strokeWidth = denseRoads ? 9.0 : 7.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Major curved diagonal arterial road (bottom-left -> mid -> top-right)
    final mainPath = Path()
      ..moveTo(w * 0.16, h * 1.02)
      ..lineTo(w * 0.40, h * 0.62)
      ..lineTo(w * 0.68, h * 0.52)
      ..lineTo(w * 0.90, h * 0.43)
      ..lineTo(w * 1.04, h * 0.39);
    canvas.drawPath(mainPath, majorRoad);

    // Secondary major arterial road (top-center -> upper-right)
    final upperMajor = Path()
      ..moveTo(w * 0.52, -h * 0.02)
      ..lineTo(w * 0.66, h * 0.14)
      ..lineTo(w * 1.02, h * 0.36);
    canvas.drawPath(upperMajor, majorRoad);

    final topRightBranch = Path()
      ..moveTo(w * 0.66, h * 0.14)
      ..lineTo(w * 0.96, h * 0.04)
      ..lineTo(w * 1.03, h * 0.07);
    canvas.drawPath(topRightBranch, majorRoad);

    // Grid & diagonal minor streets matching Figma vector pattern
    void line(double x1, double y1, double x2, double y2) {
      canvas.drawLine(Offset(w * x1, h * y1), Offset(w * x2, h * y2), minorRoad);
    }

    // Upper-left neighborhood web
    line(0.00, 0.22, 0.22, 0.00);
    line(0.14, 0.09, 0.48, 0.45);
    line(0.00, 0.20, 0.35, 0.58);
    line(0.00, 0.36, 0.27, 0.50);
    line(0.00, 0.53, 0.41, 0.45);
    line(0.22, 0.00, 0.35, 0.05);
    line(0.35, 0.00, 0.34, 0.09);
    line(0.22, 0.15, 0.44, 0.39);
    line(0.08, 0.29, 0.24, 0.36);
    line(0.24, 0.36, 0.39, 0.41);

    // Mid-city angled grid blocks
    line(0.10, 0.57, 0.99, 0.29);
    line(0.14, 0.62, 1.02, 0.34);
    line(0.04, 0.50, 0.94, 0.23);
    line(0.02, 0.68, 0.35, 0.56);

    // Cross streets cutting across the mid-city blocks
    for (final t in [0.16, 0.25, 0.34, 0.43, 0.52, 0.61, 0.70, 0.79]) {
      line(t - 0.04, 0.44 - (t - 0.16) * 0.28, t + 0.05, 0.60 - (t - 0.16) * 0.28);
    }

    // Upper-right & center blocks
    line(0.45, 0.17, 0.68, 0.36);
    line(0.55, 0.15, 0.74, 0.30);
    line(0.68, 0.15, 0.56, 0.26);
    line(0.75, 0.22, 0.93, 0.12);
    line(0.84, 0.10, 1.00, 0.24);
    line(0.95, 0.06, 1.02, 0.17);

    if (denseRoads) {
      // Lower-left & lower-right cul-de-sacs and loops
      line(0.00, 0.66, 0.15, 0.62);
      line(0.12, 0.64, 0.00, 0.85);
      line(0.02, 0.88, 0.25, 0.68);
      line(0.08, 0.96, 0.36, 0.68);
      line(0.41, 0.62, 0.50, 0.76);
      line(0.32, 0.92, 0.48, 0.66);
      line(0.48, 0.66, 0.63, 0.61);
      line(0.63, 0.61, 0.72, 0.67);
      line(0.72, 0.67, 0.63, 0.94);
      line(0.72, 0.67, 1.02, 0.64);
      line(0.76, 0.96, 0.94, 0.82);
      line(0.94, 0.82, 1.02, 0.77);
      line(0.56, 0.82, 0.67, 0.85);
    }
  }

  @override
  bool shouldRepaint(covariant _StylizedStreetMapPainter oldDelegate) =>
      oldDelegate.denseRoads != denseRoads;
}
