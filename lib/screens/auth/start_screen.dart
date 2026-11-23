import 'package:flutter/material.dart';

import '../../components/atoms/app_button.dart';
import '../../core/constants/app_colors.dart';
import '../../features/trips/presentation/screens/trips_list_screen.dart';
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
              const SizedBox(height: 19),
              // Temporary shortcut button to jump directly to Organizer Trips List & Overview
              AppButton(
                text: 'Open Trips (Temp)',
                customHeight: 50,
                variant: AppButtonVariant.primaryOrange,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TripsListScreen()),
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
