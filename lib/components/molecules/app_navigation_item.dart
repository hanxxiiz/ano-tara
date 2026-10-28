import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../atoms/app_icon.dart';
import '../atoms/app_text.dart';

/// Reusable Navigation Item molecule built from shared atoms (AppIcon + AppText).
/// Enforces >= 44x44px tap target and highlights the active tab in #144885.
class AppNavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const AppNavigationItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isSelected ? AppColors.primaryNavy : AppColors.shayne;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcon(
                icon,
                key: ValueKey('nav_item_${label}_$isSelected'),
                color: color,
                size: 25,
              ),
              const SizedBox(height: 4),
              AppText(
                label,
                variant: AppTextVariant.caption,
                color: color,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 11,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
