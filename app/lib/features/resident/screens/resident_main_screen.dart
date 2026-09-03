import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/state/navigation_state.dart';
import 'home_screen.dart';
import '../../impact/screens/impact_screen.dart';
import '../../rewards/screens/rewards_screen.dart';
import '../../community/screens/community_screen.dart';
import '../../profile/screens/profile_screen.dart';

class ResidentMainScreen extends StatelessWidget {
  const ResidentMainScreen({super.key});

  final List<Widget> _screens = const [
    HomeScreen(),
    ImpactScreen(),
    RewardsScreen(),
    CommunityScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navState = context.watch<NavigationState>();
    final selectedIndex = navState.residentIndex;

    return PopScope(
      canPop: selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (selectedIndex != 0) {
          context.read<NavigationState>().setResidentIndex(0);
        }
      },
      child: Scaffold(
        body: IndexedStack(index: selectedIndex, children: _screens),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) =>
              context.read<NavigationState>().setResidentIndex(index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Impact',
            ),
            NavigationDestination(
              icon: Icon(Icons.stars_outlined),
              selectedIcon: Icon(Icons.stars),
              label: 'Rewards',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: 'Community',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
