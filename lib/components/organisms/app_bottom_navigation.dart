import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../molecules/app_navigation_item.dart';

enum AppTab {
  home,
  trips,
  create,
  groups,
  profile,
}

/// O01 Bottom Navigation Bar organism built from AppNavigationItem molecules.
/// Selected / Pressed tab uses AppColors.primaryNavy (#144885) and unselected uses AppColors.shayne (#868097).
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
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE8E6E3), width: 1.2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              AppNavigationItem(
                icon: Iconsax.home_15,
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => onTabSelected(0),
              ),
              AppNavigationItem(
                icon: Iconsax.send_25,
                label: 'Trips',
                isSelected: currentIndex == 1,
                onTap: () => onTabSelected(1),
              ),
              _buildCreateItem(index: 2),
              AppNavigationItem(
                icon: Iconsax.profile_2user5,
                label: 'Groups',
                isSelected: currentIndex == 3,
                onTap: () => onTabSelected(3),
              ),
              AppNavigationItem(
                icon: Iconsax.user5,
                label: 'Profile',
                isSelected: currentIndex == 4,
                onTap: () => onTabSelected(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateItem({required int index}) {
    final bool isSelected = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTabSelected(index),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
          child: Center(
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryNavy : AppColors.secondaryDark,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.add,
                color: AppColors.white,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
