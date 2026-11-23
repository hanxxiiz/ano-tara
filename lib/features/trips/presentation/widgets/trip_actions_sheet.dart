import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/trip_repository.dart';

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
class CancelTripDialog extends StatelessWidget {
  const CancelTripDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const CancelTripDialog(),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    return _NeoBottomSheetContainer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
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
            const SizedBox(height: 44),
            AppButton(
              text: 'Cancel Trip',
              variant: AppButtonVariant.destructive,
              customHeight: 50,
              borderRadius: 16,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    );
  }
}

/// Functional Edit Trip sheet for Organizer to update trip details.
class EditTripSheet extends StatefulWidget {
  final TripModel trip;

  const EditTripSheet({super.key, required this.trip});

  static Future<TripModel?> show(BuildContext context, TripModel trip) {
    return showModalBottomSheet<TripModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditTripSheet(trip: trip),
    );
  }

  @override
  State<EditTripSheet> createState() => _EditTripSheetState();
}

class _EditTripSheetState extends State<EditTripSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _destinationController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;
  late final TextEditingController _meetingPlaceController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.trip.name);
    _destinationController =
        TextEditingController(text: widget.trip.destination);
    _startDateController = TextEditingController(text: widget.trip.startDate);
    _endDateController = TextEditingController(text: widget.trip.endDate);
    _meetingPlaceController =
        TextEditingController(text: widget.trip.meetingPlace);
    _descriptionController =
        TextEditingController(text: widget.trip.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _meetingPlaceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final destination = _destinationController.text.trim();
    final startDate = _startDateController.text.trim();
    final endDate = _endDateController.text.trim();
    final meetingPlace = _meetingPlaceController.text.trim();
    final description = _descriptionController.text.trim();

    final updated = widget.trip.copyWith(
      name: name.isNotEmpty ? name : widget.trip.name,
      destination:
          destination.isNotEmpty ? destination : widget.trip.destination,
      startDate: startDate.isNotEmpty ? startDate : widget.trip.startDate,
      endDate: endDate.isNotEmpty ? endDate : widget.trip.endDate,
      fullDateRange:
          '${startDate.isNotEmpty ? startDate : widget.trip.startDate} - ${endDate.isNotEmpty ? endDate : widget.trip.endDate}',
      meetingPlace:
          meetingPlace.isNotEmpty ? meetingPlace : widget.trip.meetingPlace,
      description: description,
    );

    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: _NeoBottomSheetContainer(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.semanticYellow,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppColors.secondaryDark,
                            width: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Edit Trip',
                        style: AppTypography.h2.copyWith(
                          color: AppColors.secondaryDark,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  _CloseSquareButton(onTap: () => Navigator.of(context).pop()),
                ],
              ),
              const SizedBox(height: 16),
              _buildField('Trip Name', _nameController),
              const SizedBox(height: 12),
              _buildField('Destination', _destinationController),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildField('Start Date', _startDateController)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField('End Date', _endDateController)),
                ],
              ),
              const SizedBox(height: 12),
              _buildField('Meeting Location', _meetingPlaceController),
              const SizedBox(height: 12),
              _buildField('About This Trip', _descriptionController, maxLines: 3),
              const SizedBox(height: 20),
              AppButton(
                text: 'Save Changes',
                variant: AppButtonVariant.primaryNavy,
                customHeight: 48,
                borderRadius: 14,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.inputLabel.copyWith(
            fontSize: 13,
            color: AppColors.secondaryDark,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.secondaryLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.secondaryDark, width: 1.8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.secondaryDark,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
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
