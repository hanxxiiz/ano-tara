import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
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
  organizer,
}

enum RsvpStatus {
  going,
  maybe,
  notGoing,
  pending,
}

/// Badge atom matching Figma "Badges & status" specification:
/// Supports organizer pill, counters, tier badges, and RSVP status tiles.
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

  factory AppBadge.organizer() {
    return const AppBadge(
      label: 'Organizer',
      variant: AppBadgeVariant.organizer,
    );
  }

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
      case AppBadgeVariant.organizer:
        bg = AppColors.secondaryDark;
        fg = AppColors.white;
        break;
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

/// Standalone RSVP status tile matching Figma "Badges & status" board:
/// Going (Navy), Maybe (Yellow), Not going (Orange), Pending (Grey/Purple).
class AppRsvpStatusTile extends StatelessWidget {
  final RsvpStatus status;
  final VoidCallback? onTap;

  const AppRsvpStatusTile({
    super.key,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color iconColor;
    String label;

    switch (status) {
      case RsvpStatus.going:
        bg = AppColors.primaryNavy;
        iconColor = AppColors.white;
        label = 'Going';
        break;
      case RsvpStatus.maybe:
        bg = AppColors.semanticYellow;
        iconColor = AppColors.secondaryDark;
        label = 'Maybe';
        break;
      case RsvpStatus.notGoing:
        bg = AppColors.primaryOrange;
        iconColor = AppColors.white;
        label = 'Not going';
        break;
      case RsvpStatus.pending:
        bg = const Color(0xFFC3C0CB);
        iconColor = AppColors.secondaryDark;
        label = 'Pending';
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.secondaryDark, width: 2.0),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.secondaryDark,
                  offset: Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Iconsax.user,
                color: iconColor,
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.secondaryDark,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
