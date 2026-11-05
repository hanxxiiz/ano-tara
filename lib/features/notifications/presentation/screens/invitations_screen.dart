import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../components/atoms/app_button.dart';

class InvitationsScreen extends StatefulWidget {
  const InvitationsScreen({super.key});

  @override
  State<InvitationsScreen> createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  final List<Map<String, dynamic>> _invitations = [
    {
      'id': '1',
      'title': 'Siargao Cloud 9 Surf Getaway',
      'host': 'Alex Tan',
      'date': 'Dec 12 - Dec 16, 2026',
      'group': 'Island Surfers',
      'members': 5,
      'isGroupInvite': false,
    },
    {
      'id': '2',
      'title': 'Palawan Underground River Trek',
      'host': 'Chloe Lim',
      'date': 'Jan 15 - Jan 19, 2027',
      'group': 'Adventure Club',
      'members': 4,
      'isGroupInvite': false,
    },
    {
      'id': '3',
      'title': 'Baguio Pine Forest & Cafe Crawl',
      'host': 'Mark Santos',
      'date': 'Feb 06 - Feb 08, 2027',
      'group': 'Weekend Escapes',
      'members': 8,
      'isGroupInvite': false,
    },
    {
      'id': '4',
      'title': 'Manila Foodies Squad',
      'host': 'Bea Cruz',
      'date': 'Created 2 days ago',
      'group': 'Food & Nightlife Group',
      'members': 12,
      'isGroupInvite': true,
    },
    {
      'id': '5',
      'title': 'Cebu Backpackers Society',
      'host': 'Louie Abella',
      'date': 'Created yesterday',
      'group': 'Travel Enthusiasts',
      'members': 7,
      'isGroupInvite': true,
    },
  ];

  void _handleAccept(int index) {
    final item = _invitations[index];
    setState(() {
      _invitations.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Accepted invitation to ${item['title']}!'),
        backgroundColor: AppColors.primaryNavy,
      ),
    );
  }

  void _handleDecline(int index) {
    setState(() {
      _invitations.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invitation declined.'),
        backgroundColor: AppColors.carla,
      ),
    );
  }

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
          'Notifications → Invitations',
          style: AppTypography.titleLarge.copyWith(color: AppColors.chucky),
        ),
      ),
      body: SafeArea(
        child: _invitations.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primaryNavyLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.chucky, width: 2),
                        ),
                        child: const Icon(
                          Iconsax.notification_bing,
                          size: 32,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'All Caught Up!',
                        style: AppTypography.h3.copyWith(color: AppColors.chucky),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'You have responded to all pending invitations.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemCount: _invitations.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = _invitations[index];
                  final isGroup = item['isGroupInvite'] as bool;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(18),
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
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isGroup
                                    ? AppColors.semanticYellow
                                    : AppColors.primaryNavy,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.chucky, width: 1.5),
                              ),
                              child: Icon(
                                isGroup ? Iconsax.people : Iconsax.routing,
                                color: isGroup ? AppColors.chucky : AppColors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'] as String,
                                    style: AppTypography.titleMedium.copyWith(
                                      color: AppColors.chucky,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Invited by ${item['host']} • ${item['group']}',
                                    style: AppTypography.caption.copyWith(color: AppColors.shayne),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Iconsax.calendar, size: 14, color: AppColors.primaryOrange),
                              const SizedBox(width: 6),
                              Text(
                                item['date'] as String,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.chucky,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                text: 'Decline',
                                variant: AppButtonVariant.secondary,
                                size: AppButtonSize.small,
                                onPressed: () => _handleDecline(index),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AppButton(
                                text: 'Accept',
                                variant: AppButtonVariant.primaryNavy,
                                size: AppButtonSize.small,
                                onPressed: () => _handleAccept(index),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
