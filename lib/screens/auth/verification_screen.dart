import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:anotara/main.dart';
import '../../components/atoms/app_button.dart';
import '../../components/atoms/app_otp_field.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import 'new_password_screen.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key, required this.email});

  final String email;

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  static const _codeLength = 6;
  static const _coolDownSeconds = 60;

  String _code = '';
  bool _loading = false;
  int _coolDown = _coolDownSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _show(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _coolDown = _coolDownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _coolDown--);
      if (_coolDown <= 0) t.cancel();
    });
  }

  Future<void> _verify() async {
    if (_loading) return;
    if (_code.length < _codeLength) {
      _show('Enter the full 6-digit code.');
      return;
    }
    setState(() => _loading = true);

    try {
      await supabase.auth.verifyOTP(
        email: widget.email,
        token: _code,
        type: OtpType.recovery,
      );
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NewPasswordScreen()),
      );
    } on AuthException {
      _show('Invalid or expired code.');
    } catch (_) {
      _show('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    if (_coolDown > 0) return;
    try {
      await supabase.auth.resetPasswordForEmail(widget.email);
      _startCooldown();
      _show('A new code was sent to ${widget.email}.');
    } on AuthException catch (e) {
      _show(e.message);
    } catch (_) {
      _show('Something went wrong. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 12, 26, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Iconsax.arrow_left, color: AppColors.secondaryDark),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryOrange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.sms5,
                    color: AppColors.white,
                    size: 72,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Verification Code',
                textAlign: TextAlign.center,
                style: AppTypography.h2.copyWith(color: AppColors.secondaryDark),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter the 6-digit code sent to your email.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.secondaryDark),
              ),
              const SizedBox(height: 22),
              AppOtpField(
                length: _codeLength,
                onChanged: (code) => setState(() => _code = code),
              ),
              const SizedBox(height: 28),
              const Center(
                child: Text(
                  "Didn't receive the code?",
                  style: TextStyle(fontSize: 14, color: AppColors.secondaryDark),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: GestureDetector(
                  onTap: _resend,
                  child: const Text(
                    'Resend Code',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 38),
              AppButton(
                text: 'Verify',
                isLoading: _loading,
                onPressed: _verify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
