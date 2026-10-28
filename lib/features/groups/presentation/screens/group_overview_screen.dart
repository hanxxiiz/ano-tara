import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../components/atoms/app_button.dart';

class GroupOverviewScreen extends StatelessWidget {
  final String groupName;
  final int memberCount;
  final String activeTrip;

  const GroupOverviewScreen({
    super.key,
    this.groupName = 'The Group',
    this.memberCount = 6,
    this.activeTrip = 'Bantayan Trip (Oct 10 - Oct 15)',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: AppColors.chucky, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          groupName,
          style: AppTypography.titleLarge.copyWith(color: AppColors.chucky),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.more, color: AppColors.chucky),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Group Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.semanticYellowLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.chucky, width: 2.0),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.chucky,
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.semanticYellow,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.chucky, width: 2.0),
                          ),
                          child: const Icon(
                            Iconsax.people,
                            color: AppColors.primaryOrange,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                groupName,
                                style: AppTypography.h3.copyWith(
                                  color: AppColors.chucky,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$memberCount active members',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.carla,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.chucky, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Iconsax.calendar_1, size: 16, color: AppColors.primaryOrange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Current Trip: $activeTrip',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.chucky,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Group Members Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Members ($memberCount)',
                    style: AppTypography.titleLarge.copyWith(color: AppColors.chucky),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Iconsax.add, size: 18, color: AppColors.primaryNavy),
                    label: Text(
                      'Invite',
                      style: AppTypography.buttonMedium.copyWith(
                        color: AppColors.primaryNavy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Member items
              _buildMemberTile(name: 'Louie Abella', role: 'Organizer', isYou: true),
              const SizedBox(height: 10),
              _buildMemberTile(name: 'Sarah Jenkins', role: 'Member', status: 'Available'),
              const SizedBox(height: 10),
              _buildMemberTile(name: 'Carla Santos', role: 'Member', status: 'Available'),
              const SizedBox(height: 10),
              _buildMemberTile(name: 'Mark Lim', role: 'Member', status: 'Pending RSVP'),
              const SizedBox(height: 10),
              _buildMemberTile(name: 'Jenny Tan', role: 'Member', status: 'Pending RSVP'),
              const SizedBox(height: 10),
              _buildMemberTile(name: 'Dave Bautista', role: 'Member', status: 'Pending RSVP'),

              const SizedBox(height: 28),

              // Action Buttons
              AppButton(
                text: 'Plan a Trip with This Group',
                variant: AppButtonVariant.primaryNavy,
                iconLeading: const Icon(Iconsax.add, color: AppColors.white, size: 20),
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    '/plan-trip',
                    arguments: groupName,
                  );
                },
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'View Group Availability',
                variant: AppButtonVariant.secondary,
                iconLeading: const Icon(Iconsax.calendar, color: AppColors.chucky, size: 20),
                onPressed: () {},
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberTile({
    required String name,
    required String role,
    bool isYou = false,
    String? status,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.chucky, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.chucky,
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isYou ? AppColors.primaryNavy : AppColors.secondaryLight,
            child: Text(
              name.substring(0, 1),
              style: TextStyle(
                color: isYou ? AppColors.white : AppColors.chucky,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: AppTypography.titleMedium.copyWith(color: AppColors.chucky),
                    ),
                    if (isYou) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryNavy,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'You',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  role,
                  style: AppTypography.caption.copyWith(color: AppColors.shayne),
                ),
              ],
            ),
          ),
          if (status != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: status.contains('Pending')
                    ? AppColors.semanticYellowLight
                    : AppColors.semanticGreenLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: status.contains('Pending')
                      ? AppColors.semanticYellow
                      : AppColors.semanticGreen,
                  width: 1.0,
                ),
              ),
              child: Text(
                status,
                style: AppTypography.caption.copyWith(
                  color: status.contains('Pending')
                      ? const Color(0xFFB45309)
                      : AppColors.semanticGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
