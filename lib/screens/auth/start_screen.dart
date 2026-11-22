import 'package:flutter/material.dart';

import '../../components/atoms/app_button.dart';
import '../../components/molecules/floating_messages_button.dart';
import '../../core/constants/app_colors.dart';
import '../messages_list_screen.dart';
import 'login_screen.dart';
import 'sign_up_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO: Remove temporary floating messages button from StartScreen once Groups screen is wired
      floatingActionButton: const FloatingMessagesButton(),
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
              // TODO: Remove temporary navigation button once Groups tab is wired
              AppButton(
                text: 'Group Messages & Chat (Temp)',
                customHeight: 50,
                variant: AppButtonVariant.primaryOrange,
                iconLeading: const Icon(
                  Icons.mail_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MessagesListScreen(),
                  ),
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
