import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_routes.dart';
import 'core/routes/app_routes.dart' as core_routes;
import 'core/theme/app_theme.dart' as core_theme;
import 'features/shell/presentation/screens/main_shell_screen.dart';
import 'screens/component_preview_screen.dart';
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
      AppRoutes.home: (_) => const HomeScreen(),
      AppRoutes.onboarding: (_) => const OnboardingFlow(),
      AppRoutes.editPreferences: (_) => const OnboardingFlow(editing: true),
    };

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ano Tara',
      theme: core_theme.AppTheme.lightTheme,
      home: const ComponentPreviewScreen(),
      routes: appRoutes,
      onGenerateRoute: (settings) {
        if (settings.name == Navigator.defaultRouteName) {
          return MaterialPageRoute(
            builder: (_) => const ComponentPreviewScreen(),
            settings: settings,
          );
        }
        return core_routes.AppRoutes.onGenerateRoute(settings);
      },
    );
  }
}

/// Home screen displayed when logged in.
/// Renders the complete Ano Tara navigation shell with the 5 bottom tabs
/// (Home, Trips, Create, Groups, Profile) matching the design mockup.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainShellScreen();
  }
}
