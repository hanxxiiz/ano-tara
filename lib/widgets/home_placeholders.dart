import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// ============================================================================
// COMPONENT PLACEHOLDERS
// These placeholders represent existing or in-progress components.
// They preserve exact layout, dimensions, styling, and visual structure
// until the actual reusable components are integrated.
// ============================================================================

/// Topbar Placeholder
/// Reserved height: ~56-60px
/// Reserved layout: Avatar on the left, notifications and settings on the right.
class TopbarPlaceholder extends StatelessWidget implements PreferredSizeWidget {
  const TopbarPlaceholder({
    super.key,
    this.onAvatarTap,
    this.onNotificationTap,
    this.onSettingsTap,
  });

  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSettingsTap;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryBackground,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.pagePaddingHorizontal,
        vertical: 10,
      ),
      child: Row(
        children: [
          // Left Avatar Placeholder
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.primaryDarkAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Spacer(),
          // Notification Bell
          IconButton(
            onPressed: onNotificationTap,
            icon: const Icon(
              Icons.notifications_rounded,
              color: AppColors.primaryDarkAccent,
              size: 24,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          const SizedBox(width: 12),
          // Settings Gear
          IconButton(
            onPressed: onSettingsTap,
            icon: const Icon(
              Icons.settings_rounded,
              color: AppColors.primaryDarkAccent,
              size: 24,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}

/// Button Placeholder
/// Used for prominent action buttons such as "Plan a Trip" on the promotional banner.
class ButtonPlaceholder extends StatelessWidget {
  const ButtonPlaceholder({
    super.key,
    required this.label,
    this.onPressed,
    this.backgroundColor = AppColors.primaryBlue,
    this.textColor = Colors.white,
    this.height = 42,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryDarkAccent,
          width: AppTokens.borderWidth,
        ),
        boxShadow: AppTokens.hardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Groups Tile Placeholder
/// Square tile representing a group travel circle (e.g. "The Group", "Blackpink").
class GroupsTilePlaceholder extends StatelessWidget {
  const GroupsTilePlaceholder({
    super.key,
    required this.name,
    this.backgroundColor = AppColors.groupsTileBg,
    this.iconColor = AppColors.promotionalBanner,
    this.icon = Icons.groups_rounded,
    this.onTap,
  });

  final String name;
  final Color backgroundColor;
  final Color iconColor;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 82,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Square Tile Box
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.primaryDarkAccent,
                  width: AppTokens.borderWidth,
                ),
                boxShadow: AppTokens.hardShadow,
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Group Name
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Upcoming Trips Tile Placeholder
/// Full-width card with destination cover photo, trip details, and navigation arrow.
class UpcomingTripsTilePlaceholder extends StatelessWidget {
  const UpcomingTripsTilePlaceholder({
    super.key,
    required this.destination,
    required this.location,
    required this.group,
    required this.dates,
    this.imageUrl,
    this.onTap,
  });

  final String destination;
  final String location;
  final String group;
  final String dates;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.circular(AppTokens.cardRadius),
          border: Border.all(
            color: AppColors.primaryDarkAccent,
            width: AppTokens.borderWidth,
          ),
          boxShadow: AppTokens.hardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cover Image Area
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl != null && imageUrl!.isNotEmpty)
                    Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildBeachPlaceholder(),
                    )
                  else
                    _buildBeachPlaceholder(),
                  // Bottom border separating image from content
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      color: AppColors.primaryDarkAccent,
                    ),
                  ),
                ],
              ),
            ),
            // Trip Details & Navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          destination,
                          style: const TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _buildMetaRow(Icons.location_on, location),
                        const SizedBox(height: 3),
                        _buildMetaRow(Icons.group, group),
                        const SizedBox(height: 3),
                        _buildMetaRow(Icons.calendar_month, dates),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Navigation Arrow
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.primaryDarkAccent,
                    size: 24,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.primaryBlue,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Graceful, visually accurate beach illustration fallback when offline
  Widget _buildBeachPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF388E3C), // coastal trees / vegetation
            Color(0xFFF3E5AB), // white sandbar
            Color(0xFF4DD0E1), // turquoise tropical water
            Color(0xFF0097A7), // deep azure ocean
          ],
          stops: [0.0, 0.35, 0.65, 1.0],
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryDarkAccent.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Aerial Beach View',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Action Needed Tile Placeholder
/// White card with colored icon badge, title, descriptive message, and trailing arrow.
class ActionNeededTilePlaceholder extends StatelessWidget {
  const ActionNeededTilePlaceholder({
    super.key,
    required this.title,
    required this.description,
    required this.badgeColor,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String description;
  final Color badgeColor;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.circular(AppTokens.cardRadius),
          border: Border.all(
            color: AppColors.primaryDarkAccent,
            width: AppTokens.borderWidth,
          ),
          boxShadow: AppTokens.hardShadow,
        ),
        child: Row(
          children: [
            // Colored Icon Badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primaryDarkAccent,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Title and Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Trailing Chevron
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primaryDarkAccent,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

/// Navbar Placeholder
/// Fixed bottom navigation bar with 5 destinations: Home, Trips, Create (+), Groups, Profile.
class NavbarPlaceholder extends StatelessWidget {
  const NavbarPlaceholder({
    super.key,
    this.selectedIndex = 0,
    this.onItemSelected,
    this.onCreatePressed,
  });

  final int selectedIndex;
  final ValueChanged<int>? onItemSelected;
  final VoidCallback? onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        border: Border(
          top: BorderSide(
            color: AppColors.primaryDarkAccent.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: 'Home',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.send_rounded,
                label: 'Trips',
              ),
              // Center Action Button (+)
              GestureDetector(
                onTap: onCreatePressed,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryDarkAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.groups_rounded,
                label: 'Groups',
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.person_rounded,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = selectedIndex == index;
    final color = isSelected ? AppColors.primaryBlue : const Color(0xFF7E7A90);

    return Expanded(
      child: InkWell(
        onTap: () => onItemSelected?.call(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
