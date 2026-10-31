import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../components/organisms/app_top_bar.dart';
import '../../../../core/routes/app_routes.dart';

/// Password Updated confirmation screen matching Figma Auth Screen 7.
class PasswordUpdatedScreen extends StatelessWidget {
  const PasswordUpdatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(showBackButton: false),
      body: SafeArea(
        child: AppScrollableFillBody(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Orange Checkmark Shield Graphic
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: AppColors.primaryOrange,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33E24B27),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Iconsax.tick_circle,
                  color: AppColors.white,
                  size: 46,
                ),
              ),
              const SizedBox(height: 28),

              Text(
                'Password Updated',
                style: AppTypography.h2.copyWith(color: AppColors.chucky),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Your password has been changed successfully.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium,
                ),
              ),

              const Spacer(flex: 3),

              AppButton(
                text: 'Back to Login',
                variant: AppButtonVariant.primaryNavy,
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.login,
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
