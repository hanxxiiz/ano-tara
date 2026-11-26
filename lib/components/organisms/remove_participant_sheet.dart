import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../theme/app_theme.dart' show AppFonts;
import '../atoms/app_button.dart';

/// Opens the "Remove Trip Participant" confirmation bottom sheet/dialog.
/// Returns `true` if the organizer confirms removal, or `false`/`null` if cancelled.
///
/// Matches Figma "07.10 · Trip participant — remove confirmation.png".
Future<bool?> showRemoveParticipantDialog({
  required BuildContext context,
  String? participantName,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: AppColors.secondaryDark.withValues(alpha: 0.35),
    builder: (sheetContext) {
      return const _RemoveParticipantSheet();
    },
  );
}

class _RemoveParticipantSheet extends StatelessWidget {
  const _RemoveParticipantSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.secondaryDark, width: 2.0),
          left: BorderSide(color: AppColors.secondaryDark, width: 2.0),
          right: BorderSide(color: AppColors.secondaryDark, width: 2.0),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle + top-right close button
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: 46,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryDark,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context).pop(false),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.secondaryDark,
                                  width: 2.0,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.secondaryDark,
                                    offset: Offset(0, 2.5),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 20,
                                color: AppColors.secondaryDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 26),
                    child: _HexagonWarningIcon(size: 76),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title
              const Text(
                'Remove Trip Participant',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.urbanist,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondaryDark,
                ),
              ),
              const SizedBox(height: 10),

              // Body message
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'They will no longer be part of this trip or receive trip updates. They will remain a member of the group.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.openSans,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.carla,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Primary destructive action: Remove Member
              AppButton(
                text: 'Remove Member',
                variant: AppButtonVariant.primaryOrange,
                borderRadius: 16,
                customHeight: 50,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: 12),

              // Secondary action: Cancel
              AppButton(
                text: 'Cancel',
                variant: AppButtonVariant.secondary,
                borderRadius: 16,
                customHeight: 50,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Orange rounded hexagon with a white exclamation mark matching Figma 07.10.
class _HexagonWarningIcon extends StatelessWidget {
  final double size;

  const _HexagonWarningIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HexagonPainter(color: AppColors.primaryOrange),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: size * 0.085,
                height: size * 0.30,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              SizedBox(height: size * 0.07),
              Container(
                width: size * 0.095,
                height: size * 0.095,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HexagonPainter extends CustomPainter {
  final Color color;

  const _HexagonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) * 0.94;

    // Pointy-top hexagon vertices
    final vertices = <Offset>[];
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 180) * (60 * i - 90);
      vertices.add(Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)));
    }

    // Build rounded-corner path
    final path = Path();
    const cornerFraction = 0.20;
    for (int i = 0; i < 6; i++) {
      final prev = vertices[(i + 5) % 6];
      final curr = vertices[i];
      final next = vertices[(i + 1) % 6];

      final start = Offset.lerp(curr, prev, cornerFraction)!;
      final end = Offset.lerp(curr, next, cornerFraction)!;

      if (i == 0) {
        path.moveTo(start.dx, start.dy);
      } else {
        path.lineTo(start.dx, start.dy);
      }
      path.quadraticBezierTo(curr.dx, curr.dy, end.dx, end.dy);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HexagonPainter oldDelegate) =>
      oldDelegate.color != color;
}
