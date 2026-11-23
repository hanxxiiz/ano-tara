import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/trip_repository.dart';

/// Stylized light-lavender vector street map header matching Figma 07.01 & 07.02,
/// with an overlaid [TripStatusPill] positioned in the top-right corner.
class TripMapBanner extends StatelessWidget {
  final TripStatus status;
  final double height;

  const TripMapBanner({
    super.key,
    required this.status,
    this.height = 104,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _StylizedMapPainter(),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: TripStatusPill(status: status),
          ),
        ],
      ),
    );
  }
}

/// Bordered status pill matching Figma:
/// - Ongoing: Primary Navy (#144885) + White text
/// - Completed: Semantic Yellow (#F9CF09) + Dark Ink (#0F0331) text
/// - Cancelled: Primary Orange (#E24B27) + White text
/// - Upcoming: Soft Navy Tint (#E8EEF5) + Primary Navy (#144885) text
class TripStatusPill extends StatelessWidget {
  final TripStatus status;

  const TripStatusPill({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case TripStatus.ongoing:
        backgroundColor = AppColors.primaryNavy;
        textColor = AppColors.white;
        break;
      case TripStatus.completed:
        backgroundColor = AppColors.semanticYellow;
        textColor = AppColors.secondaryDark;
        break;
      case TripStatus.cancelled:
        backgroundColor = AppColors.primaryOrange;
        textColor = AppColors.white;
        break;
      case TripStatus.upcoming:
        backgroundColor = AppColors.primaryNavyLight;
        textColor = AppColors.primaryNavy;
        break;
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 88),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.secondaryDark,
          width: 1.5,
        ),
      ),
      child: Text(
        status.label,
        textAlign: TextAlign.center,
        style: AppTypography.badge.copyWith(
          color: textColor,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          height: 1.1,
        ),
      ),
    );
  }
}

class _StylizedMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Soft lavender-blue map base
    final bgPaint = Paint()..color = const Color(0xFFEAECFF);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final w = size.width;
    final h = size.height;

    // Secondary street grid lines
    final minorRoad = Paint()
      ..color = const Color(0xFF9AA8F8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Left block roads
    final leftPath = Path()
      ..moveTo(w * 0.04, 0)
      ..lineTo(w * 0.09, h * 0.56)
      ..lineTo(w * 0.19, h * 0.44)
      ..lineTo(w * 0.13, 0);
    canvas.drawPath(leftPath, minorRoad);

    canvas.drawLine(Offset(0, h * 0.65), Offset(w * 0.03, h * 0.61), minorRoad);
    canvas.drawLine(
      Offset(w * 0.08, h * 0.34),
      Offset(w * 0.17, h * 0.23),
      minorRoad,
    );

    // Mid-left connecting avenues
    final midPath = Path()
      ..moveTo(w * 0.18, h * 1.0)
      ..lineTo(w * 0.21, h * 0.80)
      ..lineTo(w * 0.56, h * 0.16)
      ..lineTo(w * 0.63, 0);
    canvas.drawPath(midPath, minorRoad);

    canvas.drawLine(
      Offset(w * 0.22, 0),
      Offset(w * 0.26, h * 0.72),
      minorRoad,
    );
    canvas.drawLine(
      Offset(w * 0.24, h * 0.34),
      Offset(w * 0.43, h * 0.0),
      minorRoad,
    );
    canvas.drawLine(
      Offset(w * 0.43, 0),
      Offset(w * 0.49, h * 0.28),
      minorRoad,
    );
    canvas.drawLine(
      Offset(w * 0.48, h * 0.29),
      Offset(w * 0.61, h * 1.0),
      minorRoad,
    );

    // Right-side street loops
    final rightPath = Path()
      ..moveTo(w * 0.60, h * 1.0)
      ..lineTo(w * 0.65, h * 0.56)
      ..lineTo(w * 0.77, h * 0.42)
      ..lineTo(w * 0.87, h * 0.56)
      ..lineTo(w * 0.84, h * 1.0);
    canvas.drawPath(rightPath, minorRoad);

    canvas.drawLine(
      Offset(w * 0.71, h * 0.19),
      Offset(w * 1.0, h * 0.50),
      minorRoad,
    );
    canvas.drawLine(
      Offset(w * 0.72, 0),
      Offset(w * 0.88, h * 0.12),
      minorRoad,
    );
    canvas.drawLine(
      Offset(w * 0.57, h * 0.36),
      Offset(w * 0.78, h * 0.16),
      minorRoad,
    );

    // Primary diagonal arterial highway (thicker periwinkle stroke)
    final majorRoad = Paint()
      ..color = const Color(0xFF7B8DF6)
      ..strokeWidth = 7.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final highwayPath = Path()
      ..moveTo(w * 0.46, h * 1.04)
      ..lineTo(w * 0.56, h * 0.35)
      ..lineTo(w * 0.72, 0);
    canvas.drawPath(highwayPath, majorRoad);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
