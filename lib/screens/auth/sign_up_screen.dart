import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../widgets/auth_widgets.dart';
import 'login_screen.dart';
import 'validators.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _signUp() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: create the account with Supabase and save the profile fields.
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.onboarding, (_) => false);
  }

  void _continueWithGoogle() {
    // TODO: sign up with Supabase Google OAuth.
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      children: [
        const SizedBox(height: 8),
        const LogoBadge(),
        const SizedBox(height: 22),
        const AuthHeader(title: 'Create Your Account'),
        const SizedBox(height: 32),
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'First Name',
                        controller: _firstName,
                        autofillHints: const [AutofillHints.givenName],
                        validator: requiredField('First name'),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: AppTextField(
                        label: 'Last Name',
                        controller: _lastName,
                        autofillHints: const [AutofillHints.familyName],
                        validator: requiredField('Last name'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                AppTextField(
                  label: 'Username',
                  controller: _username,
                  autofillHints: const [AutofillHints.newUsername],
                  validator: requiredField('Username'),
                ),
                const SizedBox(height: 13),
                AppTextField(
                  label: 'Email',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: validateEmail,
                ),
                const SizedBox(height: 13),
                AppTextField(
                  label: 'Password',
                  controller: _password,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: validatePassword,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        AppButton(label: 'Sign Up', onPressed: _signUp),
        const OrDivider(),
        AppButton(
          label: 'Continue with Google',
          icon: Icons.person,
          variant: AppButtonVariant.secondary,
          onPressed: _continueWithGoogle,
        ),
        const SizedBox(height: 28),
        FooterPrompt(
          prompt: 'Already have an account?',
          action: 'Log In',
          onTap: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
        ),
      ],
    );
  }
}
