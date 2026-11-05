import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

import 'dart:async';
import '../../app_routes.dart';
import '../../widgets/auth_widgets.dart';
import 'forgot_password_screen.dart';
import 'sign_up_screen.dart';
import 'validators.dart';
import 'package:anotara/main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  // onAuthStateChange listener to pop the login screen when the user signs in.
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
  void dispose() {
    _authSub.cancel();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  //temporaray notification for erros and other
  void _show(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  // Turn Supabase auth errors into plain-language messages.
  String _friendlyAuthError(AuthException e) {
    final code = (e.code ?? '').toLowerCase();
    final msg = e.message.toLowerCase();

    if (code == 'invalid_credentials' ||
        msg.contains('invalid login credentials')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (code == 'email_not_confirmed' || msg.contains('email not confirmed')) {
      return 'Please verify your email before logging in.';
    }
    if (code == 'over_request_rate_limit' ||
        code == 'over_email_send_rate_limit' ||
        msg.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (code == 'user_banned') {
      return 'This account has been disabled. Please contact support.';
    }
    return 'Unable to log in right now. Please try again.';
  }

  bool _loading = false;

  // sign in with Supabase (email + password).
  Future<void> _logIn() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final response = await supabase.auth.signInWithPassword(
        email: _email.text.trim(),
        password: _password.text,
      );

      if (!mounted) return;

      if (response.user != null) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
      }
    } on AuthException catch (e) {
      _show(_friendlyAuthError(e));
    } on SocketException {
      _show('No internet connection. Please check your network.');
    } catch (_) {
      _show('Something went wrong. Please try again.');
    } finally {
      // Always release the button, including after a failed login.
      if (mounted) setState(() => _loading = false);
    }
  }

  // sign in with Supabase Google OAuth.
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
      _show(_friendlyAuthError(e));
    } catch (_) {
      _show('Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      children: [
        const SizedBox(height: 8),
        const LogoBadge(),
        const SizedBox(height: 24),
        const AuthHeader(title: 'Welcome Back'),
        const SizedBox(height: 28),
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              children: [
                AppTextField(
                  label: 'Email',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: validateEmail,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Password',
                  controller: _password,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  validator: requiredField('Password'),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.black),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
            ),
            child: const Text(
              'Forgot password?',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 20),
        AppButton(label: 'Log In', loading: _loading, onPressed: _logIn),
        const OrDivider(),
        AppButton(
          label: 'Continue with Google',
          icon: Icons.person,
          variant: AppButtonVariant.secondary,
          loading: _googleLoading,
          onPressed: _continueWithGoogle,
        ),
        const SizedBox(height: 32),
        FooterPrompt(
          prompt: "Don't have an account?",
          action: 'Sign Up',
          onTap: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const SignUpScreen()),
          ),
        ),
      ],
    );
  }
}
