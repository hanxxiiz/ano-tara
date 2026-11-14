import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/group_models.dart';
import '../atoms/app_avatar.dart';

/// Group trip card matching Figma "05.03 Group details — associated trips":
/// Recipe: Map header + status pill + title + location/date metadata + member tokens + open action.
class GroupTripCard extends StatelessWidget {
  final GroupTrip trip;
  final VoidCallback? onTap;

  /// Tap on the trailing arrow; falls back to [onTap] when null.
  final VoidCallback? onArrowTap;

  const GroupTripCard({
    super.key,
    required this.trip,
    this.onTap,
    this.onArrowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: '${trip.title}, ${trip.status.label}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.secondaryDark, width: 2),
            boxShadow: const [
              BoxShadow(
                color: AppColors.secondaryDark,
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 74,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const ColoredBox(
                      color: AppColors.mapLavender,
                      child: CustomPaint(painter: _MapLinesPainter()),
                    ),
                    Positioned(
                      top: 8,
                      right: 12,
                      child: TripStatusPill(status: trip.status),
                    ),
                  ],
                ),
              ),
              Container(height: 2, color: AppColors.secondaryDark),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 12, 14, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.h4.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondaryDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _MetaRow(
                            icon: Iconsax.location,
                            iconColor: AppColors.primaryOrange,
                            text: trip.location,
                          ),
                          const SizedBox(height: 4),
                          _MetaRow(
                            icon: Iconsax.calendar_1,
                            iconColor: AppColors.secondaryDark,
                            text: trip.dateRange,
                          ),
                          const SizedBox(height: 12),
                          AppInitialsTokenRow(names: trip.memberNames),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Semantics(
                      button: true,
                      label: '${trip.title} options',
                      container: true,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onArrowTap ?? onTap,
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(
                            Iconsax.arrow_circle_right,
                            color: AppColors.secondaryDark,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rounded status label shown on the trip card map header.
class TripStatusPill extends StatelessWidget {
  final TripStatus status;

  const TripStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color background, Color foreground) = switch (status) {
      TripStatus.ongoing => (AppColors.primaryNavy, AppColors.white),
      TripStatus.completed => (AppColors.primaryOrange, AppColors.white),
      TripStatus.upcoming => (
        AppColors.semanticYellow,
        AppColors.secondaryDark,
      ),
      TripStatus.cancelled => (
        AppColors.secondaryLight,
        AppColors.secondaryDark,
      ),
    };

    return Container(
      constraints: const BoxConstraints(minWidth: 88),
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.secondaryDark, width: 1.5),
      ),
      child: Text(
        status.label,
        style: AppTypography.badge.copyWith(
          color: foreground,
          fontSize: 10,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _MetaRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: iconColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.slate,
              fontSize: 11.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// Stylised street-map line art used until trips carry a real cover image.
class _MapLinesPainter extends CustomPainter {
  const _MapLinesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.mapLavenderLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final roads = <List<Offset>>[
      [
        Offset(0, h * 0.25),
        Offset(w * 0.35, h * 0.55),
        Offset(w * 0.7, h * 0.15),
        Offset(w, h * 0.45),
      ],
      [Offset(w * 0.1, h), Offset(w * 0.25, h * 0.4), Offset(w * 0.3, 0)],
      [
        Offset(w * 0.45, h),
        Offset(w * 0.55, h * 0.6),
        Offset(w * 0.85, h * 0.75),
        Offset(w, h * 0.95),
      ],
      [
        Offset(w * 0.6, 0),
        Offset(w * 0.62, h * 0.35),
        Offset(w * 0.9, h * 0.3),
      ],
      [Offset(0, h * 0.8), Offset(w * 0.2, h * 0.7), Offset(w * 0.4, h * 0.85)],
    ];

    for (final road in roads) {
      final path = Path()..moveTo(road.first.dx, road.first.dy);
      for (final point in road.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
