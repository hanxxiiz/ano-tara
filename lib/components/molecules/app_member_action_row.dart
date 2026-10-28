import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../atoms/app_avatar.dart';
import '../atoms/app_icon.dart';
import '../atoms/app_text.dart';

/// M04 Member action row molecule matching Figma "02 Molecules" and "03 Organisms (O05)":
/// Recipe: A06 Avatar + A01 Member name + A02 Action icon.
class AppMemberActionRow extends StatelessWidget {
  final String name;
  final VoidCallback? onActionTap;

  const AppMemberActionRow({
    super.key,
    required this.name,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondaryDark, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.secondaryDark,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          AppAvatar.singleUser(size: 50),
          const SizedBox(width: 14),
          Expanded(
            child: AppText(
              name,
              variant: AppTextVariant.titleMedium,
              color: AppColors.secondaryDark,
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onActionTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
              child: const Center(
                child: AppIcon(
                  Iconsax.login5,
                  color: AppColors.primaryOrange,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
