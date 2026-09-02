import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/widgets/eco_card.dart';
import '../../../core/widgets/eco_button.dart';

class RecyclerLanding extends StatelessWidget {
  const RecyclerLanding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recycler Experience')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(EcoSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Material Recovery',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: EcoSpacing.xl),
            const EcoMetricCard(
              label: 'Incoming Batch',
              value: '450 kg',
              icon: Icons.inventory_2_outlined,
            ),
            const SizedBox(height: EcoSpacing.m),
            const EcoMetricCard(
              label: 'Recovery Rate',
              value: '84%',
              icon: Icons.recycling,
              iconColor: Colors.teal,
            ),
            const SizedBox(height: EcoSpacing.xl),
            EcoCard(
              child: Column(
                children: [
                  const Icon(
                    Icons.factory_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: EcoSpacing.m),
                  Text(
                    'Recovery Tracking Pending',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: EcoSpacing.s),
                  const Text(
                    'Batch processing, purity tracking, and environmental impact reporting will be available in Stage 2.',
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
