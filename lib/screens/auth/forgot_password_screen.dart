import 'package:flutter/material.dart';

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

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _sendCode() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: send the recovery code with Supabase.
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => VerificationScreen(email: _email.text.trim())),
    );
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
        AppButton(label: 'Send Code', onPressed: _sendCode),
      ],
    );
  }
}
