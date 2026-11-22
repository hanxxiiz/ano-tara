import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_icon.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/itinerary_entry.dart';
import 'itinerary_widgets.dart';

/// Grey copy on the delete sheets (#635E6E).
const Color kItinerarySheetCopy = Color(0xFF635E6E);

/// Dashed "+ Add to Itinerary" tile under a day's entries (07.12).
class AddToItineraryTile extends StatelessWidget {
  final VoidCallback onTap;

  const AddToItineraryTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF666175);
    return Semantics(
      button: true,
      label: 'Add to Itinerary',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: CustomPaint(
          painter: const _DashedBorderPainter(
            color: AppColors.shayne,
            radius: 9,
          ),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.secondaryLight,
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Iconsax.add, size: 16, color: ink),
                const SizedBox(width: 8),
                Text(
                  'Add to Itinerary',
                  style: AppTypography.titleMedium.copyWith(
                    color: ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 4), paint);
        distance += 8;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}

/// Small lavender "Select" chip next to the Entries heading (07.12).
class ItinerarySelectChip extends StatelessWidget {
  final VoidCallback onTap;

  const ItinerarySelectChip({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Select entries',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Container(
            constraints: const BoxConstraints(minWidth: 75),
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFE7E0ED),
              borderRadius: BorderRadius.circular(5.5),
              border: Border.all(color: AppColors.secondaryDark),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Iconsax.tick_square,
                  size: 14,
                  color: AppColors.secondaryDark,
                ),
                const SizedBox(width: 6),
                Text(
                  'Select',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Round navy AI button floating over the entries list (07.12).
class ItineraryAiFab extends StatelessWidget {
  final VoidCallback onPressed;

  const ItineraryAiFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Generate with AI',
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 73,
          height: 73,
          decoration: BoxDecoration(
            color: AppColors.secondaryDark,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.secondaryDark, width: 2.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x80000000),
                offset: Offset(0, 8),
                blurRadius: 20,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const AppIcon(
            Iconsax.magic_star5,
            size: 30,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet confirming a deletion (07.14 / 07.15).
/// Resolves to `true` when the user taps Delete.
Future<bool> showDeleteEntriesSheet({
  required BuildContext context,
  required String title,
  required String message,
}) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _DeleteEntriesSheet(
      title: title,
      message: message,
    ),
  );
  return confirmed ?? false;
}

class _DeleteEntriesSheet extends StatelessWidget {
  final String title;
  final String message;

  const _DeleteEntriesSheet({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          top: BorderSide(color: AppColors.secondaryDark, width: 2),
          left: BorderSide(color: AppColors.secondaryDark, width: 2),
          right: BorderSide(color: AppColors.secondaryDark, width: 2),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, 14, 24, 28 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 45,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.secondaryDark,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ItinerarySquareIconButton(
              icon: Icons.close_rounded,
              semanticLabel: 'Close',
              background: AppColors.white,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ),
          const AppIcon(
            Iconsax.warning_25,
            size: 80,
            color: AppColors.primaryOrange,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.h2.copyWith(
              color: AppColors.secondaryDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: kItinerarySheetCopy,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 26),
          AppButton(
            text: 'Delete',
            variant: AppButtonVariant.primaryOrange,
            customHeight: 50,
            borderRadius: 16,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: 16),
          AppButton(
            text: 'Cancel',
            variant: AppButtonVariant.secondary,
            customHeight: 50,
            borderRadius: 16,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}

/// Form label with an orange asterisk when [required] ("Title*").
class ItineraryFieldLabel extends StatelessWidget {
  final String text;
  final bool required;

  const ItineraryFieldLabel(this.text, {super.key, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          text: text,
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.primaryOrange),
              ),
          ],
        ),
        style: AppTypography.titleMedium.copyWith(
          color: AppColors.secondaryDark,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}

IconData entryTypeIcon(ItineraryEntryType type) {
  switch (type) {
    case ItineraryEntryType.accommodation:
      return Iconsax.home_25;
    case ItineraryEntryType.activity:
      return Iconsax.sun_15;
    case ItineraryEntryType.dining:
      return Iconsax.reserve5;
  }
}

/// Accommodation / Activity / Dining option cards (07.16).
class EntryTypeSelector extends StatelessWidget {
  final ItineraryEntryType? selected;
  final ValueChanged<ItineraryEntryType> onChanged;

  const EntryTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final type in ItineraryEntryType.values) ...[
          if (type != ItineraryEntryType.values.first)
            const SizedBox(width: 14),
          Expanded(child: _TypeCard(
            type: type,
            selected: type == selected,
            onTap: () => onChanged(type),
          )),
        ],
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  final ItineraryEntryType type;
  final bool selected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.white : AppColors.secondaryDark;
    return Semantics(
      button: true,
      selected: selected,
      label: type.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 90,
          decoration: BoxDecoration(
            color: selected ? AppColors.secondaryDark : AppColors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.secondaryDark, width: 2),
            boxShadow: const [
              BoxShadow(
                color: AppColors.secondaryDark,
                offset: Offset(0, 2),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcon(entryTypeIcon(type), size: 28, color: foreground),
              const SizedBox(height: 10),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  type.label,
                  style: AppTypography.titleMedium.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Location block on the entry form (07.16): place name, area, rating,
/// a yellow "Change" button and "View in Map". Shows a search prompt when
/// no location is set yet.
class EntryLocationCard extends StatelessWidget {
  final String? placeName;
  final String? address;
  final double? rating;
  final VoidCallback onChoose;

  /// `null` hides "View in Map" (e.g. a custom place without coordinates).
  final VoidCallback? onViewInMap;

  const EntryLocationCard({
    super.key,
    required this.placeName,
    required this.address,
    required this.rating,
    required this.onChoose,
    required this.onViewInMap,
  });

  @override
  Widget build(BuildContext context) {
    final hasPlace = placeName != null && placeName!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryDark, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.secondaryDark,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: hasPlace ? _buildPlace() : _buildEmpty(),
    );
  }

  Widget _buildEmpty() {
    return Semantics(
      button: true,
      label: 'Search location',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChoose,
        child: Container(
          height: 74,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(5.25),
            border: Border.all(color: AppColors.secondaryDark, width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              const AppIcon(
                Iconsax.location_add5,
                size: 24,
                color: AppColors.primaryOrange,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add a location',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Search places or pick a top pick nearby',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.slate,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Iconsax.search_normal_1,
                size: 18,
                color: AppColors.secondaryDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlace() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 74),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(5.25),
            border: Border.all(color: AppColors.secondaryDark, width: 1.5),
          ),
          padding: const EdgeInsets.fromLTRB(10, 12, 9, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      placeName!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const AppIcon(
                          Iconsax.location5,
                          size: 14,
                          color: AppColors.primaryOrange,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            address ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.secondaryDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ChangeButton(onTap: onChoose),
            ],
          ),
        ),
        if (rating != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const AppIcon(
                Iconsax.star_15,
                size: 14,
                color: AppColors.semanticYellow,
              ),
              const SizedBox(width: 6),
              Text(
                '${rating!.toStringAsFixed(1)} stars',
                style: AppTypography.caption.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
        if (onViewInMap != null) ...[
          const SizedBox(height: 12),
          AppButton(
            text: 'View in Map',
            size: AppButtonSize.small,
            customHeight: 36,
            borderRadius: 11,
            iconTrailing: const Icon(
              Iconsax.arrow_right_1,
              size: 16,
              color: AppColors.white,
            ),
            onPressed: onViewInMap,
          ),
        ],
      ],
    );
  }
}

class _ChangeButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ChangeButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Change location',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 82,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.semanticYellow,
            borderRadius: BorderRadius.circular(5.25),
            border: Border.all(color: AppColors.secondaryDark, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: AppColors.secondaryDark,
                offset: Offset(0, 2),
                blurRadius: 0,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            'Change',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.secondaryDark,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
