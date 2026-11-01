import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:anotara/main.dart';
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
  bool _loading = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  // temporary error message
  void _show(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  // update the password with Supabase.
  Future<void> _reset() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await supabase.auth.updateUser(UserAttributes(password: _password.text));

      // The code step signed the user in. Sign out so they log in with
      // the new password.
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
        AppButton(
          label: 'Reset Password',
          loading: _loading,
          onPressed: _reset,
        ),
      ],
    );
  }
}
