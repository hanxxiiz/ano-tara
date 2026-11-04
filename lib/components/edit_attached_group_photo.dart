import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../theme/app_theme.dart';

/// A small circular edit badge overlaid on the group photo.
///
/// Position it at the bottom-right of the circular photo using a [Stack].
class EditAttachedGroupPhoto extends StatelessWidget {
  const EditAttachedGroupPhoto({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 26,
        height: 26,
        decoration: const BoxDecoration(
          color: AppColors.primaryDark,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Iconsax.edit_2,
          size: 14,
          color: Colors.white,
        ),
      ),
    );
  }
}
