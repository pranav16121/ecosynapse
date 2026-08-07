import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/collection.dart';
import '../../../core/models/smart_bin.dart';
import '../../../core/state/operational_state.dart';
import '../../../core/widgets/eco_card.dart';
import '../../../core/widgets/eco_button.dart';

class CollectorCollectionsScreen extends StatelessWidget {
  const CollectorCollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final opState = context.watch<OperationalState>();
    final activeRequests = opState.collectionRequests
        .where((r) => r.status != CollectionStatus.completed)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Active Collections')),
      body: activeRequests.isEmpty
          ? const Center(child: Text('No active collection requests.'))
          : ListView.builder(
              padding: const EdgeInsets.all(EcoSpacing.l),
              itemCount: activeRequests.length,
              itemBuilder: (context, index) =>
                  _buildRequestCard(context, activeRequests[index], opState),
            ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    CollectionRequest request,
    OperationalState opState,
  ) {
    final bin = opState.bins.firstWhere(
      (b) => b.id == request.binId,
      orElse:
          () => SmartBin(
            id: request.binId,
            communityId: request.communityId,
            location: 'Unknown Location',
            status: BinStatus.offline,
            fillLevels: {},
          ),
    );
    final Color statusColor = _getStatusColor(request.status);
    final Color priorityColor = _getPriorityColor(request.priority);

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
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                ),
                _buildBadge(request.status.name.toUpperCase(), statusColor),
              ],
            ),
            const SizedBox(height: EcoSpacing.m),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: EcoSpacing.s),
                Expanded(
                  child: Text(
                    bin.location,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: EcoSpacing.s),
                _buildBadge(_getPriorityLabel(request.priority), priorityColor),
              ],
            ),
            const SizedBox(height: EcoSpacing.m),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    context,
                    'Bin ID',
                    bin.id,
                    Icons.qr_code_scanner,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    context,
                    'Fill Level',
                    '${bin.maxFillLevel}%',
                    Icons.bar_chart,
                    color: bin.maxFillLevel >= 85 ? Colors.red : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: EcoSpacing.s),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    context,
                    'Est. Weight',
                    '${(bin.maxFillLevel * 0.4).toStringAsFixed(1)} kg',
                    Icons.fitness_center,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    context,
                    'Last Update',
                    _formatTime(request.createdAt),
                    Icons.access_time,
                  ),
                ),
              ],
            ),
            const Divider(height: EcoSpacing.xl),
            Wrap(
              spacing: EcoSpacing.m,
              runSpacing: EcoSpacing.m,
              children: [
                if (request.status == CollectionStatus.pending)
                  _buildActionButton(
                    context,
                    'Accept Job',
                    () => opState.updateRequestStatus(
                      request.id,
                      CollectionStatus.scheduled,
                    ),
                  ),
                if (request.status == CollectionStatus.scheduled) ...[
                  _buildActionButton(
                    context,
                    'Navigate',
                    () => _showNavigationSimulation(context, bin),
                    type: EcoButtonType.secondary,
                  ),
                  _buildActionButton(
                    context,
                    'Start Collection',
                    () => opState.updateRequestStatus(
                      request.id,
                      CollectionStatus.inProgress,
                    ),
                  ),
                ],
                if (request.status == CollectionStatus.inProgress)
                  _buildActionButton(
                    context,
                    'Complete Collection',
                    () => _showCompleteDialog(context, request, opState),
                  ),
                EcoButton(
                  label: 'Inspect Bin',
                  type: EcoButtonType.text,
                  fullWidth: false,
                  onPressed: () => _showBinInspection(context, bin),
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
    IconData icon, {
    Color? color,
  }) {
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
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    VoidCallback onPressed, {
    EcoButtonType type = EcoButtonType.primary,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 120),
      child: EcoButton(
        label: label,
        onPressed: onPressed,
        type: type,
        fullWidth: false,
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(EcoRadius.small),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _getPriorityLabel(int priority) {
    if (priority >= 5) return 'CRITICAL';
    if (priority >= 4) return 'HIGH';
    return 'NORMAL';
  }

  Color _getPriorityColor(int priority) {
    if (priority >= 5) return Colors.red;
    if (priority >= 4) return Colors.orange;
    return Colors.blue;
  }

  void _showNavigationSimulation(BuildContext context, SmartBin bin) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(EcoRadius.large),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: EcoSpacing.m),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: EcoSpacing.l),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: EcoSpacing.l),
                  child: Row(
                    children: [
                      const Icon(Icons.navigation, color: Colors.blue),
                      const SizedBox(width: EcoSpacing.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Navigating to ${bin.id}',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(bin.location),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: EcoSpacing.xl),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(EcoSpacing.l),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(EcoRadius.medium),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            size: 80,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: EcoSpacing.m),
                          const Text(
                            'Map Simulation Active',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Text('Estimated arrival: 4 mins'),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(EcoSpacing.l),
                  child: EcoButton(
                    label: 'Arrived at Bin',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showCompleteDialog(
    BuildContext context,
    CollectionRequest request,
    OperationalState opState,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Complete Collection'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Confirm that all waste has been collected from this bin and it is now empty.',
                ),
                const SizedBox(height: EcoSpacing.l),
                const LinearProgressIndicator(),
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
                  _showLoadingDialog(context);
                  await Future.delayed(const Duration(milliseconds: 1500));
                  opState.updateRequestStatus(
                    request.id,
                    CollectionStatus.completed,
                  );
                  if (context.mounted) {
                    Navigator.pop(context); // Close loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Collection completed successfully.'),
                      ),
                    );
                  }
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const Center(
            child: CircularProgressIndicator(),
          ),
    );
  }

  String _formatTime(DateTime date) {
    return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  void _showBinInspection(BuildContext context, SmartBin bin) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Inspect ${bin.id}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCompartmentRow(
                  context,
                  'Wet Waste',
                  bin.fillLevels[WasteCategory.wet] ?? 0,
                  Colors.brown,
                ),
                const SizedBox(height: EcoSpacing.m),
                _buildCompartmentRow(
                  context,
                  'Dry Waste',
                  bin.fillLevels[WasteCategory.dry] ?? 0,
                  Colors.blue,
                ),
                const SizedBox(height: EcoSpacing.m),
                _buildCompartmentRow(
                  context,
                  'Recyclable',
                  bin.fillLevels[WasteCategory.recyclable] ?? 0,
                  Colors.teal,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildCompartmentRow(
    BuildContext context,
    String label,
    int level,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('$level%', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: level / 100,
          backgroundColor: color.withOpacity(0.1),
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
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
