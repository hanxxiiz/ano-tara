import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/group_models.dart';
import '../atoms/app_avatar.dart';

/// Member row matching Figma "05.05 Group details — member list":
/// Recipe: Avatar + name + pending badge + handle + remove action.
/// The remove action only renders when [onRemove] is provided (organizers).
class GroupMemberCard extends StatelessWidget {
  final GroupMember member;
  final VoidCallback? onRemove;

  const GroupMemberCard({super.key, required this.member, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 82),
      padding: const EdgeInsets.fromLTRB(18, 12, 10, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.secondaryDark, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.secondaryDark,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 2),
            ),
            child: AppAvatar.singleUser(size: 52),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.isCurrentUser
                            ? '${member.name} (You)'
                            : member.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.secondaryDark,
                        ),
                      ),
                    ),
                    if (member.isPending) ...[
                      const SizedBox(width: 8),
                      const _PendingBadge(),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  member.handle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.secondaryDark,
                  ),
                ),
              ],
            ),
          ),
          if (onRemove != null)
            Semantics(
              button: true,
              label: 'Remove ${member.name}',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onRemove,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Iconsax.profile_delete,
                    size: 24,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PendingBadge extends StatelessWidget {
  const _PendingBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEA87),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Pending',
        style: AppTypography.badge.copyWith(
          color: AppColors.secondaryDark,
          fontSize: 10,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
