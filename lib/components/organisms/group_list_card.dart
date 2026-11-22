import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/group_models.dart';
import '../atoms/app_avatar.dart';

/// One group in the Groups list (05.01).
/// Recipe: orange photo square + name / organizer / role + member tokens
/// + "Next: trip" pill.
class GroupListCard extends StatelessWidget {
  final GroupSummary group;
  final VoidCallback onTap;

  const GroupListCard({super.key, required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final extra = group.memberNames.length - 4;

    return Semantics(
      button: true,
      container: true,
      label: '${group.name}, ${group.role.label}',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
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
                width: 105,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.secondaryDark, width: 2),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.h4.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (group.organizerName.isNotEmpty)
                      Text(
                        group.organizerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.carla,
                        ),
                      ),
                    Text(
                      group.role.label,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.shayne,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AppMemberTokenCluster(
                      size: 20,
                      extraCount: extra > 0 ? extra : 0,
                    ),
                    if (group.nextTripTitle != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.nextTripPill,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Next: ${group.nextTripTitle}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primaryNavy,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
