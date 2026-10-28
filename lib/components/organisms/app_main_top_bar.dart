import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../atoms/app_icon.dart';

/// Reusable non-scrollable top navigation bar matching Ano Tara Figma designs.
/// Pinned at the top of Scaffold so profile, notifications, and settings NEVER scroll with page content.
/// Uses Iconsax icons throughout.
class AppMainTopBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSettingsTap;
  final bool hasUnreadNotifications;
  final Color backgroundColor;

  const AppMainTopBar({
    super.key,
    this.showBackButton = false,
    this.onBackPressed,
    this.onProfileTap,
    this.onNotificationTap,
    this.onSettingsTap,
    this.hasUnreadNotifications = false,
    this.backgroundColor = AppColors.white,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Either Back button OR Solid Dark Ink Profile Circle (matching Figma)
          if (showBackButton)
            GestureDetector(
              onTap: onBackPressed ?? () => Navigator.of(context).maybePop(),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.arrow_left,
                  color: AppColors.secondaryDark,
                  size: 26,
                ),
              ),
            )
          else
            GestureDetector(
              onTap: onProfileTap ??
                  () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).maybePop();
                    }
                  },
              child: Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryDark,
                  shape: BoxShape.circle,
                ),
              ),
            ),

          // Right: Notification Bell & Settings Gear (Solid/Bold Iconsax)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onNotificationTap ??
                    () {
                      Navigator.pushNamed(context, AppRoutes.invitations);
                    },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const AppIcon(
                          Iconsax.notification5,
                          color: AppColors.secondaryDark,
                          size: 26,
                        ),
                        if (hasUnreadNotifications)
                          Positioned(
                            right: 1,
                            top: 1,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryOrange,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onSettingsTap ?? () {},
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: const Center(
                    child: AppIcon(
                      Iconsax.setting_25,
                      color: AppColors.secondaryDark,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
