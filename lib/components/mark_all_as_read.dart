import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// MarkAllAsRead component
///
/// Compact horizontal container with light gray background, dark navy border,
/// rounded corners, custom checkbox on the left, and "Mark all as read" label.
class MarkAllAsRead extends StatelessWidget {
  const MarkAllAsRead({
    super.key,
    required this.checked,
    required this.onChanged,
    this.label = 'Mark all as read',
  });

  final bool checked;
  final ValueChanged<bool> onChanged;
  final String label;

  static const Color backgroundColor = Color(0xFFE9E7E7);
  static const Color darkNavy = Color(0xFF10052F);
  static const Color primaryBlue = Color(0xFF164D91);
  static const Color textColor = Color(0xFF0F0331);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!checked),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: darkNavy,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Checkbox on the left
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: checked ? primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: darkNavy,
                  width: 1.5,
                ),
              ),
              child: checked
                  ? const Center(
                      child: Icon(
                        Icons.check_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            // Label in Open Sans
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppFonts.openSans,
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
