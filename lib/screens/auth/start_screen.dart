import 'package:flutter/material.dart';

import '../../components/atoms/app_button.dart';
import '../../core/constants/app_colors.dart';
import '../../features/trips/presentation/widgets/trip_views_preview_sheet.dart';
import 'login_screen.dart';
import 'sign_up_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 3),
              Center(
                child: Container(
                  width: 164,
                  height: 164,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryOrange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const Spacer(flex: 2),
              AppButton(
                text: 'Create Account',
                customHeight: 50,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                ),
              ),
              const SizedBox(height: 19),
              AppButton(
                text: 'Log In',
                customHeight: 50,
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
              ),
              const SizedBox(height: 14),
              // Temporary shortcut to preview Trip Map & Completed/Cancelled Trip Views
              AppButton(
                text: 'Preview Trip Views (Temp)',
                customHeight: 46,
                variant: AppButtonVariant.primaryOrange,
                onPressed: () => showTripViewsPreviewSheet(context),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
