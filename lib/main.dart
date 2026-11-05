import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_routes.dart';
import 'screens/auth/start_screen.dart';
import 'screens/home_screen.dart';
import 'screens/notifications_screen.dart';
import 'core/routes/app_routes.dart' as core_routes;
import 'core/theme/app_theme.dart' as core_theme;

import 'features/auth/presentation/screens/welcome_screen.dart';
import 'screens/onboarding/onboarding_flow.dart';

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
    // Exclude '/' from routes table since 'home' property is specified
    final Map<String, WidgetBuilder> appRoutes = {
      for (final entry in core_routes.AppRoutes.routes.entries)
        if (entry.key != Navigator.defaultRouteName) entry.key: entry.value,

      AppRoutes.onboarding: (_) => const OnboardingFlow(),
      AppRoutes.editPreferences: (_) => const OnboardingFlow(editing: true),
    };

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ano Tara',
      theme: buildAppTheme(),
      home: const StartScreen(),
      routes: {
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.notifications: (_) => const NotificationsScreen(),
        AppRoutes.onboarding: (_) => const OnboardingFlow(),
        AppRoutes.editPreferences: (_) => const OnboardingFlow(editing: true),
      theme: core_theme.AppTheme.lightTheme,
      home: const WelcomeScreen(),
      routes: appRoutes,
      onGenerateRoute: (settings) {
        if (settings.name == Navigator.defaultRouteName) {
          return MaterialPageRoute(
            builder: (_) => const WelcomeScreen(),
            settings: settings,
          );
        }
        return core_routes.AppRoutes.onGenerateRoute(settings);
      },
    );
  }
}
