import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../theme/app_theme.dart';

/// A small tappable edit icon button.
///
/// Used in the Review step of the Create Group flow beside
/// Group Name, Description, and Group Members sections.
class EditButton extends StatelessWidget {
  const EditButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        // Generous tap target while keeping visual size small.
        padding: const EdgeInsets.all(6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Iconsax.edit_2,
              size: 16,
              color: AppColors.primaryText,
            ),
            SizedBox(width: 4),
            Text(
              'Edit',
              style: TextStyle(
                fontFamily: AppFonts.urbanist,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
