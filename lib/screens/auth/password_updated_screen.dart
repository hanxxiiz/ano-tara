import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../components/atoms/app_button.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import 'login_screen.dart';

class PasswordUpdatedScreen extends StatelessWidget {
  const PasswordUpdatedScreen({super.key});

  void _backToLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 12, 26, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => _backToLogin(context),
                  icon: const Icon(Iconsax.arrow_left, color: AppColors.secondaryDark),
                ),
              ),
              const SizedBox(height: 120),
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryOrange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.shield_tick5,
                    color: AppColors.white,
                    size: 72,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Text(
                'Password Updated',
                textAlign: TextAlign.center,
                style: AppTypography.h2.copyWith(color: AppColors.secondaryDark),
              ),
              const SizedBox(height: 6),
              Text(
                'Your password has been changed successfully.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.secondaryDark),
              ),
              const SizedBox(height: 40),
              AppButton(
                text: 'Back to Log In',
                onPressed: () => _backToLogin(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
