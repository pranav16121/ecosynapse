import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ecosynapse/core/state/auth_state.dart';
import 'package:ecosynapse/core/state/resident_state.dart';
import 'package:ecosynapse/app/theme/theme.dart';
import 'package:ecosynapse/core/state/operational_state.dart';
import 'package:ecosynapse/core/state/navigation_state.dart';
import 'package:ecosynapse/features/auth/screens/resident_login_screen.dart';
import 'package:ecosynapse/features/auth/screens/resident_signup_screen.dart';
import 'package:ecosynapse/features/auth/screens/admin_login_screen.dart';
import 'package:ecosynapse/features/auth/screens/collector_login_screen.dart';
import 'package:ecosynapse/features/auth/screens/recycler_login_screen.dart';
import 'package:ecosynapse/features/role_selection/screens/role_selector_screen.dart';
import 'package:ecosynapse/features/resident/screens/home_screen.dart';
import 'package:ecosynapse/features/impact/screens/impact_screen.dart';
import 'package:ecosynapse/features/rewards/screens/rewards_screen.dart';
import 'package:ecosynapse/features/community/screens/community_screen.dart';
import 'package:ecosynapse/features/profile/screens/profile_screen.dart';
import 'package:ecosynapse/features/bins/screens/bins_screen.dart';
import 'package:ecosynapse/features/admin/screens/admin_main_screen.dart';
import 'package:ecosynapse/features/admin/screens/admin_accounts_screen.dart';
import 'package:ecosynapse/features/collector/screens/collector_main_screen.dart';
import 'package:ecosynapse/features/recycler/screens/recycler_main_screen.dart';

void main() {
  Future<void> testScreen(
    WidgetTester tester, {
    required Widget screen,
    required String name,
    double width = 360,
  }) async {
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
  }

  group('Responsive Audit - 360dp Width Portals', () {
    testWidgets('Resident Login Screen', (tester) async {
      await testScreen(tester, screen: const ResidentLoginScreen(), name: 'ResidentLogin');
      expect(find.text('Resident Portal'), findsOneWidget);
    });

    testWidgets('Resident Signup Screen', (tester) async {
      await testScreen(tester, screen: const ResidentSignupScreen(), name: 'ResidentSignup');
      expect(find.text('Create Resident Account'), findsAtLeastNWidgets(1));
    });

    testWidgets('Admin Login Screen', (tester) async {
      await testScreen(tester, screen: const AdminLoginScreen(), name: 'AdminLogin');
      expect(find.text('Admin Operations Portal'), findsOneWidget);
    });

    testWidgets('Collector Login Screen', (tester) async {
      await testScreen(tester, screen: const CollectorLoginScreen(), name: 'CollectorLogin');
      expect(find.text('Collector Portal'), findsOneWidget);
    });

    testWidgets('Recycler Login Screen', (tester) async {
      await testScreen(tester, screen: const RecyclerLoginScreen(), name: 'RecyclerLogin');
      expect(find.text('Recycler Portal'), findsOneWidget);
    });

    testWidgets('Role Selector', (tester) async {
      await testScreen(
        tester,
        screen: const RoleSelectorScreen(),
        name: 'RoleSelector',
      );
      expect(find.text('EcoSynapse'), findsOneWidget);
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

    testWidgets('Admin Accounts Screen', (tester) async {
      await testScreen(tester, screen: const AdminAccountsScreen(), name: 'AdminAccounts');
      expect(find.text('Account Management'), findsOneWidget);
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
