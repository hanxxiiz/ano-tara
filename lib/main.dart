import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://mfeoezkjndigezqrcehh.supabase.co',
      publishableKey: 'sb_publishable_AkrMT6v0CFsSfENL1KUovQ_nCIifJ4y',
    );
  } catch (e) {
    debugPrint('Supabase initialization notice: $e');
  }

  runApp(const AnoTaraApp());
}

class AnoTaraApp extends StatelessWidget {
  const AnoTaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ano Tara',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.welcome,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
