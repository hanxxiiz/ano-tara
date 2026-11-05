import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../atoms/app_button.dart';
import '../atoms/app_icon.dart';
import '../../main.dart';
import '../../screens/auth/login_screen.dart';

/// Reusable non-scrollable top navigation bar matching Ano Tara Figma designs.
/// Pinned at the top of Scaffold so profile, notifications, and settings NEVER scroll with page content.
/// Uses Iconsax icons throughout.
/// Clicking Notification and Settings items uses the same transition and colors (#144885 primaryNavy
/// active/pressed, #868097 shayne idle, AnimatedScale + AnimatedSwitcher) as AppNavigationItem.
/// Back button also features a smooth press/slide/scale transition.
class AppMainTopBar extends StatefulWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSettingsTap;
  final bool hasUnreadNotifications;
  final bool isNotificationSelected;
  final bool isSettingsSelected;
  final Color backgroundColor;

  const AppMainTopBar({
    super.key,
    this.showBackButton = false,
    this.onBackPressed,
    this.onProfileTap,
    this.onNotificationTap,
    this.onSettingsTap,
    this.hasUnreadNotifications = false,
    this.isNotificationSelected = false,
    this.isSettingsSelected = false,
    this.backgroundColor = AppColors.white,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  State<AppMainTopBar> createState() => _AppMainTopBarState();
}

class _AppMainTopBarState extends State<AppMainTopBar> {
  bool _isBackPressed = false;
  bool _isProfilePressed = false;
  bool _isNotifPressed = false;
  bool _isSettingsPressed = false;
  int? _activeRightIndex; // 0 = notification, 1 = settings

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.secondaryDark, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: AppColors.secondaryDark,
                blurRadius: 0,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.secondaryDark.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Settings',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              AppButton(
                text: 'Log Out',
                variant: AppButtonVariant.destructive,
                iconLeading: const Icon(
                  Iconsax.logout,
                  color: AppColors.white,
                  size: 20,
                ),
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await supabase.auth.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleBackTapUp(BuildContext context) async {
    if (!_isBackPressed) {
      setState(() => _isBackPressed = true);
    }
    await Future<void>.delayed(const Duration(milliseconds: 130));
    if (mounted) {
      setState(() => _isBackPressed = false);
    }
    if (widget.onBackPressed != null) {
      widget.onBackPressed!();
    } else if (context.mounted) {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _handleProfileTapUp(BuildContext context) async {
    if (!_isProfilePressed) {
      setState(() => _isProfilePressed = true);
    }
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (mounted) {
      setState(() => _isProfilePressed = false);
    }
    if (widget.onProfileTap != null) {
      widget.onProfileTap!();
    } else if (context.mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _handleNotifTapUp(BuildContext context) async {
    setState(() {
      _isNotifPressed = true;
      _activeRightIndex = _activeRightIndex == 0 ? null : 0;
    });
    await Future<void>.delayed(const Duration(milliseconds: 140));
    if (mounted) {
      setState(() => _isNotifPressed = false);
    }
    if (widget.onNotificationTap != null) {
      widget.onNotificationTap!();
    }
  }

  Future<void> _handleSettingsTapUp(BuildContext context) async {
    setState(() {
      _isSettingsPressed = true;
      _activeRightIndex = _activeRightIndex == 1 ? null : 1;
    });
    await Future<void>.delayed(const Duration(milliseconds: 140));
    if (mounted) {
      setState(() => _isSettingsPressed = false);
    }
    if (widget.onSettingsTap != null) {
      widget.onSettingsTap!();
    } else if (context.mounted) {
      _showSettingsSheet(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool notifHighlighted = widget.isNotificationSelected ||
        _isNotifPressed ||
        _activeRightIndex == 0;
    final bool settingsHighlighted = widget.isSettingsSelected ||
        _isSettingsPressed ||
        _activeRightIndex == 1;

    final Color notifColor =
        notifHighlighted ? AppColors.primaryNavy : AppColors.shayne;
    final Color settingsColor =
        settingsHighlighted ? AppColors.primaryNavy : AppColors.shayne;

    return AppBar(
      backgroundColor: widget.backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Either Back button with press transition OR Solid Dark Ink Profile Circle
          if (widget.showBackButton)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => setState(() => _isBackPressed = true),
              onTapUp: (_) => _handleBackTapUp(context),
              onTapCancel: () => setState(() => _isBackPressed = false),
              child: AnimatedScale(
                scale: _isBackPressed ? 0.88 : 1.0,
                duration: Duration(milliseconds: _isBackPressed ? 90 : 220),
                curve: _isBackPressed ? Curves.easeOutQuad : Curves.elasticOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  width: 44,
                  height: 44,
                  transform: Matrix4.translationValues(
                    _isBackPressed ? -3.0 : 0.0,
                    0,
                    0,
                  ),
                  decoration: BoxDecoration(
                    color: _isBackPressed
                        ? AppColors.primaryNavyLight
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Iconsax.arrow_left,
                      color: _isBackPressed
                          ? AppColors.primaryNavy
                          : AppColors.secondaryDark,
                      size: 26,
                    ),
                  ),
                ),
              ),
            )
          else
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => setState(() => _isProfilePressed = true),
              onTapUp: (_) => _handleProfileTapUp(context),
              onTapCancel: () => setState(() => _isProfilePressed = false),
              child: AnimatedScale(
                scale: _isProfilePressed ? 0.90 : 1.0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _isProfilePressed
                        ? AppColors.primaryNavy
                        : AppColors.secondaryDark,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

          // Right: Notification Bell & Settings Gear with navbar-like transition & colors
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) => setState(() => _isNotifPressed = true),
                onTapUp: (_) => _handleNotifTapUp(context),
                onTapCancel: () => setState(() => _isNotifPressed = false),
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
                  child: AnimatedScale(
                    scale: _isNotifPressed
                        ? 0.90
                        : (notifHighlighted ? 1.08 : 1.0),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) =>
                                  ScaleTransition(
                                scale: Tween<double>(begin: 0.88, end: 1.0)
                                    .animate(animation),
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              ),
                              child: AppIcon(
                                Iconsax.notification5,
                                key: ValueKey('topbar_notif_$notifHighlighted'),
                                color: notifColor,
                                size: 26,
                              ),
                            ),
                            if (widget.hasUnreadNotifications)
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
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) => setState(() => _isSettingsPressed = true),
                onTapUp: (_) => _handleSettingsTapUp(context),
                onTapCancel: () => setState(() => _isSettingsPressed = false),
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
                  child: AnimatedScale(
                    scale: _isSettingsPressed
                        ? 0.90
                        : (settingsHighlighted ? 1.08 : 1.0),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(
                            scale: Tween<double>(begin: 0.88, end: 1.0)
                                .animate(animation),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          ),
                          child: AppIcon(
                            Iconsax.setting_25,
                            key: ValueKey(
                                'topbar_settings_$settingsHighlighted'),
                            color: settingsColor,
                            size: 26,
                          ),
                        ),
                      ),
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
