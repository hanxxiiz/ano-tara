import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_typography.dart';
import '../atoms/app_avatar.dart';
import '../atoms/app_badge.dart';

class MemberData {
  final String id;
  final String name;
  final String role; // "Organizer", "Member", etc.
  final List<String> availableDays; // e.g. ["Mon", "Tue", "Fri"]
  final String? avatarUrl;
  final bool isCurrentUser;

  const MemberData({
    required this.id,
    required this.name,
    required this.role,
    this.availableDays = const [],
    this.avatarUrl,
    this.isCurrentUser = false,
  });
}

/// Member Card / Panel organism matching Figma "Member Card.pdf" & "Member Status.pdf".
class MemberPanel extends StatelessWidget {
  final MemberData member;
  final VoidCallback? onTap;
  final VoidCallback? onMorePressed;

  const MemberPanel({
    super.key,
    required this.member,
    this.onTap,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOrganizer = member.role.toLowerCase() == 'organizer';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.radiusLg,
        border: Border.all(color: AppColors.borderLight, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.radiusLg,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Avatar + Name + Role Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppAvatar(
                      name: member.name,
                      imageUrl: member.avatarUrl,
                      size: 44,
                      backgroundColor: isOrganizer
                          ? AppColors.primaryOrangeLight
                          : AppColors.primaryNavyLight,
                      textColor: isOrganizer
                          ? AppColors.primaryOrange
                          : AppColors.primaryNavy,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  member.name,
                                  style: AppTypography.titleMedium.copyWith(color: AppColors.chucky),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (member.isCurrentUser) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '(You)',
                                  style: AppTypography.caption.copyWith(color: AppColors.shayne),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            member.role,
                            style: AppTypography.caption.copyWith(
                              color: isOrganizer ? AppColors.primaryOrange : AppColors.carla,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onMorePressed != null)
                      IconButton(
                        icon: const Icon(Iconsax.more, color: AppColors.shayne, size: 20),
                        onPressed: onMorePressed,
                        splashRadius: 20,
                      )
                    else
                      AppBadge(
                        label: member.role,
                        variant: isOrganizer
                            ? AppBadgeVariant.primaryOrange
                            : AppBadgeVariant.neutralLight,
                      ),
                  ],
                ),

                // General Availability row matching Member Card.pdf
                if (member.availableDays.isNotEmpty) ...[
                  const Divider(height: 20),
                  Row(
                    children: [
                      Text(
                        'General Availability:',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.shayne,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: member.availableDays.map((day) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: AppRadii.radiusSm,
                                border: Border.all(color: AppColors.ann, width: 0.8),
                              ),
                              child: Text(
                                day,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.chucky,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
