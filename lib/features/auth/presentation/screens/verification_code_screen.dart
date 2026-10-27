import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_otp_field.dart';
import '../../../../components/organisms/app_top_bar.dart';
import '../../../../core/routes/app_routes.dart';

/// 6-digit verification code screen matching Figma Auth Screen 5.
class VerificationCodeScreen extends StatefulWidget {
  const VerificationCodeScreen({super.key});

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  String _otpCode = '';
  bool _isLoading = false;

  void _handleVerify() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pushNamed(AppRoutes.createNewPassword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Orange Envelope Graphic
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: AppColors.primaryOrange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.sms,
                  color: AppColors.white,
                  size: 38,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Verification Code',
                style: AppTypography.h2.copyWith(color: AppColors.chucky),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Enter the 6-digit code sent to your email',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium,
                ),
              ),
              const SizedBox(height: 36),

              // 6 OTP Digit Input Boxes
              AppOtpField(
                length: 6,
                onChanged: (code) => setState(() => _otpCode = code),
                onCompleted: (code) {
                  setState(() => _otpCode = code);
                  _handleVerify();
                },
              ),
              const SizedBox(height: 28),

              // Resend Code link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: AppTypography.bodySmall.copyWith(color: AppColors.carla),
                  ),
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
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              AppButton(
                text: 'Verify',
                variant: AppButtonVariant.primaryNavy,
                isLoading: _isLoading,
                isDisabled: _otpCode.length < 6,
                onPressed: _handleVerify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
