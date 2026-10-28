import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_input_field.dart';
import '../../../../core/routes/app_routes.dart';

/// Sign Up screen matching Figma Auth Screen 3 ("Create Your Account").
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    // Proceeds to 7-step Onboarding preferences flow
    Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
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
              // Back Button (Top Left)
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

              const SizedBox(height: 20),

              // Solid Orange Brand Graphic Circle
              Container(
                width: 130,
                height: 130,
                decoration: const BoxDecoration(
                  color: AppColors.primaryOrange,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(height: 20),

              // Title: "Create Your Account"
              Text(
                'Create Your Account',
                style: GoogleFonts.urbanist(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondaryDark,
                ),
              ),

              const SizedBox(height: 24),

              // Side-by-side First Name & Last Name
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppInputField(
                      label: 'First Name',
                      controller: _firstNameController,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: AppInputField(
                      label: 'Last Name',
                      controller: _lastNameController,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Username
              AppInputField(
                label: 'Username',
                controller: _usernameController,
              ),

              const SizedBox(height: 16),

              // Email
              AppInputField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              // Password
              AppInputField(
                label: 'Password',
                controller: _passwordController,
                isPassword: true,
              ),

              const SizedBox(height: 28),

              // Sign Up Button
              AppButton(
                text: 'Sign Up',
                variant: AppButtonVariant.primaryNavy,
                isLoading: _isLoading,
                onPressed: _handleRegister,
              ),

              // "or" text (Centered, plain lowercase, no dividers)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'or',
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondaryDark,
                  ),
                ),
              ),

              // Continue with Google Button
              AppButton.google(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
                },
              ),

              const SizedBox(height: 32),

              // Already have an account? Log In
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                    },
                    child: Text(
                      'Log In',
                      style: GoogleFonts.urbanist(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
