import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/state/operational_state.dart';
import '../../../core/state/navigation_state.dart';
import 'admin_overview_screen.dart';
import 'admin_bins_screen.dart';
import 'admin_logistics_screen.dart';
import 'admin_community_screen.dart';
import 'admin_accounts_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  final List<Widget> _screens = const [
    AdminOverviewScreen(),
    AdminBinsScreen(),
    AdminLogisticsScreen(),
    AdminCommunityScreen(),
    AdminAccountsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OperationalState>().initialize(
        MockData.getCommunityBins(),
        [...MockData.getInitialRequests(), ...MockData.getCompletedCollections()],
        [...MockData.getIncomingBatches(), ...MockData.getProcessedHistory()],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final rawIndex = context.watch<NavigationState>().adminIndex;
    final selectedIndex = rawIndex >= _screens.length ? 0 : rawIndex;

    return PopScope(
      canPop: selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (selectedIndex != 0) {
          context.read<NavigationState>().setAdminIndex(0);
        }
      },
      child: Scaffold(
        body: IndexedStack(index: selectedIndex, children: _screens),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) =>
              context.read<NavigationState>().setAdminIndex(index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Overview',
            ),
            NavigationDestination(
              icon: Icon(Icons.delete_outline),
              selectedIcon: Icon(Icons.delete),
              label: 'Bins',
            ),
            NavigationDestination(
              icon: Icon(Icons.local_shipping_outlined),
              selectedIcon: Icon(Icons.local_shipping),
              label: 'Logistics',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: 'Community',
            ),
            NavigationDestination(
              icon: Icon(Icons.manage_accounts_outlined),
              selectedIcon: Icon(Icons.manage_accounts),
              label: 'Accounts',
            ),
          ],
        ),
      ),
    );
  }
}
