import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/state/operational_state.dart';
import '../../../core/state/navigation_state.dart';
import 'recycler_incoming_screen.dart';
import 'recycler_recovery_screen.dart';
import 'recycler_profile_screen.dart';

class RecyclerMainScreen extends StatefulWidget {
  const RecyclerMainScreen({super.key});

  @override
  State<RecyclerMainScreen> createState() => _RecyclerMainScreenState();
}

class _RecyclerMainScreenState extends State<RecyclerMainScreen> {
  final List<Widget> _screens = const [
    RecyclerIncomingScreen(),
    RecyclerRecoveryScreen(),
    RecyclerProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final opState = context.read<OperationalState>();
      if (opState.recyclingBatches.isEmpty) {
        opState.initialize(
          MockData.getCommunityBins(),
          [...MockData.getInitialRequests(), ...MockData.getCompletedCollections()],
          [...MockData.getIncomingBatches(), ...MockData.getProcessedHistory()],
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final navState = context.watch<NavigationState>();
    final selectedIndex = navState.recyclerIndex;

    return PopScope(
      canPop: selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (selectedIndex != 0) {
          context.read<NavigationState>().setRecyclerIndex(0);
        }
      },
      child: Scaffold(
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
      ),
    );
  }
}
