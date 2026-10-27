import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_typography.dart';

enum AppBadgeVariant {
  primaryNavy,
  primaryOrange,
  tierYellow,
  neutralCarla,
  neutralLight,
  semanticRed,
  semanticGreen,
}

/// Badge atom for tier badges (e.g. "Plus"), counters ("+3", "7 free"), and status tags.
class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeVariant variant;
  final Widget? icon;
  final VoidCallback? onTap;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.neutralLight,
    this.icon,
    this.onTap,
  });

  factory AppBadge.tierPlus() {
    return const AppBadge(
      label: 'Plus',
      variant: AppBadgeVariant.tierYellow,
    );
  }

  factory AppBadge.counter(String count) {
    return AppBadge(
      label: count,
      variant: AppBadgeVariant.neutralCarla,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (variant) {
      case AppBadgeVariant.primaryNavy:
        bg = AppColors.primaryNavy;
        fg = AppColors.white;
        break;
      case AppBadgeVariant.primaryOrange:
        bg = AppColors.primaryOrange;
        fg = AppColors.white;
        break;
      case AppBadgeVariant.tierYellow:
        bg = AppColors.semanticYellow;
        fg = AppColors.chucky;
        break;
      case AppBadgeVariant.neutralCarla:
        bg = AppColors.carla;
        fg = AppColors.white;
        break;
      case AppBadgeVariant.neutralLight:
        bg = AppColors.surfaceMuted;
        fg = AppColors.carla;
        border = const BorderSide(color: AppColors.borderLight, width: 1);
        break;
      case AppBadgeVariant.semanticRed:
        bg = AppColors.semanticRedLight;
        fg = AppColors.semanticRed;
        break;
      case AppBadgeVariant.semanticGreen:
        bg = AppColors.semanticGreenLight;
        fg = AppColors.semanticGreen;
        break;
    }

    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.radiusPill,
        border: border != BorderSide.none ? Border.fromBorderSide(border) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.badge.copyWith(color: fg),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: AppRadii.radiusPill,
        child: badge,
      );
    }

    return badge;
  }
}
