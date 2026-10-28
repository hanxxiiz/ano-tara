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
import '../../features/trips/presentation/screens/plan_trip_screen.dart';
import '../../features/groups/presentation/screens/group_overview_screen.dart';
import '../../features/groups/presentation/screens/create_group_flow_screen.dart';
import '../../features/groups/presentation/screens/group_detail_screen.dart';
import '../../features/chat/presentation/screens/group_chat_screen.dart';
import '../../features/trips/presentation/screens/trip_overview_screen.dart';
import '../../features/notifications/presentation/screens/invitations_screen.dart';
import '../../features/expenses/presentation/screens/expense_updates_screen.dart';
import '../../features/trips/presentation/screens/member_responses_screen.dart';

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

  // Detailed App Screens
  static const String planTrip = '/plan-trip';
  static const String groupOverview = '/group-overview';
  static const String groupDetail = '/group-detail';
  static const String groupChat = '/group-chat';
  static const String createGroup = '/create-group';
  static const String tripOverview = '/trip-overview';
  static const String invitations = '/invitations';
  static const String expenseUpdates = '/expense-updates';
  static const String memberResponses = '/member-responses';

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
        planTrip: (context) => const PlanTripScreen(),
        groupOverview: (context) => const GroupOverviewScreen(),
        groupDetail: (context) => const GroupDetailScreen(),
        groupChat: (context) => const GroupChatScreen(),
        createGroup: (context) => const CreateGroupFlowScreen(),
        tripOverview: (context) => const TripOverviewScreen(),
        invitations: (context) => const InvitationsScreen(),
        expenseUpdates: (context) => const ExpenseUpdatesScreen(),
        memberResponses: (context) => const MemberResponsesScreen(),
        showcase: (context) => const ComponentShowcaseScreen(),
      };

  /// Route generator for parameterized navigation
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == planTrip) {
      final groupName = settings.arguments as String?;
      return MaterialPageRoute(
        builder: (context) => PlanTripScreen(initialGroupName: groupName),
        settings: settings,
      );
    }
    if (settings.name == groupOverview) {
      final groupName = (settings.arguments as String?) ?? 'The Group';
      return MaterialPageRoute(
        builder: (context) => GroupOverviewScreen(groupName: groupName),
        settings: settings,
      );
    }
    if (settings.name == groupDetail) {
      final groupName = (settings.arguments as String?) ?? 'Trip to Bantayan';
      return MaterialPageRoute(
        builder: (context) => GroupDetailScreen(groupName: groupName),
        settings: settings,
      );
    }
    if (settings.name == groupChat) {
      final groupName = (settings.arguments as String?) ?? 'Hannah Dul Set';
      return MaterialPageRoute(
        builder: (context) => GroupChatScreen(groupName: groupName),
        settings: settings,
      );
    }

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
