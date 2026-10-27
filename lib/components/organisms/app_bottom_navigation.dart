import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_typography.dart';

enum AppTab {
  home,
  trips,
  create,
  groups,
  profile,
}

/// Bottom Navigation Bar organism matching Figma "Navigation Bar.pdf".
/// All tabs have guaranteed >= 44x44 tap targets and clear active states.
class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.chucky.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(color: AppColors.borderLight, width: 1.0),
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
                label: 'Home',
                icon: Iconsax.home_2,
                activeIcon: Iconsax.home_15,
              ),
              _buildNavItem(
                index: 1,
                label: 'Trips',
                icon: Iconsax.routing_2,
                activeIcon: Iconsax.routing,
              ),
              _buildCreateItem(
                index: 2,
              ),
              _buildNavItem(
                index: 3,
                label: 'Groups',
                icon: Iconsax.people,
                activeIcon: Iconsax.profile_2user,
              ),
              _buildNavItem(
                index: 4,
                label: 'Profile',
                icon: Iconsax.user,
                activeIcon: Iconsax.profile_tick,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final bool isSelected = currentIndex == index;
    final Color color = isSelected ? AppColors.primaryNavy : AppColors.shayne;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTabSelected(index),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: color,
                  size: 22,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: color,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateItem({required int index}) {
    final bool isSelected = currentIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTabSelected(index),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
            child: Center(
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryNavy : AppColors.primaryOrange,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isSelected ? AppColors.primaryNavy : AppColors.primaryOrange)
                          .withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Iconsax.add,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
