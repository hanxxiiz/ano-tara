import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:anotara/services/auth_service.dart';

import 'app_routes.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/profile/presentation/screens/subscription_screen.dart';
import 'screens/home_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/onboarding/onboarding_flow.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mfeoezkjndigezqrcehh.supabase.co',
    publishableKey: 'sb_publishable_AkrMT6v0CFsSfENL1KUovQ_nCIifJ4y',
  );

  runApp(const AnoTaraApp());
}

final supabase = Supabase.instance.client;

class AnoTaraApp extends StatelessWidget {
  const AnoTaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ano Tara',
      theme: buildAppTheme(),
      home: const AuthGate(),
      routes: {
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.onboarding: (_) => const OnboardingFlow(),
        AppRoutes.editPreferences: (_) => const OnboardingFlow(editing: true),
        AppRoutes.notifications: (_) => const NotificationsScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.subscription: (_) => const SubscriptionScreen(),
      },
    );
  }
}

