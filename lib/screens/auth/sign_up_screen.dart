import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:anotara/main.dart';
import '../../components/atoms/app_button.dart';
import '../../components/atoms/app_input_field.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import 'login_screen.dart';
import 'validators.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  bool _googleLoading = false;
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
    _firstName.dispose();
    _lastName.dispose();
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _show(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _signUp() async {
    if (_loading) return;
    final err = requiredField('First name')(_firstName.text) ??
        requiredField('Last name')(_lastName.text) ??
        requiredField('Username')(_username.text) ??
        validateEmail(_email.text) ??
        validatePassword(_password.text);
    if (err != null) {
      _show(err);
      return;
    }

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
        emailRedirectTo: 'io.supabase.anotara://login-callback/',
        data: {
          'first_name': _firstName.text.trim(),
          'last_name': _lastName.text.trim(),
          'username': username,
        },
      );
      if (!mounted) return;

      if (response.user?.identities?.isEmpty ?? false) {
        _show('An account with this email already exists. Try logging in.');
        return;
      }

      if (response.session == null) {
        _show('Check your email to confirm your account.');
        return;
      }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 24, 26, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 132,
                  height: 132,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryOrange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Create Your Account',
                textAlign: TextAlign.center,
                style: AppTypography.h2.copyWith(color: AppColors.secondaryDark),
              ),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppInputField(
                      label: 'First Name',
                      controller: _firstName,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: AppInputField(
                      label: 'Last Name',
                      controller: _lastName,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              AppInputField(
                label: 'Username',
                controller: _username,
              ),
              const SizedBox(height: 13),
              AppInputField(
                label: 'Email',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 13),
              AppInputField(
                label: 'Password',
                controller: _password,
                isPassword: true,
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Sign Up',
                isLoading: _loading,
                onPressed: _signUp,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Text(
                  'or',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: AppColors.secondaryDark),
                ),
              ),
              AppButton.google(
                onPressed: _continueWithGoogle,
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(fontSize: 14, color: AppColors.secondaryDark),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
