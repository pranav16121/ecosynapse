import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/state/navigation_state.dart';
import 'collector_collections_screen.dart';
import 'collector_history_screen.dart';
import 'collector_profile_screen.dart';

class CollectorMainScreen extends StatelessWidget {
  const CollectorMainScreen({super.key});

  final List<Widget> _screens = const [
    CollectorCollectionsScreen(),
    CollectorHistoryScreen(),
    CollectorProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navState = context.watch<NavigationState>();
    final selectedIndex = navState.collectorIndex;

    return PopScope(
      canPop: selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (selectedIndex != 0) {
          context.read<NavigationState>().setCollectorIndex(0);
        }
      },
      child: Scaffold(
        body: IndexedStack(index: selectedIndex, children: _screens),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) =>
              context.read<NavigationState>().setCollectorIndex(index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.local_shipping_outlined),
              selectedIcon: Icon(Icons.local_shipping),
              label: 'Collections',
            ),
            NavigationDestination(
              icon: Icon(Icons.history),
              selectedIcon: Icon(Icons.history),
              label: 'History',
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
