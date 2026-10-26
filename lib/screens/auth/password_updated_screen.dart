import 'package:flutter/material.dart';

import '../../widgets/auth_widgets.dart';
import 'login_screen.dart';

class PasswordUpdatedScreen extends StatelessWidget {
  const PasswordUpdatedScreen({super.key});

  void _backToLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      onBack: () => _backToLogin(context),
      children: [
        const SizedBox(height: 140),
        const LogoBadge(size: 140, icon: Icons.verified_user_rounded),
        const SizedBox(height: 26),
        const AuthHeader(
          title: 'Password Updated',
          subtitle: 'Your password has been changed successfully.',
        ),
        const SizedBox(height: 40),
        AppButton(label: 'Back to Log In', onPressed: () => _backToLogin(context)),
      ],
    );
  }
}
