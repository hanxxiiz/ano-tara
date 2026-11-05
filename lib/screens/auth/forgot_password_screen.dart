import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

import 'package:anotara/main.dart';
import '../../widgets/auth_widgets.dart';
import 'validators.dart';
import 'verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  // temporary message function to show error messages in a snackbar.
  void _show(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  // Asks Supabase for the account state: 'not_found', 'unverified' or 'verified'.
  Future<String> _emailStatus(String email) async {
    final result = await supabase.rpc(
      'email_status',
      params: {'p_email': email},
    );
    return result is String ? result : 'not_found';
  }

  // send the recovery code with Supabase (only for existing, verified accounts).
  Future<void> _sendCode() async {
    // The form validator already rejects empty / badly formatted emails.
    if (_loading || !_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final email = _email.text.trim();

    try {
      final status = await _emailStatus(email);

      if (status == 'not_found') {
        _show('No account found with that email address.');
        return;
      }
      if (status == 'unverified') {
        _show(
          'This email hasn\'t been verified yet. Please confirm it from the '
          'email we sent when you signed up.',
        );
        return;
      }

      await supabase.auth.resetPasswordForEmail(email);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => VerificationScreen(email: email)),
      );
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (e.code == 'over_email_send_rate_limit' ||
          msg.contains('rate limit')) {
        _show('Too many requests. Please wait a moment and try again.');
      } else {
        _show('Unable to send the code right now. Please try again.');
      }
    } on SocketException {
      _show('No internet connection. Please check your network.');
    } catch (_) {
      _show('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      children: [
        const SizedBox(height: 40),
        const LogoBadge(size: 140, icon: Icons.shield_rounded),
        const SizedBox(height: 22),
        const AuthHeader(
          title: 'Forgot Password',
          subtitle: "Enter your email and we'll send you a verification code.",
        ),
        const SizedBox(height: 22),
        Form(
          key: _formKey,
          child: AppTextField(
            label: 'Email',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            validator: validateEmail,
          ),
        ),
        const SizedBox(height: 30),
        AppButton(label: 'Send Code', loading: _loading, onPressed: _sendCode),
      ],
    );
  }
}
