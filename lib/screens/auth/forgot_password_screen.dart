import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  // send the recovery code with Supabase.
  Future<void> _sendCode() async {
    if (_loading || !_formKey.currentState!.validate()) return;
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
