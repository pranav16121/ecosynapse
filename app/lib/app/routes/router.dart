import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/models/enums.dart';
import '../../core/state/auth_state.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/resident_login_screen.dart';
import '../../features/auth/screens/resident_signup_screen.dart';
import '../../features/auth/screens/admin_login_screen.dart';
import '../../features/auth/screens/collector_login_screen.dart';
import '../../features/auth/screens/recycler_login_screen.dart';
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
      final loc = state.matchedLocation;

      final isAuthFlow =
          loc == '/auth-portal' ||
          loc == '/role-selector' ||
          loc == '/login' ||
          loc == '/signup' ||
          loc == '/resident-login' ||
          loc == '/resident-signup' ||
          loc == '/admin-login' ||
          loc == '/collector-login' ||
          loc == '/recycler-login' ||
          loc == '/forgot-password';

      final isOnboarding = loc == '/onboarding';
      final isSplash = loc == '/';

      // 1. Loading session or SharedPreferences on cold start: hold on splash screen
      if (authState.isLoading) {
        return isSplash ? null : '/';
      }

      // 2. Unauthenticated & Onboarding NOT completed:
      if (!authState.isAuthenticated && !authState.isOnboardingComplete) {
        return (isSplash || isOnboarding) ? null : '/onboarding';
      }

      // 3. Unauthenticated & Onboarding IS completed:
      if (!authState.isAuthenticated && authState.isOnboardingComplete) {
        return isAuthFlow ? null : '/auth-portal';
      }

      // 4. Authenticated:
      if (authState.isAuthenticated) {
        if (isSplash || isOnboarding || isAuthFlow) {
          final role = authState.currentUser?.role ?? UserRole.resident;
          switch (role) {
            case UserRole.resident:
              return '/resident';
            case UserRole.admin:
              return '/admin';
            case UserRole.collector:
              return '/collector';
            case UserRole.recycler:
              return '/recycler';
          }
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth-portal',
        builder: (context, state) => const RoleSelectorScreen(),
      ),
      GoRoute(
        path: '/role-selector',
        builder: (context, state) => const RoleSelectorScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const RoleSelectorScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const ResidentSignupScreen(),
      ),
      GoRoute(
        path: '/resident-login',
        builder: (context, state) => const ResidentLoginScreen(),
      ),
      GoRoute(
        path: '/resident-signup',
        builder: (context, state) => const ResidentSignupScreen(),
      ),
      GoRoute(
        path: '/admin-login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/collector-login',
        builder: (context, state) => const CollectorLoginScreen(),
      ),
      GoRoute(
        path: '/recycler-login',
        builder: (context, state) => const RecyclerLoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
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
            BinDetailScreen(bin: state.extra),
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
