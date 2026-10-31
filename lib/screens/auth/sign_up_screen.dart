import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

//import 'package:url_launcher/url_launcher.dart';
import '../../widgets/auth_widgets.dart';
import 'login_screen.dart';
import 'validators.dart';
import 'package:anotara/main.dart';

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
    _authSub.cancel();
    _firstName.dispose();
    _lastName.dispose();
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // creates the account with Supabase.
  bool _loading = false;

  void _show(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _signUp() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final username = _username.text.trim().toLowerCase();
      final available = await supabase.rpc(
        'username_available',
        params: {'p_username': username},
      );
      if (available != true) {
        _show('That username is already taken.');
        return;
      }

      final response = await supabase.auth.signUp(
        email: _email.text.trim(),
        password: _password.text,
        emailRedirectTo:
            'io.supabase.anotara://login-callback/', // when email confirms with the link supabase will redirect users back to the app
        data: {
          'first_name': _firstName.text.trim(),
          'last_name': _lastName.text.trim(),
          'username': username,
        },
      );
      if (!mounted) return;

      // With email confirmation on, Supabase hides "already registered"
      // by returning a user with no identities.
      if (response.user?.identities?.isEmpty ?? false) {
        _show('An account with this email already exists. Try logging in.');
        return;
      }

      if (response.session == null) {
        _show('Check your email to confirm your account.');
        return;
      }

      // Signed in. AuthGate reacts to the session, so just clear pushed screens.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthException catch (e) {
      _show(
        e.message.contains('Database error')
            ? 'That username is already taken.'
            : e.message,
      );
    } catch (_) {
      _show('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // sign up with Supabase Google OAuth.
  bool _googleLoading = false;

  Future<void> _continueWithGoogle() async {
    if (_googleLoading) return;
    setState(() => _googleLoading = true);
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.anotara://signup-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } on AuthException catch (e) {
      _show(e.message);
    } catch (_) {
      _show('Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  late final StreamSubscription<AuthState> _authSub;

  @override
  void initState() {
    super.initState();
    _authSub = supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn && mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
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
        AppButton(label: 'Sign Up', loading: _loading, onPressed: _signUp),
        const OrDivider(),
        AppButton(
          label: 'Continue with Google',
          icon: Icons.person,
          variant: AppButtonVariant.secondary,
          loading: _googleLoading,
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
