import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/models/enums.dart';
import '../../../core/state/auth_state.dart';
import '../../../core/state/operational_state.dart';
import '../../../core/state/navigation_state.dart';
import '../../../core/widgets/eco_card.dart';

class CollectorProfileScreen extends StatelessWidget {
  const CollectorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthState>().currentUser;
    final opState = context.watch<OperationalState>();
    final completedCount = opState.collectionRequests
        .where((r) => r.status == CollectionStatus.completed)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Collector Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(EcoSpacing.l),
        child: Column(
          children: [
            _buildProfileHeader(context, user, completedCount),
            const SizedBox(height: EcoSpacing.xl),
            _buildOperationalMetrics(context),
            const SizedBox(height: EcoSpacing.xl),
            _buildMenu(context),
            const SizedBox(height: EcoSpacing.xl),
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: EcoSpacing.m,
              runSpacing: EcoSpacing.s,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    await context.read<AuthState>().logout();
                    if (context.mounted) {
                      context.go('/auth-portal');
                    }
                  },
                  icon: const Icon(Icons.swap_horiz, size: 18),
                  label: const Text('Switch Portal'),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await context.read<AuthState>().logout();
                    if (context.mounted) {
                      context.go('/auth-portal');
                    }
                  },
                  icon: const Icon(Icons.logout, size: 18, color: Colors.red),
                  label: const Text('Log Out', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user, int count) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          child: Icon(Icons.local_shipping, size: 50),
        ),
        const SizedBox(height: EcoSpacing.m),
        Text(
          'Ramesh Kumar',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const Text(
          'Role: Collection Operator',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green),
        ),
        const Text(
          'Employee ID: COL-104',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: EcoSpacing.l),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatItem(context, 'Today', '18'),
            const SizedBox(width: EcoSpacing.xxl),
            _buildStatItem(context, 'Shift', 'Morning'),
            const SizedBox(width: EcoSpacing.xxl),
            _buildStatItem(context, 'Performance', '96%'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildOperationalMetrics(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Achievements', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: EcoSpacing.m),
        Row(
          children: [
            Expanded(
              child: _buildMetricMini(
                context,
                'Fast Response',
                'Top 5%',
                Icons.speed,
                Colors.orange,
              ),
            ),
            const SizedBox(width: EcoSpacing.m),
            Expanded(
              child: _buildMetricMini(
                context,
                'Zero Missed',
                'Perfect',
                Icons.check_circle_outline,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: EcoSpacing.m),
        const EcoCard(
          child: ListTile(
            leading: Icon(Icons.workspace_premium, color: Colors.amber),
            title: Text('Top Collector - July 2026'),
            subtitle: Text('Highest weight collected in Greenwood'),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricMini(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return EcoCard(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: EcoSpacing.s),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return EcoCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildMenuItem(Icons.assignment_outlined, 'Assigned Area', () {}),
          const Divider(height: 1),
          _buildMenuItem(Icons.map_outlined, 'Route Preferences', () {}),
          const Divider(height: 1),
          _buildMenuItem(Icons.history, 'Full History', () => context.read<NavigationState>().setCollectorIndex(1)),
          const Divider(height: 1),
          _buildMenuItem(Icons.help_outline, 'Logistics Support', () {}),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
