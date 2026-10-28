import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_input_field.dart';
import '../../../../core/routes/app_routes.dart';

/// Create New Password screen matching Figma Auth Screen.
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
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pushReplacementNamed(AppRoutes.passwordUpdated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Back Arrow
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.secondaryDark,
                    size: 26,
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),

              const SizedBox(height: 24),

              // Orange Lock Graphic
              Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  color: AppColors.primaryOrange,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Lock shackle
                      Container(
                        width: 32,
                        height: 24,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.white, width: 6),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                      ),
                      // Lock body
                      Container(
                        width: 58,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryOrange,
                                width: 4.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title: "Create New Password"
              Text(
                'Create New Password',
                style: GoogleFonts.urbanist(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondaryDark,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Set a new password for your account.',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondaryDark,
                ),
              ),

              const SizedBox(height: 32),

              AppInputField(
                label: 'New Password',
                controller: _newPasswordController,
                isPassword: true,
              ),

              const SizedBox(height: 20),

              AppInputField(
                label: 'Confirm Password',
                controller: _confirmPasswordController,
                isPassword: true,
              ),

              const SizedBox(height: 48),

              AppButton(
                text: 'Reset Password',
                variant: AppButtonVariant.primaryNavy,
                isLoading: _isLoading,
                onPressed: _handleResetPassword,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
