import 'package:flutter/material.dart';

import '../../widgets/auth_widgets.dart';
import 'password_updated_screen.dart';
import 'validators.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _reset() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: update the password with Supabase.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PasswordUpdatedScreen()),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      children: [
        const SizedBox(height: 12),
        const LogoBadge(size: 140, icon: Icons.lock_rounded),
        const SizedBox(height: 32),
        const AuthHeader(
          title: 'Create New Password',
          subtitle: 'Set a new password for your account.',
        ),
        const SizedBox(height: 22),
        Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                label: 'New Password',
                controller: _password,
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                validator: validatePassword,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Confirm Password',
                controller: _confirm,
                obscureText: true,
                textInputAction: TextInputAction.done,
                validator: (value) =>
                    value != _password.text ? 'Passwords do not match' : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        AppButton(label: 'Reset Password', onPressed: _reset),
      ],
    );
  }
}
