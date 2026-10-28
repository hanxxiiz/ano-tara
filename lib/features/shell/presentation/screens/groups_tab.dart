import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../components/atoms/app_avatar.dart';
import '../../../../components/atoms/app_badge.dart';
import '../../../../components/organisms/app_top_bar.dart';
import '../../../../components/organisms/availability_panel.dart';
import '../../../../components/organisms/member_panel.dart';

class GroupsTab extends StatelessWidget {
  const GroupsTab({super.key});

  @override
  Widget build(BuildContext context) {
    const List<MemberData> members = [
      MemberData(
        id: '1',
        name: 'Louie Abella',
        role: 'Organizer',
        availableDays: ['Fri', 'Sat', 'Sun'],
        isCurrentUser: true,
      ),
      MemberData(
        id: '2',
        name: 'Carla Santos',
        role: 'Member',
        availableDays: ['Mon', 'Tue', 'Fri'],
      ),
      MemberData(
        id: '3',
        name: 'Ann Reyes',
        role: 'Member',
        availableDays: ['Wed', 'Thu', 'Sat', 'Sun'],
      ),
      MemberData(
        id: '4',
        name: 'Shayne Dela Cruz',
        role: 'Member',
        availableDays: ['Sat', 'Sun'],
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        showBackButton: false,
        title: 'Bantayan Squad',
        subtitle: '4 active members',
        actions: [
          IconButton(
            icon: const Icon(Iconsax.user_add, color: AppColors.primaryNavy),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.createGroup);
            },
            splashRadius: 22,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group Summary Card matching Figma Group 1850.pdf
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: AppRadii.radiusXl,
                  border: Border.all(color: AppColors.borderLight, width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bantayan Squad',
                          style: AppTypography.titleLarge.copyWith(color: AppColors.chucky),
                        ),
                        const AppAvatarGroup(
                          names: ['Louie', 'Carla', 'Ann', 'Shayne'],
                          maxVisible: 3,
                          avatarSize: 30,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Iconsax.calendar, size: 14, color: AppColors.primaryOrange),
                        const SizedBox(width: 6),
                        Text(
                          'Next: Bantayan Trip',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        const AppBadge(
                          label: 'Organizer: Louie',
                          variant: AppBadgeVariant.neutralCarla,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Group Availability Panel Organism
              Text(
                'Weekly Free Time Sync',
                style: AppTypography.titleLarge.copyWith(color: AppColors.chucky),
              ),
              const SizedBox(height: 10),
              const AvailabilityPanel(
                freeCount: 4,
                title: 'Squad Availability',
                memberNames: ['Louie', 'Carla', 'Ann', 'Shayne'],
              ),
              const SizedBox(height: 24),

              // Member Panel List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Squad Members (4)',
                    style: AppTypography.titleLarge.copyWith(color: AppColors.chucky),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.createGroup);
                    },
                    icon: const Icon(Iconsax.add, size: 16, color: AppColors.primaryOrange),
                    label: Text(
                      'Invite',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              for (final member in members) ...[
                MemberPanel(
                  member: member,
                  onTap: () {},
                  onMorePressed: () {},
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
