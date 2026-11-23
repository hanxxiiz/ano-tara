import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../components/atoms/app_button.dart';
import '../models/notification_models.dart';
import '../theme/app_theme.dart';

/// Accepted and Declined result screens matching Figma:
/// - `04.04 · Group invitation — accepted success.png`
/// - `04.04 · Group invitation — accepted success-1.png` (Trip accepted)
/// - `04.05 · Group invitation — declined success.png`
/// - `04.08 · Trip invitation — declined success.png`
class InvitationResultScreen extends StatelessWidget {
  const InvitationResultScreen({
    super.key,
    required this.invitationType,
    required this.accepted,
    required this.targetName,
    this.onPrimaryAction,
  });

  final InvitationType invitationType;
  final bool accepted;
  final String targetName;
  final VoidCallback? onPrimaryAction;

  static const Color badgeOrange = Color(0xFFE24B27);
  static const Color inkColor = Color(0xFF0F0331);

  String get _title {
    if (accepted) {
      return invitationType == InvitationType.group
          ? 'Group Invitation Accepted'
          : 'Trip Invitation Accepted';
    }
    return invitationType == InvitationType.group
        ? 'Group Invitation Declined'
        : 'Invitation Declined';
  }

  String get _description {
    if (accepted) {
      if (invitationType == InvitationType.group) {
        return "You've successfully joined $targetName. You're now part of the group and can start planning trips together.";
      }
      return "You've successfully joined $targetName. Start sharing ideas, dreaming up adventures, and planning the perfect itinerary together.";
    }
    if (invitationType == InvitationType.group) {
      return "You've declined the invitation to $targetName. You won't be added to the group.";
    }
    return "You've declined the invitation to $targetName. Your response has been updated to Not Going.";
  }

  String get _buttonLabel {
    if (accepted) {
      return 'View Group';
    }
    return 'Back to Invitations';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 3),
              Center(
                child: SizedBox(
                  width: 142,
                  height: 142,
                  child: CustomPaint(
                    painter: accepted
                        ? const _AcceptedBadgePainter(color: badgeOrange)
                        : const _DeclinedBadgePainter(color: badgeOrange),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              Text(
                _title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppFonts.urbanist,
                  color: inkColor,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  _description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppFonts.openSans,
                    color: inkColor,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 52),
              AppButton(
                text: _buttonLabel,
                variant: AppButtonVariant.primaryNavy,
                customHeight: 52,
                borderRadius: 16,
                onPressed: onPrimaryAction ?? () => Navigator.of(context).pop(),
              ),
              const Spacer(flex: 4),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints the 8-lobe scalloped terracotta seal with a bold white checkmark
/// matching Figma `04.04`.
class _AcceptedBadgePainter extends CustomPainter {
  const _AcceptedBadgePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.44;
    const lobes = 8;
    const amplitude = 0.085;
    const steps = 240;

    final path = Path();
    for (int i = 0; i <= steps; i++) {
      final theta = (i / steps) * 2 * math.pi - (math.pi / 2);
      final r = baseRadius * (1 + amplitude * math.cos(lobes * theta));
      final x = center.dx + r * math.cos(theta);
      final y = center.dy + r * math.sin(theta);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Thick rounded white checkmark
    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.085
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final checkPath = Path()
      ..moveTo(size.width * 0.36, size.height * 0.51)
      ..lineTo(size.width * 0.46, size.height * 0.61)
      ..lineTo(size.width * 0.65, size.height * 0.41);

    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant _AcceptedBadgePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Paints the solid terracotta circle with a bold white X mark
/// matching Figma `04.05` and `04.08`.
class _DeclinedBadgePainter extends CustomPainter {
  const _DeclinedBadgePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.47;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, fillPaint);

    final crossPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.085
      ..strokeCap = StrokeCap.round;

    final offset = size.width * 0.16;
    canvas.drawLine(
      Offset(center.dx - offset, center.dy - offset),
      Offset(center.dx + offset, center.dy + offset),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx + offset, center.dy - offset),
      Offset(center.dx - offset, center.dy + offset),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DeclinedBadgePainter oldDelegate) =>
      oldDelegate.color != color;
}
