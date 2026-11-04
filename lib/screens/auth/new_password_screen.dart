import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:anotara/main.dart';
import '../../components/atoms/app_button.dart';
import '../../components/atoms/app_input_field.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import 'password_updated_screen.dart';
import 'validators.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _show(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _reset() async {
    if (_loading) return;
    final passErr = validatePassword(_password.text);
    final confirmErr =
        _confirm.text != _password.text ? 'Passwords do not match' : null;
    if (passErr != null || confirmErr != null) {
      _show(passErr ?? confirmErr!);
      return;
    }
    setState(() => _loading = true);

    try {
      await supabase.auth.updateUser(UserAttributes(password: _password.text));
      await supabase.auth.signOut();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PasswordUpdatedScreen()),
        (route) => route.isFirst,
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
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryOrange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.lock5,
                    color: AppColors.white,
                    size: 72,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Create New Password',
                textAlign: TextAlign.center,
                style: AppTypography.h2.copyWith(color: AppColors.secondaryDark),
              ),
              const SizedBox(height: 6),
              Text(
                'Set a new password for your account.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.secondaryDark),
              ),
              const SizedBox(height: 22),
              AppInputField(
                label: 'New Password',
                controller: _password,
                isPassword: true,
              ),
              const SizedBox(height: 16),
              AppInputField(
                label: 'Confirm Password',
                controller: _confirm,
                isPassword: true,
              ),
              const SizedBox(height: 40),
              AppButton(
                text: 'Reset Password',
                isLoading: _loading,
                onPressed: _reset,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
