import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_otp_field.dart';
import '../../../../core/routes/app_routes.dart';

/// 6-digit verification code screen matching Figma Auth Screen.
class VerificationCodeScreen extends StatefulWidget {
  const VerificationCodeScreen({super.key});

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  String _otpCode = '';
  bool _isLoading = false;

  void _handleVerify() async {
    if (_otpCode.length < 6) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pushNamed(AppRoutes.createNewPassword);
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

              // Orange Envelope Graphic
              Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  color: AppColors.primaryOrange,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primaryOrange,
                      size: 38,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title: "Verification Code"
              Text(
                'Verification Code',
                style: GoogleFonts.urbanist(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondaryDark,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Enter the 6-digit code sent to your email.',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondaryDark,
                ),
              ),

              const SizedBox(height: 36),

              // 6 OTP Digit Input Boxes with atomic styling
              AppOtpField(
                length: 6,
                onChanged: (code) => setState(() => _otpCode = code),
                onCompleted: (code) {
                  setState(() => _otpCode = code);
                  _handleVerify();
                },
              ),

              const SizedBox(height: 28),

              // Resend Code section
              Text(
                'Didn’t receive the code?',
                style: GoogleFonts.openSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondaryDark,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('A fresh verification code has been resent to your email.'),
                      backgroundColor: AppColors.primaryNavy,
                    ),
                  );
                },
                child: Text(
                  'Resend Code',
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Verify Button
              AppButton(
                text: 'Verify',
                variant: AppButtonVariant.primaryNavy,
                isLoading: _isLoading,
                onPressed: _handleVerify,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
