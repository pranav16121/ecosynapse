import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/widgets/eco_card.dart';
import '../../../core/widgets/eco_button.dart';

class AdminLanding extends StatelessWidget {
  const AdminLanding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Experience')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(EcoSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Community Administration',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: EcoSpacing.xl),
            const EcoMetricCard(
              label: 'Total Residents',
              value: '1,240',
              icon: Icons.people,
            ),
            const SizedBox(height: EcoSpacing.m),
            const EcoMetricCard(
              label: 'Active Smart Bins',
              value: '42',
              icon: Icons.delete_outline,
              iconColor: Colors.blue,
            ),
            const SizedBox(height: EcoSpacing.xl),
            EcoCard(
              child: Column(
                children: [
                  const Icon(
                    Icons.analytics_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: EcoSpacing.m),
                  Text(
                    'Admin Dashboard Pending',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: EcoSpacing.s),
                  const Text(
                    'Tools for managing bins, collection schedules, and community analytics will be available in Stage 2.',
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
