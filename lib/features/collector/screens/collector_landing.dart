import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/widgets/eco_card.dart';
import '../../../core/widgets/eco_button.dart';

class CollectorLanding extends StatelessWidget {
  const CollectorLanding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Collector Experience')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(EcoSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Collection Logistics',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: EcoSpacing.xl),
            const EcoMetricCard(
              label: 'Pending Pickups',
              value: '18',
              icon: Icons.assignment_outlined,
              iconColor: Colors.orange,
            ),
            const SizedBox(height: EcoSpacing.m),
            const EcoMetricCard(
              label: 'Optimized Route',
              value: '4.2 km',
              icon: Icons.map_outlined,
              iconColor: Colors.green,
            ),
            const SizedBox(height: EcoSpacing.xl),
            EcoCard(
              child: Column(
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: EcoSpacing.m),
                  Text(
                    'Logistics Tools Coming Soon',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: EcoSpacing.s),
                  const Text(
                    'Real-time route optimization, bin status alerts, and collection logging will be implemented in Stage 2.',
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
