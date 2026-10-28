import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_input_field.dart';
import '../../../../core/routes/app_routes.dart';

/// Forgot Password screen matching Figma Auth Screen.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendCode() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pushNamed(AppRoutes.verificationCode);
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

              // Orange Shield Badge Graphic
              Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  color: AppColors.primaryOrange,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.shield_outlined,
                    color: AppColors.white,
                    size: 64,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title: "Forgot Password"
              Text(
                'Forgot Password',
                style: GoogleFonts.urbanist(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondaryDark,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                "Enter your email and we'll send a 6-digit verification code.",
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondaryDark,
                ),
              ),

              const SizedBox(height: 36),

              AppInputField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 48),

              AppButton(
                text: 'Send Code',
                variant: AppButtonVariant.primaryNavy,
                isLoading: _isLoading,
                onPressed: _handleSendCode,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
