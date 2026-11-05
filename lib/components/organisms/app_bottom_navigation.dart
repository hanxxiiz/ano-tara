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
/// Features smooth scale and press feedback.
class AppBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  State<AppBottomNavigation> createState() => _AppBottomNavigationState();
}

class _AppBottomNavigationState extends State<AppBottomNavigation> {
  bool _isCreatePressed = false;

  Future<void> _handleCreateTapUp(int index) async {
    if (!_isCreatePressed) {
      setState(() => _isCreatePressed = true);
    }
    widget.onTabSelected(index);
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (mounted) {
      setState(() => _isCreatePressed = false);
    }
  }

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
                isSelected: widget.currentIndex == 0,
                onTap: () => widget.onTabSelected(0),
              ),
              AppNavigationItem(
                icon: Iconsax.send_25,
                label: 'Trips',
                isSelected: widget.currentIndex == 1,
                onTap: () => widget.onTabSelected(1),
              ),
              _buildCreateItem(index: 2),
              AppNavigationItem(
                icon: Iconsax.profile_2user5,
                label: 'Groups',
                isSelected: widget.currentIndex == 3,
                onTap: () => widget.onTabSelected(3),
              ),
              AppNavigationItem(
                icon: Iconsax.user5,
                label: 'Profile',
                isSelected: widget.currentIndex == 4,
                onTap: () => widget.onTabSelected(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateItem({required int index}) {
    final bool isSelected = widget.currentIndex == index || _isCreatePressed;
    return Expanded(
      child: Center(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _isCreatePressed = true),
          onTapUp: (_) => _handleCreateTapUp(index),
          onTapCancel: () => setState(() => _isCreatePressed = false),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
            child: AnimatedScale(
              scale: _isCreatePressed ? 0.90 : (isSelected ? 1.06 : 1.0),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryNavy
                      : AppColors.secondaryDark,
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
      ),
    );
  }
}
