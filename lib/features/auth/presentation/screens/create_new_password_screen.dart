import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_input_field.dart';
import '../../../../components/organisms/app_top_bar.dart';
import '../../../../core/routes/app_routes.dart';

/// Create New Password screen matching Figma Auth Screen 6.
class CreateNewPasswordScreen extends StatefulWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleResetPassword() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pushReplacementNamed(AppRoutes.passwordUpdated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Orange Lock Graphic
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: AppColors.primaryOrange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.lock,
                  color: AppColors.white,
                  size: 38,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Create New Password',
                style: AppTypography.h2.copyWith(color: AppColors.chucky),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Set a new password for your account',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium,
                ),
              ),
              const SizedBox(height: 32),

              AppInputField(
                label: 'New Password',
                hint: 'Enter your new password',
                controller: _newPasswordController,
                isPassword: true,
              ),
              const SizedBox(height: 16),

              AppInputField(
                label: 'Confirm Password',
                hint: 'Re-enter your new password',
                controller: _confirmPasswordController,
                isPassword: true,
              ),
              const SizedBox(height: 36),

              AppButton(
                text: 'Reset Password',
                variant: AppButtonVariant.primaryNavy,
                isLoading: _isLoading,
                onPressed: _handleResetPassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
