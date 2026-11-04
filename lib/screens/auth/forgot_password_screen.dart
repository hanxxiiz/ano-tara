import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:anotara/main.dart';
import '../../components/atoms/app_button.dart';
import '../../components/atoms/app_input_field.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import 'validators.dart';
import 'verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _show(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _sendCode() async {
    if (_loading) return;
    final err = validateEmail(_email.text);
    if (err != null) {
      _show(err);
      return;
    }
    setState(() => _loading = true);
    final email = _email.text.trim();

    try {
      await supabase.auth.resetPasswordForEmail(email);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => VerificationScreen(email: email)),
      );
    } on AuthException catch (e) {
      _show(e.message);
    } catch (_) {
      _show('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
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
                    Iconsax.shield_tick5,
                    color: AppColors.white,
                    size: 72,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Forgot Password',
                textAlign: TextAlign.center,
                style: AppTypography.h2.copyWith(color: AppColors.secondaryDark),
              ),
              const SizedBox(height: 6),
              Text(
                "Enter your email and we'll send you a verification code.",
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.secondaryDark),
              ),
              const SizedBox(height: 22),
              AppInputField(
                label: 'Email',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 30),
              AppButton(
                text: 'Send Code',
                isLoading: _loading,
                onPressed: _sendCode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
