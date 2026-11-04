import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../theme/app_theme.dart';

/// A card tile representing a person who has been selected to be invited.
///
/// Displays the person's avatar (or a yellow fallback), their [name] and
/// optional [subtitle], and a trash icon button on the right that calls
/// [onRemove] when tapped.
class SelectedPeopleTile extends StatelessWidget {
  const SelectedPeopleTile({
    super.key,
    required this.name,
    this.subtitle,
    this.imageUrl,
    this.onRemove,
  });

  /// Display name shown in bold.
  final String name;

  /// Optional subtitle, e.g. username handle.
  final String? subtitle;

  /// Optional network/asset avatar URL. Falls back to yellow initials circle.
  final String? imageUrl;

  /// Called when the trash icon is tapped.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTokens.cardDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // ── Avatar ───────────────────────────────────────────────────
          _Avatar(imageUrl: imageUrl, name: name),

          const SizedBox(width: 12),

          // ── Name + subtitle ──────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: AppFonts.urbanist,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.primaryText,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontFamily: AppFonts.urbanist,
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      color: AppColors.primaryText,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Trash icon ───────────────────────────────────────────────
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: const Icon(
                Iconsax.trash,
                size: 20,
                color: AppColors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared avatar widget (internal) ─────────────────────────────────────────
class _Avatar extends StatelessWidget {
  const _Avatar({this.imageUrl, required this.name});

  final String? imageUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    final initials =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl!,
          width: AppTokens.avatarSize,
          height: AppTokens.avatarSize,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _FallbackAvatar(initial: initials),
        ),
      );
    }
    return _FallbackAvatar(initial: initials);
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppTokens.avatarSize,
      height: AppTokens.avatarSize,
      decoration: const BoxDecoration(
        color: AppColors.yellow,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontFamily: AppFonts.urbanist,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
