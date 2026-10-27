import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../core/routes/app_routes.dart';

/// Landing screen matching Figma Auth Screen 1:
/// Large orange circle graphic, "Create Account" primary button, "Log In" outline button.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Orange Brand Graphic Circle
              Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  color: AppColors.primaryOrange,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33E24B27),
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'ano\ntara',
                    textAlign: TextAlign.center,
                    style: AppTypography.h3.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),
              Text(
                'Ano Tara!',
                style: AppTypography.h1.copyWith(
                  color: AppColors.chucky,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Plan trips, align schedules, and explore together effortlessly.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium,
              ),

              const Spacer(flex: 3),

              // Action Buttons
              AppButton(
                text: 'Create Account',
                variant: AppButtonVariant.primaryNavy,
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.register);
                },
              ),
              const SizedBox(height: 14),
              AppButton(
                text: 'Log In',
                variant: AppButtonVariant.outline,
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.login);
                },
              ),
              const SizedBox(height: 14),

              // Quick bypass to Design System Showcase for pairing / evaluation
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.showcase);
                },
                child: Text(
                  'Explore Design System & Atoms Gallery',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
