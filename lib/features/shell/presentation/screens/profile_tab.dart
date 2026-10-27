import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../components/atoms/app_avatar.dart';
import '../../../../components/atoms/app_badge.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../components/organisms/app_top_bar.dart';
import '../../../../core/routes/app_routes.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(
        showBackButton: false,
        title: 'My Profile',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // User Avatar & Name
              const AppAvatar(
                name: 'Louie Abella',
                size: 76,
              ),
              const SizedBox(height: 14),
              Text(
                'Louie Abella',
                style: AppTypography.h3.copyWith(color: AppColors.chucky),
              ),
              const SizedBox(height: 4),
              Text(
                'louie.abella@example.com',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppBadge.tierPlus(),
                  const SizedBox(width: 8),
                  const AppBadge(
                    label: 'Trip Leader',
                    variant: AppBadgeVariant.primaryNavy,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Preferences Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: AppRadii.radiusLg,
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip Preferences',
                      style: AppTypography.titleMedium.copyWith(color: AppColors.chucky),
                    ),
                    const SizedBox(height: 12),
                    _buildPreferenceRow('Activities', 'Food Trips, Beaches'),
                    _buildPreferenceRow('Dietary', 'Gluten-free'),
                    _buildPreferenceRow('Allergies', 'Dairy, Gluten, Eggs'),
                    _buildPreferenceRow('Pace', 'Balanced'),
                    _buildPreferenceRow('Budget Range', '₱ 2,000 / trip'),
                    _buildPreferenceRow('Free Days', 'Mon, Fri, Sat, Sun'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Button to Design System Showcase
              AppButton(
                text: 'Design System & Atoms Showcase',
                variant: AppButtonVariant.primaryNavy,
                iconLeading: const Icon(Iconsax.designtools, color: AppColors.white, size: 18),
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.showcase);
                },
              ),
              const SizedBox(height: 12),

              // Re-run Onboarding preferences
              AppButton(
                text: 'Update Onboarding Preferences',
                variant: AppButtonVariant.outline,
                iconLeading: const Icon(Iconsax.edit, color: AppColors.primaryNavy, size: 18),
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.onboarding);
                },
              ),
              const SizedBox(height: 12),

              // Log Out
              AppButton(
                text: 'Log Out',
                variant: AppButtonVariant.destructive,
                iconLeading: const Icon(Iconsax.logout, color: AppColors.white, size: 18),
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.welcome,
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(color: AppColors.shayne),
          ),
          Text(
            value,
            style: AppTypography.caption.copyWith(
              color: AppColors.chucky,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
