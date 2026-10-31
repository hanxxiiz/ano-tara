import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:anotara/main.dart';
import 'package:anotara/screens/auth/start_screen.dart';
import 'package:anotara/models/member_preferences.dart';
import 'package:anotara/services/preferences_service.dart';
import 'package:anotara/screens/onboarding/onboarding_flow.dart'; // adjust to your path

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? supabase.auth.currentSession;
        if (session == null) return const StartScreen();
        // key = user id, so the check re-runs only when the user changes
        return OnboardingCheck(key: ValueKey(session.user.id));
      },
    );
  }
}

class OnboardingCheck extends StatefulWidget {
  const OnboardingCheck({super.key});

  @override
  State<OnboardingCheck> createState() => _OnboardingCheckState();
}

class _OnboardingCheckState extends State<OnboardingCheck> {
  late Future<MemberPreferences?> _future = PreferencesService().load();
  void _retry() => setState(() => _future = PreferencesService().load());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MemberPreferences?>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return Scaffold(
            body: Center(
              child: TextButton(
                onPressed: _retry,
                child: const Text("Couldn't load. Tap to retry."),
              ),
            ),
          );
        }
        return snap.data == null ? const OnboardingFlow() : const HomeScreen();
      },
    );
  }
}
