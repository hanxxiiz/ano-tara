import 'package:flutter/material.dart';

import '../../../../components/organisms/app_top_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/profile_repository.dart';
import '../widgets/profile_widgets.dart';

/// Placeholder for the subscription flow until the billing screens land
/// (feature/settings uses the same route).
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final summary = ProfileRepository.instance.summary;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const AppTopBar(title: 'Manage Subscription'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(15, 16, 15, 32),
        children: [
          const ProfileSectionTitle('Current Plan'),
          const SizedBox(height: 14),
          CurrentPlanCard(summary: summary),
          const SizedBox(height: 24),
          Text(
            'Plan changes and billing will be available here soon.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }
}
