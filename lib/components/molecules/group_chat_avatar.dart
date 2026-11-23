import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Circular group image with the existing group color as its fallback.
class GroupChatAvatar extends StatelessWidget {
  const GroupChatAvatar({
    super.key,
    required this.size,
    this.imageUrl,
    this.fallbackColor = AppColors.primaryOrange,
    this.borderWidth = 1.5,
  });

  final double size;
  final String? imageUrl;
  final Color fallbackColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final fallback = ColoredBox(color: fallbackColor);

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      foregroundDecoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.secondaryDark,
          width: borderWidth,
        ),
      ),
      child: ClipOval(
        child: SizedBox.expand(
          child: imageUrl == null
              ? fallback
              : Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => fallback,
                ),
        ),
      ),
    );
  }
}
