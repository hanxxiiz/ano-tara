import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/trip_participant.dart';
import '../../theme/app_theme.dart' show AppFonts;
import '../atoms/app_button.dart';

/// Opens the "Filter By" bottom sheet for filtering invitation responses.
/// Matches Figma "07.08 · Trip participants — response filter.png".
Future<TripResponseFilter?> showResponseFilterSheet({
  required BuildContext context,
  required TripResponseFilter currentFilter,
}) {
  return showModalBottomSheet<TripResponseFilter>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: AppColors.secondaryDark.withValues(alpha: 0.35),
    builder: (sheetContext) {
      return _ResponseFilterSheet(initialFilter: currentFilter);
    },
  );
}

class _ResponseFilterSheet extends StatefulWidget {
  final TripResponseFilter initialFilter;

  const _ResponseFilterSheet({required this.initialFilter});

  @override
  State<_ResponseFilterSheet> createState() => _ResponseFilterSheetState();
}

class _ResponseFilterSheetState extends State<_ResponseFilterSheet> {
  late TripResponseFilter _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialFilter;
  }

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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 46,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryDark,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header row: "Filter By" + X button
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Filter By',
                      style: TextStyle(
                        fontFamily: AppFonts.urbanist,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondaryDark,
                      ),
                    ),
                  ),
                  _SheetCloseButton(
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Filter radio options
              for (final option in TripResponseFilter.values) ...[
                _FilterOptionRow(
                  label: option.label,
                  selected: _selected == option,
                  onTap: () => setState(() => _selected = option),
                ),
                const SizedBox(height: 6),
              ],
              const SizedBox(height: 10),

              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.ann,
              ),
              const SizedBox(height: 18),

              // Bottom Reset + Apply buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Reset',
                      variant: AppButtonVariant.secondary,
                      borderRadius: 16,
                      customHeight: 48,
                      onPressed: () {
                        setState(() => _selected = TripResponseFilter.all);
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: AppButton(
                      text: 'Apply',
                      variant: AppButtonVariant.primaryNavy,
                      borderRadius: 16,
                      customHeight: 48,
                      onPressed: () {
                        Navigator.of(context).pop(_selected);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterOptionRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterOptionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFDE89A) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: selected
              ? Border.all(color: AppColors.secondaryDark, width: 1.8)
              : Border.all(color: Colors.transparent, width: 1.8),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: AppColors.secondaryDark,
                    offset: Offset(0, 2),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white,
                border: Border.all(
                  color: AppColors.secondaryDark,
                  width: 1.8,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.secondaryDark,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.urbanist,
                fontSize: 15,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: AppColors.secondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetCloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SheetCloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        child: Center(
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.secondaryDark, width: 2.0),
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
    );
  }
}
