import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/state/navigation_state.dart';
import 'recycler_incoming_screen.dart';
import 'recycler_recovery_screen.dart';
import 'recycler_profile_screen.dart';

class RecyclerMainScreen extends StatelessWidget {
  const RecyclerMainScreen({super.key});

  final List<Widget> _screens = const [
    RecyclerIncomingScreen(),
    RecyclerRecoveryScreen(),
    RecyclerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = context.watch<NavigationState>().recyclerIndex;

    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) =>
            context.read<NavigationState>().setRecyclerIndex(index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Incoming',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Recovery',
          ),
          NavigationDestination(
            icon: Icon(Icons.factory_outlined),
            selectedIcon: Icon(Icons.factory),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
