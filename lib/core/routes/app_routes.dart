import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/verification_code_screen.dart';
import '../../features/auth/presentation/screens/create_new_password_screen.dart';
import '../../features/auth/presentation/screens/password_updated_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_flow_screen.dart';
import '../../features/shell/presentation/screens/main_shell_screen.dart';
import '../../features/showcase/presentation/screens/component_showcase_screen.dart';

/// Centralized route definitions and generator.
/// Adding a new screen needs only a new route string and its screen widget in [routes].
class AppRoutes {
  AppRoutes._();

  // Authentication Routes
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verificationCode = '/verify-code';
  static const String createNewPassword = '/create-new-password';
  static const String passwordUpdated = '/password-updated';

  // Onboarding
  static const String onboarding = '/onboarding';

  // Main App Shell (with 5 bottom nav tabs: Home, Trips, Create, Groups, Profile)
  static const String main = '/main';

  // Design System Showcase / Component Gallery
  static const String showcase = '/showcase';

  /// Map of all available named routes
  static Map<String, WidgetBuilder> get routes => {
        welcome: (context) => const WelcomeScreen(),
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        forgotPassword: (context) => const ForgotPasswordScreen(),
        verificationCode: (context) => const VerificationCodeScreen(),
        createNewPassword: (context) => const CreateNewPasswordScreen(),
        passwordUpdated: (context) => const PasswordUpdatedScreen(),
        onboarding: (context) => const OnboardingFlowScreen(),
        main: (context) => const MainShellScreen(),
        showcase: (context) => const ComponentShowcaseScreen(),
      };

  /// Route generator for parameterized navigation
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(
        builder: builder,
        settings: settings,
      );
    }

    // Fallback route
    return MaterialPageRoute(
      builder: (context) => const WelcomeScreen(),
      settings: settings,
    );
  }
}
