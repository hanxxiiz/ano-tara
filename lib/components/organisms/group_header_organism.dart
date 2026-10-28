import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../atoms/app_avatar.dart';
import '../atoms/app_button.dart';

/// O02 Group header organism matching Figma "03 Organisms" board:
/// Recipe: Avatar + identity + organizer badge + member count + CTA.
/// Accepts data as parameters for reusability across screens.
class GroupHeaderOrganism extends StatelessWidget {
  final String groupName;
  final String roleLabel;
  final int memberCount;
  final VoidCallback? onPlanTripTap;
  final bool showMemberTokens;
  final bool isLoading;

  const GroupHeaderOrganism({
    super.key,
    required this.groupName,
    this.roleLabel = 'Organizer',
    this.memberCount = 7,
    this.onPlanTripTap,
    this.showMemberTokens = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.semanticYellow,
        border: Border.all(color: AppColors.secondaryDark, width: 2.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Group Avatar Atom (86px orange circle with 2px border & hard shadow)
              AppAvatar.group(size: 86),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      groupName,
                      style: AppTypography.h3.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryDark,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        roleLabel,
                        style: AppTypography.badge.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (showMemberTokens) ...[
                      const AppMemberTokenCluster(extraCount: 3, size: 17),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      '$memberCount members',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppButton(
            text: 'Plan a Trip',
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.small,
            isLoading: isLoading,
            onPressed: onPlanTripTap ?? () {},
          ),
        ],
      ),
    );
  }
}
