import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/collection.dart';
import '../../../core/state/operational_state.dart';
import '../../../core/widgets/eco_card.dart';

class AdminLogisticsScreen extends StatelessWidget {
  const AdminLogisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final opState = context.watch<OperationalState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Logistics & Collections')),
      body: ListView.builder(
        padding: const EdgeInsets.all(EcoSpacing.l),
        itemCount: opState.collectionRequests.length,
        itemBuilder: (context, index) =>
            _buildRequestItem(context, opState.collectionRequests[index]),
      ),
    );
  }

  Widget _buildRequestItem(BuildContext context, CollectionRequest request) {
    final Color statusColor = _getStatusColor(request.status);

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
                  request.id,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(EcoRadius.small),
                  ),
                  child: Text(
                    request.status.name.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: EcoSpacing.s),
            Row(
              children: [
                const Icon(Icons.delete_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Bin: ${request.binId}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: EcoSpacing.xs),
            Row(
              children: [
                const Icon(Icons.priority_high, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Text(
                  'Priority: ${request.priority}/5',
                  style: const TextStyle(fontSize: 12),
                ),
                const Spacer(),
                Text(
                  'Created: ${_formatDate(request.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (request.scheduledAt != null) ...[
              const Divider(height: EcoSpacing.l),
              Row(
                children: [
                  const Icon(Icons.event, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    'Scheduled: ${_formatDate(request.scheduledAt!)}',
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  Color _getStatusColor(CollectionStatus status) {
    switch (status) {
      case CollectionStatus.pending:
        return Colors.orange;
      case CollectionStatus.scheduled:
        return Colors.blue;
      case CollectionStatus.inProgress:
        return Colors.teal;
      case CollectionStatus.completed:
        return Colors.green;
      case CollectionStatus.cancelled:
        return Colors.red;
    }
  }
}
