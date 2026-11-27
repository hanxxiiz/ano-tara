import 'package:flutter/material.dart';

import '../../../../components/organisms/app_top_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../models/subscription_usage.dart';
import '../../../../services/subscription_service.dart';
import '../../data/profile_repository.dart';
import '../widgets/profile_widgets.dart';

/// Manage Subscription: current plan plus how much of each plan limit is used.
///
/// Usage comes from the `anotara_get_subscription_usage` database function.
/// The limits themselves are enforced by the database, so this screen only
/// displays them. Billing / plan changes are not implemented yet.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key, this.service});

  final SubscriptionService? service;

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  late Future<SubscriptionUsage?> _usage = _load();

  Future<SubscriptionUsage?> _load() async {
    try {
      return await (widget.service ?? SubscriptionService()).fetchUsage();
    } catch (e) {
      debugPrint('Subscription usage unavailable: $e');
      return null;
    }
  }

  Future<void> _refresh() async {
    final next = _load();
    setState(() => _usage = next);
    await next;
  }

  @override
  Widget build(BuildContext context) {
    final summary = ProfileRepository.instance.summary;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const AppTopBar(title: 'Manage Subscription'),
      body: FutureBuilder<SubscriptionUsage?>(
        future: _usage,
        builder: (context, snapshot) {
          final usage = snapshot.data;
          final loading = snapshot.connectionState != ConnectionState.done;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(15, 16, 15, 32),
              children: [
                const ProfileSectionTitle('Current Plan'),
                const SizedBox(height: 14),
                CurrentPlanCard(
                  summary: usage == null ? summary : _withPlan(summary, usage),
                ),
                const SizedBox(height: 24),
                if (loading)
                  const Center(child: CircularProgressIndicator())
                else if (usage == null)
                  Text(
                    'Usage is unavailable right now. Pull down to try again.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium,
                  )
                else
                  _UsageSection(usage: usage),
                const SizedBox(height: 24),
                Text(
                  'Plan changes and billing will be available here soon.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  ProfileSummary _withPlan(ProfileSummary s, SubscriptionUsage usage) {
    return ProfileSummary(
      fullName: s.fullName,
      username: s.username,
      avatarUrl: s.avatarUrl,
      trips: s.trips,
      groups: s.groups,
      activeTrips: s.activeTrips,
      planName: '${usage.planName} Plan',
      planExpires: usage.periodEnd == null ? 'Never' : _date(usage.periodEnd!),
    );
  }
}

class _UsageSection extends StatelessWidget {
  const _UsageSection({required this.usage});

  final SubscriptionUsage usage;

  @override
  Widget build(BuildContext context) {
    final memberLimit = usage.membersPerGroupLimit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ProfileSectionTitle('Plan Usage'),
        const SizedBox(height: 14),
        _UsageMeter(
          key: const ValueKey('usage-groups'),
          title: 'Active groups',
          quota: usage.groups,
        ),
        _UsageMeter(
          key: const ValueKey('usage-trips'),
          title: 'Active trips',
          quota: usage.activeTrips,
        ),
        _UsageMeter(
          key: const ValueKey('usage-ai'),
          title: 'AI itinerary generations',
          quota: usage.aiGenerations,
          footnote: usage.aiResetsAt == null
              ? null
              : 'Resets on ${_date(usage.aiResetsAt!)}',
        ),
        const SizedBox(height: 8),
        Text(
          memberLimit == null
              ? 'Members per group: unlimited'
              : 'Members per group: up to $memberLimit',
          style: AppTypography.titleMedium.copyWith(color: AppColors.black),
        ),
        const SizedBox(height: 10),
        if (usage.groupMembers.isEmpty)
          Text(
            'You do not own any groups yet.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.carla),
          )
        else
          for (final g in usage.groupMembers)
            _UsageMeter(title: g.groupName, quota: g.members, compact: true),
      ],
    );
  }
}

class _UsageMeter extends StatelessWidget {
  const _UsageMeter({
    super.key,
    required this.title,
    required this.quota,
    this.footnote,
    this.compact = false,
  });

  final String title;
  final QuotaUsage quota;
  final String? footnote;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = quota.isAtLimit ? AppColors.primaryOrange : AppColors.primaryNavy;
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 10 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: (compact
                          ? AppTypography.bodyMedium
                          : AppTypography.titleMedium)
                      .copyWith(color: AppColors.black),
                ),
              ),
              Text(
                quota.label,
                style: AppTypography.bodyMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: quota.fraction,
              minHeight: compact ? 6 : 8,
              backgroundColor: AppColors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          if (quota.isAtLimit) ...[
            const SizedBox(height: 4),
            Text(
              'Limit reached. Upgrade to add more.',
              style: AppTypography.caption.copyWith(color: AppColors.primaryOrange),
            ),
          ],
          if (footnote != null) ...[
            const SizedBox(height: 4),
            Text(
              footnote!,
              style: AppTypography.caption.copyWith(color: AppColors.carla),
            ),
          ],
        ],
      ),
    );
  }
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _date(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';
