import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/state/auth_state.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/role_selection/screens/role_selector_screen.dart';
import '../../features/resident/screens/resident_main_screen.dart';
import '../../features/resident/screens/activity_history_screen.dart';
import '../../features/bins/screens/bin_detail_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/admin/screens/admin_main_screen.dart';
import '../../features/collector/screens/collector_main_screen.dart';
import '../../features/recycler/screens/recycler_main_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authState = context.read<AuthState>();
      final isLoggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/forgot-password';

      final isOnboarding = state.matchedLocation == '/onboarding';
      final isSplash = state.matchedLocation == '/';

      if (!authState.isOnboardingComplete && !isSplash && !isOnboarding) {
        return '/onboarding';
      }

      if (authState.isOnboardingComplete &&
          !authState.isAuthenticated &&
          !isLoggingIn &&
          !isSplash) {
        return '/login';
      }

      if (authState.isAuthenticated && isLoggingIn) {
        return '/role-selector';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/role-selector',
        builder: (context, state) => const RoleSelectorScreen(),
      ),
      GoRoute(
        path: '/resident',
        builder: (context, state) => const ResidentMainScreen(),
      ),
      GoRoute(
        path: '/activity',
        builder: (context, state) => const ActivityHistoryScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/bin-detail',
        builder: (context, state) =>
            BinDetailScreen(bin: state.extra as Map<String, dynamic>),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminMainScreen(),
      ),
      GoRoute(
        path: '/collector',
        builder: (context, state) => const CollectorMainScreen(),
      ),
      GoRoute(
        path: '/recycler',
        builder: (context, state) => const RecyclerMainScreen(),
      ),
    ],
  );
}
