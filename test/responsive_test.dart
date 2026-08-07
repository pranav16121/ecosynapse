import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ecosynapse/core/state/auth_state.dart';
import 'package:ecosynapse/core/state/resident_state.dart';
import 'package:ecosynapse/app/theme/theme.dart';
import 'package:ecosynapse/core/state/operational_state.dart';
import 'package:ecosynapse/core/state/navigation_state.dart';
import 'package:ecosynapse/features/auth/screens/login_screen.dart';
import 'package:ecosynapse/features/auth/screens/signup_screen.dart';
import 'package:ecosynapse/features/role_selection/screens/role_selector_screen.dart';
import 'package:ecosynapse/features/resident/screens/home_screen.dart';
import 'package:ecosynapse/features/impact/screens/impact_screen.dart';
import 'package:ecosynapse/features/rewards/screens/rewards_screen.dart';
import 'package:ecosynapse/features/community/screens/community_screen.dart';
import 'package:ecosynapse/features/profile/screens/profile_screen.dart';
import 'package:ecosynapse/features/bins/screens/bins_screen.dart';
import 'package:ecosynapse/features/admin/screens/admin_main_screen.dart';
import 'package:ecosynapse/features/collector/screens/collector_main_screen.dart';
import 'package:ecosynapse/features/recycler/screens/recycler_main_screen.dart';

void main() {
  Future<void> testScreen(
    WidgetTester tester, {
    required Widget screen,
    required String name,
    double width = 360,
  }) async {
    // Set viewport
    tester.view.physicalSize = Size(width * 3, 800 * 3);
    tester.view.devicePixelRatio = 3.0;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthState()),
          ChangeNotifierProvider(create: (_) => ResidentState()),
          ChangeNotifierProvider(create: (_) => OperationalState()),
          ChangeNotifierProvider(create: (_) => NavigationState()),
        ],
        child: MaterialApp(theme: EcoTheme.light, home: screen),
      ),
    );

    await tester.pumpAndSettle();

    // Check for overflows by looking at logs or exceptions.
    // Flutter test will fail automatically if a RenderFlex overflow is detected in many environments,
    // or we can check the error log if needed.
  }

  group('Responsive Audit - 360dp Width', () {
    testWidgets('Login Screen', (tester) async {
      await testScreen(tester, screen: const LoginScreen(), name: 'Login');
      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('Signup Screen', (tester) async {
      await testScreen(tester, screen: const SignupScreen(), name: 'Signup');
      expect(find.byKey(const Key('signup_title')), findsOneWidget);
    });

    testWidgets('Role Selector', (tester) async {
      await testScreen(
        tester,
        screen: const RoleSelectorScreen(),
        name: 'RoleSelector',
      );
      expect(find.text('Choose your experience'), findsOneWidget);
    });

    testWidgets('Resident Home', (tester) async {
      await testScreen(tester, screen: const HomeScreen(), name: 'Home');
      expect(find.text('EcoScore'), findsOneWidget);
    });

    testWidgets('Impact Screen', (tester) async {
      await testScreen(tester, screen: const ImpactScreen(), name: 'Impact');
      expect(find.text('Environmental Impact'), findsOneWidget);
    });

    testWidgets('Rewards Screen', (tester) async {
      await testScreen(tester, screen: const RewardsScreen(), name: 'Rewards');
      expect(find.text('EcoPoints & Rewards'), findsOneWidget);
    });

    testWidgets('Community Screen', (tester) async {
      await testScreen(
        tester,
        screen: const CommunityScreen(),
        name: 'Community',
      );
      expect(find.text('Community Hub'), findsOneWidget);
    });

    testWidgets('Profile Screen', (tester) async {
      await testScreen(tester, screen: const ProfileScreen(), name: 'Profile');
      expect(find.text('My Profile'), findsOneWidget);
    });

    testWidgets('Bins Screen', (tester) async {
      await testScreen(tester, screen: const BinsScreen(), name: 'Bins');
      expect(find.text('Smart Bins'), findsOneWidget);
    });

    testWidgets('Admin Main', (tester) async {
      await testScreen(tester, screen: const AdminMainScreen(), name: 'AdminMain');
      expect(find.byType(AdminMainScreen), findsOneWidget);
    });

    testWidgets('Collector Main', (tester) async {
      await testScreen(tester, screen: const CollectorMainScreen(), name: 'CollectorMain');
      expect(find.byType(CollectorMainScreen), findsOneWidget);
    });

    testWidgets('Recycler Main', (tester) async {
      await testScreen(tester, screen: const RecyclerMainScreen(), name: 'RecyclerMain');
      expect(find.byType(RecyclerMainScreen), findsOneWidget);
    });
  });
}
