import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/state/auth_state.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/eco_card.dart';
import '../../../core/widgets/eco_button.dart';

class ResidentLanding extends StatelessWidget {
  const ResidentLanding({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = MockData.getResidentMetrics();
    final user = context.watch<AuthState>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resident Experience'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthState>().logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(EcoSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user?.fullName ?? "Resident"}',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: EcoSpacing.s),
            const Text('Your sustainability dashboard at a glance.'),
            const SizedBox(height: EcoSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: EcoMetricCard(
                    label: 'EcoScore',
                    value: '${metrics['ecoScore']}',
                    icon: Icons.trending_up,
                  ),
                ),
                const SizedBox(width: EcoSpacing.m),
                Expanded(
                  child: EcoMetricCard(
                    label: 'EcoPoints',
                    value: '${metrics['ecoPoints']}',
                    icon: Icons.stars,
                    iconColor: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: EcoSpacing.xl),
            EcoCard(
              child: Column(
                children: [
                  const Icon(Icons.construction, size: 48, color: Colors.grey),
                  const SizedBox(height: EcoSpacing.m),
                  Text(
                    'Module Under Development',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: EcoSpacing.s),
                  const Text(
                    'The full resident dashboard with real-time tracking, challenges, and rewards will be implemented in Stage 2.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: EcoSpacing.l),
                  EcoButton(
                    label: 'Back to Role Selector',
                    type: EcoButtonType.secondary,
                    onPressed: () => context.go('/role-selector'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
