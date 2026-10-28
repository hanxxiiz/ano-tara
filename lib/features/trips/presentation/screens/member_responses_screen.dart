import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../components/atoms/app_button.dart';

class MemberResponsesScreen extends StatefulWidget {
  const MemberResponsesScreen({super.key});

  @override
  State<MemberResponsesScreen> createState() => _MemberResponsesScreenState();
}

class _MemberResponsesScreenState extends State<MemberResponsesScreen> {
  final List<Map<String, dynamic>> _members = [
    {
      'name': 'Louie Abella',
      'role': 'Organizer',
      'status': 'Confirmed',
      'isConfirmed': true,
      'time': 'Confirmed 3 days ago',
    },
    {
      'name': 'blackxswann',
      'role': 'You',
      'status': 'Confirmed',
      'isConfirmed': true,
      'time': 'Confirmed 3 days ago',
    },
    {
      'name': 'Carla Santos',
      'role': 'Member',
      'status': 'Confirmed',
      'isConfirmed': true,
      'time': 'Confirmed yesterday',
    },
    {
      'name': 'Mark Lim',
      'role': 'Member',
      'status': 'Waiting for Response',
      'isConfirmed': false,
      'time': 'Invited 3 days ago',
      'nudged': false,
    },
    {
      'name': 'Jenny Tan',
      'role': 'Member',
      'status': 'Waiting for Response',
      'isConfirmed': false,
      'time': 'Invited 2 days ago',
      'nudged': false,
    },
    {
      'name': 'Dave Bautista',
      'role': 'Member',
      'status': 'Waiting for Response',
      'isConfirmed': false,
      'time': 'Invited yesterday',
      'nudged': false,
    },
  ];

  void _nudgeMember(int index) {
    setState(() {
      _members[index]['nudged'] = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder notification sent to ${_members[index]['name']}!'),
        backgroundColor: AppColors.primaryNavy,
      ),
    );
  }

  void _nudgeAll() {
    setState(() {
      for (final m in _members) {
        if (!m['isConfirmed']) {
          m['nudged'] = true;
        }
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reminders sent to all 3 pending members!'),
        backgroundColor: AppColors.primaryOrange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final confirmedCount = _members.where((m) => m['isConfirmed'] == true).length;
    final totalCount = _members.length;

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
          'Member Responses',
          style: AppTypography.titleLarge.copyWith(color: AppColors.chucky),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
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
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.semanticYellow,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.chucky, width: 2),
                          ),
                          child: const Icon(
                            Iconsax.profile_2user,
                            color: AppColors.chucky,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bantayan Trip RSVPs',
                                style: AppTypography.titleLarge.copyWith(color: AppColors.chucky),
                              ),
                              Text(
                                '$confirmedCount of $totalCount Members Confirmed',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.carla,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Progress Track
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: confirmedCount / totalCount,
                        minHeight: 12,
                        backgroundColor: AppColors.white,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '3 members haven’t confirmed yet. Send a nudge to lock in headcount!',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.chucky),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Member Status List',
                style: AppTypography.titleLarge.copyWith(color: AppColors.chucky),
              ),
              const SizedBox(height: 12),

              for (int i = 0; i < _members.length; i++) ...[
                _buildMemberTile(i),
                const SizedBox(height: 10),
              ],

              const SizedBox(height: 20),
              AppButton(
                text: 'Send Reminder to All Pending',
                variant: AppButtonVariant.primaryNavy,
                iconLeading: const Icon(Iconsax.notification_bing, color: AppColors.white, size: 20),
                onPressed: _nudgeAll,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberTile(int index) {
    final member = _members[index];
    final bool isConfirmed = member['isConfirmed'] as bool;
    final bool isNudged = member['nudged'] == true;

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
            backgroundColor: isConfirmed ? AppColors.primaryNavy : AppColors.secondaryLight,
            child: Text(
              (member['name'] as String).substring(0, 1),
              style: TextStyle(
                color: isConfirmed ? AppColors.white : AppColors.chucky,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member['name'] as String,
                  style: AppTypography.titleMedium.copyWith(color: AppColors.chucky),
                ),
                Text(
                  member['time'] as String,
                  style: AppTypography.caption.copyWith(color: AppColors.shayne),
                ),
              ],
            ),
          ),
          if (isConfirmed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.semanticGreenLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.semanticGreen, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check, size: 14, color: AppColors.semanticGreen),
                  const SizedBox(width: 4),
                  Text(
                    'Going',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.semanticGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          else
            OutlinedButton(
              onPressed: isNudged ? null : () => _nudgeMember(index),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.chucky, width: 1.5),
                backgroundColor: isNudged ? AppColors.surfaceLight : AppColors.semanticYellow,
                foregroundColor: AppColors.chucky,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                isNudged ? 'Nudged' : 'Nudge',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.chucky,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
