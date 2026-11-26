import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Filter pill button matching Figma `04.01` and `04.02`.
///
/// Compact pill with light gray fill, dark navy border, horizontal sliders icon,
/// and "Filter" label. Tapping opens the corresponding filter bottom sheet modal.
class InvitationFilter extends StatelessWidget {
  const InvitationFilter({
    super.key,
    required this.onTap,
    this.label = 'Filter',
    this.hasActiveFilters = false,
  });

  final VoidCallback onTap;
  final String label;
  final bool hasActiveFilters;

  static const Color darkNavy = Color(0xFF10052F);
  static const Color textColor = Color(0xFF0F0331);
  static const Color buttonBg = Color(0xFFE9E7E7);
  static const Color activeDotColor = Color(0xFFE24B27);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: buttonBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: darkNavy,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.tune_rounded,
              size: 16,
              color: darkNavy,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppFonts.urbanist,
                color: textColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (hasActiveFilters) ...[
              const SizedBox(width: 6),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: activeDotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
