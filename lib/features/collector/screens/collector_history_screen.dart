import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/collection.dart';
import '../../../core/state/operational_state.dart';
import '../../../core/widgets/eco_card.dart';

class CollectorHistoryScreen extends StatelessWidget {
  const CollectorHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final opState = context.watch<OperationalState>();
    final completedRequests = opState.collectionRequests
        .where((r) => r.status == CollectionStatus.completed)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Collection History')),
      body: completedRequests.isEmpty
          ? const Center(child: Text('No completed collections yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(EcoSpacing.l),
              itemCount: completedRequests.length,
              itemBuilder: (context, index) =>
                  _buildHistoryCard(context, completedRequests[index], opState),
            ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    CollectionRequest request,
    OperationalState opState,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: EcoSpacing.m),
      child: EcoCard(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(EcoSpacing.m),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.green, size: 20),
                ),
                const SizedBox(width: EcoSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bin ID: ${request.binId}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Completed: ${_formatDate(request.completedAt ?? DateTime.now())}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Text(
                  'COMPLETED',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const Divider(height: EcoSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('Weight', '38.2 kg'),
                _buildStatItem('Duration', '14 min'),
                _buildStatItem('Rating', '5.0 ⭐'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
