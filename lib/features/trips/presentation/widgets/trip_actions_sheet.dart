import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

enum TripActionChoice {
  edit,
  cancel,
  delete,
}

/// Trip Actions modal bottom sheet matching Figma 07.04.
/// Only shown to the Trip Organizer.
class TripActionsSheet extends StatelessWidget {
  const TripActionsSheet({super.key});

  static Future<TripActionChoice?> show(BuildContext context) {
    return showModalBottomSheet<TripActionChoice>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TripActionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _NeoBottomSheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _CloseSquareButton(onTap: () => Navigator.of(context).pop()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.semanticYellow,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.secondaryDark, width: 1),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Trip Actions',
                  style: AppTypography.h2.copyWith(
                    color: AppColors.secondaryDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1, color: AppColors.ann),
          ),
          _ActionMenuRow(
            icon: Iconsax.edit_2,
            iconColor: AppColors.secondaryDark,
            title: 'Edit Trip',
            titleColor: AppColors.secondaryDark,
            subtitle: 'Update trip details, dates, and meeting location.',
            onTap: () => Navigator.of(context).pop(TripActionChoice.edit),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1, color: AppColors.ann),
          ),
          _ActionMenuRow(
            icon: Iconsax.user_remove,
            iconColor: AppColors.secondaryDark,
            title: 'Cancel Trip',
            titleColor: AppColors.secondaryDark,
            subtitle: 'Cancel this trip and notify its participants.',
            onTap: () => Navigator.of(context).pop(TripActionChoice.cancel),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1, color: AppColors.ann),
          ),
          _ActionMenuRow(
            icon: Iconsax.trash,
            iconColor: AppColors.primaryOrange,
            title: 'Delete Trip',
            titleColor: AppColors.primaryOrange,
            subtitle: 'Permanently delete this trip and its data.',
            onTap: () => Navigator.of(context).pop(TripActionChoice.delete),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

/// Delete Trip confirmation dialog/sheet matching Figma 07.05.
class DeleteTripDialog extends StatelessWidget {
  const DeleteTripDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const DeleteTripDialog(),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    return _NeoBottomSheetContainer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: _CloseSquareButton(
                onTap: () => Navigator.of(context).pop(false),
              ),
            ),
            const _WarningHexagonBadge(),
            const SizedBox(height: 16),
            Text(
              'Delete Trip',
              style: AppTypography.h2.copyWith(
                color: AppColors.secondaryDark,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Are you sure you want to delete this trip? All trip details, itineraries, and associated records will be permanently removed. This action cannot be undone.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.carla,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Delete Trip',
              variant: AppButtonVariant.destructive,
              customHeight: 50,
              borderRadius: 16,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 12),
            AppButton(
              text: 'Cancel',
              variant: AppButtonVariant.secondary,
              customHeight: 50,
              borderRadius: 16,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cancel Trip confirmation dialog/sheet matching Figma 07.06.
class CancelTripDialog extends StatefulWidget {
  const CancelTripDialog({super.key});

  /// Returns the cancellation reason string when confirmed (may be empty),
  /// or `null` when dismissed.
  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const CancelTripDialog(),
    );
  }

  @override
  State<CancelTripDialog> createState() => _CancelTripDialogState();
}

class _CancelTripDialogState extends State<CancelTripDialog> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: _NeoBottomSheetContainer(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: _CloseSquareButton(
                  onTap: () => Navigator.of(context).pop(null),
                ),
              ),
              const _WarningHexagonBadge(),
              const SizedBox(height: 16),
              Text(
                'Cancel Trip',
                style: AppTypography.h2.copyWith(
                  color: AppColors.secondaryDark,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Are you sure you want to cancel this trip? Participants will be notified, and the trip will remain in your history.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.carla,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Reason',
                  style: AppTypography.inputLabel.copyWith(
                    color: AppColors.primaryOrange,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.secondaryDark,
                    width: 2.0,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                child: TextField(
                  controller: _reasonController,
                  minLines: 4,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.secondaryDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  cursorColor: AppColors.secondaryDark,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              AppButton(
                text: 'Cancel Trip',
                variant: AppButtonVariant.destructive,
                customHeight: 50,
                borderRadius: 16,
                onPressed: () =>
                    Navigator.of(context).pop(_reasonController.text.trim()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeoBottomSheetContainer extends StatelessWidget {
  final Widget child;

  const _NeoBottomSheetContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: AppColors.secondaryDark,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CloseSquareButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CloseSquareButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.secondaryDark, width: 2.0),
          boxShadow: const [
            BoxShadow(
              color: AppColors.secondaryDark,
              offset: Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.close_rounded,
            size: 20,
            color: AppColors.secondaryDark,
          ),
        ),
      ),
    );
  }
}

class _ActionMenuRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color titleColor;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionMenuRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.titleColor,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleLarge.copyWith(
                      color: titleColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.carla,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.secondaryDark,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

/// Terracotta rounded hexagon with a crisp white exclamation mark matching 07.05 & 07.06.
class _WarningHexagonBadge extends StatelessWidget {
  const _WarningHexagonBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      height: 78,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(78, 78),
            painter: _HexagonPainter(color: AppColors.primaryOrange),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6.5,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
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
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.47;

    // 6 vertices of a pointy-top hexagon
    final points = List.generate(6, (i) {
      final angle = (math.pi / 3) * i - math.pi / 2;
      return Offset(cx + r * math.cos(angle), cy + r * math.sin(angle));
    });

    final path = Path();
    const cornerRadius = 10.0;

    for (int i = 0; i < 6; i++) {
      final prev = points[(i + 5) % 6];
      final curr = points[i];
      final next = points[(i + 1) % 6];

      final v1 = (prev - curr);
      final v2 = (next - curr);
      final p1 = curr + v1 / v1.distance * cornerRadius;
      final p2 = curr + v2 / v2.distance * cornerRadius;

      if (i == 0) {
        path.moveTo(p1.dx, p1.dy);
      } else {
        path.lineTo(p1.dx, p1.dy);
      }
      path.quadraticBezierTo(curr.dx, curr.dy, p2.dx, p2.dy);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HexagonPainter oldDelegate) =>
      oldDelegate.color != color;
}
