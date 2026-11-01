import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:anotara/main.dart';
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

  // temporary error message
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

  // verify the code with Supabase.
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
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const NewPasswordScreen()));
    } on AuthException {
      _show('Invalid or expired code.');
    } catch (_) {
      _show('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // resend the recovery code with Supabase.
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
        AppButton(label: 'Verify', loading: _loading, onPressed: _verify),
      ],
    );
  }
}
