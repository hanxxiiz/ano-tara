import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../theme/app_theme.dart';

/// InvitationFilter component
///
/// Compact filter button with bold Iconsax filter icon and selected status label.
/// Tapping opens a styled dropdown menu with:
/// - "All", "Pending", "Accepted", "Rejected" options
/// - Clean background without unnecessary blue highlight
/// - Dark navy border (2px) and rounded corners
class InvitationFilter extends StatelessWidget {
  const InvitationFilter({
    super.key,
    required this.selectedStatus,
    required this.onChanged,
  });

  final String selectedStatus;
  final ValueChanged<String> onChanged;

  static const Color darkNavy = Color(0xFF10052F);
  static const Color primaryBlue = Color(0xFF164D91);
  static const Color textColor = Color(0xFF0F0331);
  static const Color buttonBg = Color(0xFFE9E7E7);

  static const List<String> filterOptions = [
    'All',
    'Pending',
    'Accepted',
    'Rejected',
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.white,
          elevation: 6,
          shadowColor: darkNavy.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: darkNavy, width: 2),
          ),
        ),
      ),
      child: PopupMenuButton<String>(
        tooltip: '',
        padding: EdgeInsets.zero,
        offset: const Offset(0, 36),
        onSelected: (status) {
          if (status != selectedStatus) {
            onChanged(status);
          }
        },
        itemBuilder: (context) {
          return filterOptions.map((status) {
            return PopupMenuItem<String>(
              value: status,
              padding: EdgeInsets.zero,
              height: 38,
              child: Container(
                width: 120,
                height: 38,
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.centerLeft,
                child: Text(
                  status,
                  style: const TextStyle(
                    fontFamily: AppFonts.urbanist,
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600, // Urbanist Semibold
                  ),
                ),
              ),
            );
          }).toList();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: buttonBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: darkNavy,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bold Iconsax filter icon
              const Icon(
                Iconsax.filter5,
                size: 16,
                color: primaryBlue,
              ),
              const SizedBox(width: 8),
              // Selected status label in Urbanist Semibold
              Text(
                selectedStatus,
                style: const TextStyle(
                  fontFamily: AppFonts.urbanist,
                  color: textColor,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600, // Urbanist Semibold
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
