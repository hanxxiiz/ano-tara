import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_input_field.dart';
import '../../../../core/routes/app_routes.dart';

/// Sign In screen matching Figma Auth Screen 2 ("Welcome Back").
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

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

              const SizedBox(height: 24),

              // Orange Brand Graphic Circle
              Container(
                width: 130,
                height: 130,
                decoration: const BoxDecoration(
                  color: AppColors.primaryOrange,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(height: 20),

              // Title: "Welcome Back"
              Text(
                'Welcome Back',
                style: GoogleFonts.urbanist(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondaryDark,
                ),
              ),

              const SizedBox(height: 28),

              // Email Input
              AppInputField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              // Password Input
              AppInputField(
                label: 'Password',
                controller: _passwordController,
                isPassword: true,
              ),

              const SizedBox(height: 8),

              // Forgot Password link (Right Aligned, Ink color)
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
                  },
                  child: Text(
                    'Forgot password?',
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryDark,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Log In Button
              AppButton(
                text: 'Log In',
                variant: AppButtonVariant.primaryNavy,
                isLoading: _isLoading,
                onPressed: _handleLogin,
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

              // Don't have an account yet? Sign Up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account yet? ",
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed(AppRoutes.register);
                    },
                    child: Text(
                      'Sign Up',
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
