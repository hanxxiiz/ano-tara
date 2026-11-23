import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Filter pill button matching Figma `04.01` and `04.02`.
///
/// Compact pill with light gray fill, dark navy border, horizontal sliders icon,
/// and "Filter" label (or the active filter name when a non-'All' option is active).
class InvitationFilter extends StatelessWidget {
  const InvitationFilter({
    super.key,
    required this.selectedStatus,
    required this.onChanged,
    this.options = defaultOptions,
    this.defaultLabel = 'Filter',
  });

  final String selectedStatus;
  final ValueChanged<String> onChanged;
  final List<String> options;
  final String defaultLabel;

  static const Color darkNavy = Color(0xFF10052F);
  static const Color primaryBlue = Color(0xFF144885);
  static const Color textColor = Color(0xFF0F0331);
  static const Color buttonBg = Color(0xFFE9E7E7);

  static const List<String> defaultOptions = [
    'All',
    'Pending',
    'Accepted',
    'Declined',
  ];

  static const List<String> activityOptions = [
    'All',
    'Unread',
    'Read',
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDefault = selectedStatus.toLowerCase() == 'all';
    final String displayLabel = isDefault ? defaultLabel : selectedStatus;

    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.white,
          elevation: 6,
          shadowColor: darkNavy.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: darkNavy, width: 2),
          ),
        ),
      ),
      child: PopupMenuButton<String>(
        tooltip: '',
        padding: EdgeInsets.zero,
        offset: const Offset(0, 38),
        onSelected: (status) {
          if (status != selectedStatus) {
            onChanged(status);
          }
        },
        itemBuilder: (context) {
          return options.map((status) {
            final isSelected =
                status.toLowerCase() == selectedStatus.toLowerCase();
            return PopupMenuItem<String>(
              value: status,
              padding: EdgeInsets.zero,
              height: 40,
              child: Container(
                width: 136,
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        status,
                        style: TextStyle(
                          fontFamily: AppFonts.urbanist,
                          color: isSelected ? primaryBlue : textColor,
                          fontSize: 13.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: primaryBlue,
                      ),
                  ],
                ),
              ),
            );
          }).toList();
        },
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
                displayLabel,
                style: const TextStyle(
                  fontFamily: AppFonts.urbanist,
                  color: textColor,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
