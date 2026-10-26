import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/auth_widgets.dart';
import 'new_password_screen.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key, required this.email});

  final String email;

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  static const _codeLength = 6;
  String _code = '';

  void _verify() {
    if (_code.length < _codeLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the full 6-digit code.')),
      );
      return;
    }
    // TODO: verify the code with Supabase.
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewPasswordScreen()),
    );
  }

  void _resend() {
    // TODO: resend the recovery code with Supabase.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('A new code was sent to ${widget.email}.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      children: [
        const SizedBox(height: 40),
        const LogoBadge(size: 140, icon: Icons.email_rounded),
        const SizedBox(height: 22),
        const AuthHeader(
          title: 'Verification Code',
          subtitle: 'Enter the 6-digit code sent to your email.',
        ),
        const SizedBox(height: 22),
        OtpInput(
          length: _codeLength,
          onChanged: (code) => setState(() => _code = code),
        ),
        const SizedBox(height: 28),
        const Center(
          child: Text(
            "Didn't receive the code?",
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: GestureDetector(
            onTap: _resend,
            child: const Text(
              'Resend Code',
              style: TextStyle(fontSize: 14, color: AppColors.accent),
            ),
          ),
        ),
        const SizedBox(height: 38),
        AppButton(label: 'Verify', onPressed: _verify),
      ],
    );
  }
}
