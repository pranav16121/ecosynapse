import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/models/recycler.dart';
import '../../../core/state/operational_state.dart';
import '../../../core/widgets/eco_card.dart';

class RecyclerRecoveryScreen extends StatelessWidget {
  const RecyclerRecoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final opState = context.watch<OperationalState>();
    final processedBatches = opState.recyclingBatches
        .where((b) => b.purityPercent > 0)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Recovery Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(EcoSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecoveryStats(context, processedBatches),
            const SizedBox(height: EcoSpacing.l),
            Text('Processing History', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: EcoSpacing.m),
            _buildProcessingHistory(processedBatches),
            const SizedBox(height: EcoSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildRecoveryStats(BuildContext context, List<RecyclingBatch> batches) {
    double totalWeight = batches.fold(0, (sum, b) => sum + b.weightKg);
    double avgPurity =
        batches.isEmpty
            ? 0
            : batches.fold(0, (sum, b) => sum + b.purityPercent) /
                batches.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Recovered Today',
                '124 kg',
                Icons.today,
                Colors.green,
              ),
            ),
            const SizedBox(width: EcoSpacing.m),
            Expanded(
              child: _buildMetricCard(
                'Avg Purity',
                '${avgPurity.toStringAsFixed(1)}%',
                Icons.verified_outlined,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: EcoSpacing.m),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Recovery Rate',
                '91%',
                Icons.auto_graph,
                Colors.orange,
              ),
            ),
            const SizedBox(width: EcoSpacing.m),
            Expanded(
              child: _buildMetricCard(
                'Total Recovered',
                '${totalWeight.toStringAsFixed(0)} kg',
                Icons.fitness_center,
                Colors.teal,
              ),
            ),
          ],
        ),
        const SizedBox(height: EcoSpacing.xl),
        Text(
          'Environmental Impact',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: EcoSpacing.m),
        _buildImpactGrid(context, totalWeight),
      ],
    );
  }

  Widget _buildImpactGrid(BuildContext context, double totalWeight) {
    return Wrap(
      spacing: EcoSpacing.m,
      runSpacing: EcoSpacing.m,
      children: [
        _buildImpactItem(
          context,
          Icons.cloud_done_outlined,
          'CO₂ Saved',
          '${(totalWeight * 2.5).toStringAsFixed(0)} kg',
          Colors.blue,
        ),
        _buildImpactItem(
          context,
          Icons.park_outlined,
          'Trees Equiv.',
          '${(totalWeight / 50).toStringAsFixed(1)}',
          Colors.green,
        ),
        _buildImpactItem(
          context,
          Icons.delete_sweep_outlined,
          'Landfill Div.',
          '${totalWeight.toStringAsFixed(0)} kg',
          Colors.brown,
        ),
      ],
    );
  }

  Widget _buildImpactItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      width:
          (MediaQuery.of(context).size.width -
              (EcoSpacing.l * 2) -
              EcoSpacing.m) /
          2,
      child: EcoCard(
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: EcoSpacing.s),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String label, String value, IconData icon, Color color) {
    return EcoCard(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: EcoSpacing.s),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildProcessingHistory(List<RecyclingBatch> batches) {
    if (batches.isEmpty) {
      return const EcoCard(
        child: Center(child: Text('No batches processed yet.')),
      );
    }
    return Column(
      children: [
        ...batches.map(
          (b) => Padding(
            padding: const EdgeInsets.only(bottom: EcoSpacing.s),
            child: EcoCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.check, color: Colors.green, size: 16),
                  ),
                  const SizedBox(width: EcoSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${b.category.name.toUpperCase()} Batch',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${b.weightKg.toStringAsFixed(1)} kg | Recovery: 98%',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${b.purityPercent}% Purity',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${b.timestamp.day}/${b.timestamp.month}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
