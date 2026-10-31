import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../core/routes/app_routes.dart';

/// Landing screen matching Figma Auth Screen 1:
/// Solid orange circle logo, "Create Account" primary button, "Log In" secondary button.
/// Follows the Atomic Design system with 2px Ink outlines & hard shadows.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AppScrollableFillBody(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Solid Orange Brand Graphic Circle
              Container(
                width: 190,
                height: 190,
                decoration: const BoxDecoration(
                  color: AppColors.primaryOrange,
                  shape: BoxShape.circle,
                ),
              ),

              // Spacing keeping buttons close to the logo
              const SizedBox(height: 36),

              // Action Buttons
              AppButton(
                text: 'Create Account',
                variant: AppButtonVariant.primaryNavy,
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.register);
                },
              ),
              const SizedBox(height: 16),
              AppButton(
                text: 'Log In',
                variant: AppButtonVariant.secondary,
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.login);
                },
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
