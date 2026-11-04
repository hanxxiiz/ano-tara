import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_routes.dart';
import 'screens/auth/start_screen.dart';
import 'screens/create_group/create_group_screen.dart';
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

class AnoTaraApp extends StatelessWidget {
  const AnoTaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ano Tara',
      theme: buildAppTheme(),
      home: const StartScreen(),
      routes: {
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.notifications: (_) => const NotificationsScreen(),
        AppRoutes.onboarding: (_) => const OnboardingFlow(),
        AppRoutes.createGroup: (_) => const CreateGroupScreen(),
        AppRoutes.editPreferences: (_) => const OnboardingFlow(editing: true),
      },
    );
  }
}
