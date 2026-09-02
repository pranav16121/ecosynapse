import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/recycler.dart';
import '../../../core/state/operational_state.dart';
import '../../../core/widgets/eco_card.dart';
import '../../../core/widgets/eco_button.dart';

class RecyclerIncomingScreen extends StatelessWidget {
  const RecyclerIncomingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final opState = context.watch<OperationalState>();
    final pendingBatches = opState.recyclingBatches
        .where((b) => b.purityPercent == 0)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Incoming Batches')),
      body: pendingBatches.isEmpty
          ? const Center(child: Text('No incoming batches at the moment.'))
          : ListView.builder(
              padding: const EdgeInsets.all(EcoSpacing.l),
              itemCount: pendingBatches.length,
              itemBuilder: (context, index) =>
                  _buildBatchCard(context, pendingBatches[index], opState),
            ),
    );
  }

  Widget _buildBatchCard(
    BuildContext context,
    RecyclingBatch batch,
    OperationalState opState,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: EcoSpacing.m),
      child: EcoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${batch.id}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                ),
                _buildCategoryChip(batch.category),
              ],
            ),
            const SizedBox(height: EcoSpacing.m),
            Row(
              children: [
                const Icon(Icons.business_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                const Text(
                  'Source: Greenwood Residency',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: EcoSpacing.s),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    context,
                    'Weight',
                    '${batch.weightKg.toStringAsFixed(1)} kg',
                    Icons.fitness_center,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    context,
                    'Arrived',
                    _formatDate(batch.timestamp),
                    Icons.access_time,
                  ),
                ),
              ],
            ),
            const Divider(height: EcoSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: EcoButton(
                    label: 'Process Batch',
                    onPressed: () => _showProcessDialog(context, batch, opState),
                  ),
                ),
                const SizedBox(width: EcoSpacing.m),
                EcoButton(
                  label: 'Reject',
                  type: EcoButtonType.secondary,
                  fullWidth: false,
                  onPressed: () => _showRejectDialog(context, batch),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(WasteCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(EcoRadius.small),
      ),
      child: Text(
        category.name.toUpperCase(),
        style: const TextStyle(
          color: Colors.teal,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, RecyclingBatch batch) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reject Batch'),
            content: const Text(
              'Select rejection reason: \n\n• High Contamination\n• Invalid Material\n• Source Dispute',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Batch rejection reported.')),
                  );
                },
                child: const Text('Confirm Rejection'),
              ),
            ],
          ),
    );
  }

  void _showProcessDialog(
    BuildContext context,
    RecyclingBatch batch,
    OperationalState opState,
  ) {
    int purity = 85;
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Process Batch'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Measured purity percentage (65% - 100%):',
                      ),
                      const SizedBox(height: EcoSpacing.l),
                      Text(
                        '$purity%',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      Text(
                        _getPurityLabel(purity),
                        style: TextStyle(
                          color: _getPurityColor(purity),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Slider(
                        value: purity.toDouble(),
                        min: 65,
                        max: 100,
                        divisions: 35,
                        onChanged:
                            (val) => setDialogState(() => purity = val.toInt()),
                      ),
                      const Divider(height: EcoSpacing.xl),
                      _buildCalculationRow(
                        'Material Recovered',
                        '${(batch.weightKg * (purity / 100)).toStringAsFixed(1)} kg',
                      ),
                      const SizedBox(height: EcoSpacing.s),
                      _buildCalculationRow(
                        'Est. Revenue',
                        '₹${(batch.weightKg * (purity / 100) * 45).toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        _showProcessingAnimation(context);
                        await Future.delayed(const Duration(milliseconds: 1500));
                        opState.processBatch(batch.id, purity);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Batch processed and recovery data updated.',
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _buildCalculationRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showProcessingAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  String _getPurityLabel(int purity) {
    if (purity >= 90) return 'HIGH PURITY';
    if (purity >= 70) return 'GOOD QUALITY';
    if (purity >= 40) return 'CONTAMINATED';
    return 'CRITICAL CONTAMINATION';
  }

  Color _getPurityColor(int purity) {
    if (purity >= 90) return Colors.green;
    if (purity >= 70) return Colors.blue;
    if (purity >= 40) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
