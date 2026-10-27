import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

/// Avatar atom for displaying user pictures or initials, plus stacked avatar groups.
class AppAvatar extends StatelessWidget {
  final String? name;
  final String? imageUrl;
  final double size;
  final Color backgroundColor;
  final Color textColor;

  const AppAvatar({
    super.key,
    this.name,
    this.imageUrl,
    this.size = 40.0,
    this.backgroundColor = AppColors.primaryNavyLight,
    this.textColor = AppColors.primaryNavy,
  });

  String _getInitials() {
    if (name == null || name!.trim().isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: Border.all(color: AppColors.white, width: 2.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Center(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildFallback(),
              )
            : _buildFallback(),
      ),
    );
  }

  Widget _buildFallback() {
    if (name != null && name!.trim().isNotEmpty) {
      return Text(
        _getInitials(),
        style: AppTypography.buttonMedium.copyWith(
          color: textColor,
          fontSize: size * 0.38,
        ),
      );
    }
    return Icon(
      Iconsax.user,
      size: size * 0.5,
      color: textColor,
    );
  }
}

/// Stacked avatars atom showing overlapping avatars and a "+X" overflow indicator.
class AppAvatarGroup extends StatelessWidget {
  final List<String> names;
  final int maxVisible;
  final double avatarSize;

  const AppAvatarGroup({
    super.key,
    required this.names,
    this.maxVisible = 3,
    this.avatarSize = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    final visibleCount = names.length > maxVisible ? maxVisible : names.length;
    final overflow = names.length - visibleCount;

    final avatarColors = [
      (AppColors.primaryNavyLight, AppColors.primaryNavy),
      (AppColors.primaryOrangeLight, AppColors.primaryOrange),
      (AppColors.semanticYellowLight, AppColors.chucky),
      (AppColors.surfaceMuted, AppColors.carla),
    ];

    return SizedBox(
      height: avatarSize,
      width: (visibleCount * (avatarSize * 0.72)) + (overflow > 0 ? avatarSize * 0.8 : avatarSize * 0.28),
      child: Stack(
        children: [
          for (int i = 0; i < visibleCount; i++)
            Positioned(
              left: i * (avatarSize * 0.72),
              child: AppAvatar(
                name: names[i],
                size: avatarSize,
                backgroundColor: avatarColors[i % avatarColors.length].$1,
                textColor: avatarColors[i % avatarColors.length].$2,
              ),
            ),
          if (overflow > 0)
            Positioned(
              left: visibleCount * (avatarSize * 0.72),
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.carla,
                  border: Border.all(color: AppColors.white, width: 2.0),
                ),
                child: Center(
                  child: Text(
                    '+$overflow',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: avatarSize * 0.35,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
