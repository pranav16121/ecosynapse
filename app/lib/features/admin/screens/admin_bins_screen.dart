import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/smart_bin.dart';
import '../../../core/state/operational_state.dart';
import '../../../core/widgets/eco_card.dart';
import '../../../core/widgets/eco_button.dart';

class AdminBinsScreen extends StatelessWidget {
  const AdminBinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final opState = context.watch<OperationalState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Community Smart Bins')),
      body: ListView.builder(
        padding: const EdgeInsets.all(EcoSpacing.l),
        itemCount: opState.bins.length,
        itemBuilder: (context, index) =>
            _buildBinItem(context, opState.bins[index], opState),
      ),
    );
  }

  Widget _buildBinItem(
    BuildContext context,
    SmartBin bin,
    OperationalState opState,
  ) {
    final bool isRequested = opState.hasActiveCollectionRequest(bin.id);
    final bool isOffline = bin.status == BinStatus.offline;
    final Color statusColor = _getStatusColor(bin.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: EcoSpacing.m),
      child: EcoCard(
        onTap: () => context.push('/bin-detail', extra: bin),
        child: Column(
          children: [
            Row(
              children: [
                _buildFillIndicator(bin.maxFillLevel),
                const SizedBox(width: EcoSpacing.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bin.id,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        bin.location,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: EcoSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(EcoRadius.small),
                        ),
                        child: Text(
                          _getStatusLabel(bin.status),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (bin.maxFillLevel >= 80)
                  const Icon(Icons.error_outline, color: Colors.red),
              ],
            ),
            const Divider(height: EcoSpacing.xl),
            _buildCompartmentLevels(context, bin),
            const SizedBox(height: EcoSpacing.l),
            if (isRequested)
              EcoButton(
                label: 'Collection Requested',
                onPressed: () {},
                type: EcoButtonType.secondary,
              )
            else if (isOffline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(EcoSpacing.m),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(EcoRadius.medium),
                ),
                child: const Text(
                  'Bin Offline — Collection Request Unavailable',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              )
            else
              EcoButton(
                label: 'Request Immediate Collection',
                onPressed: () {
                  opState.requestCollection(bin.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Collection requested for ${bin.id}'),
                    ),
                  );
                },
                type: EcoButtonType.primary,
              ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(BinStatus status) {
    if (status == BinStatus.collectionSoon) return 'COLLECTION SOON';
    return status.name.toUpperCase();
  }

  Widget _buildFillIndicator(int level) {
    final Color color =
        level >= 90 ? Colors.red : (level >= 80 ? Colors.orange : Colors.green);
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 50,
          width: 50,
          child: CircularProgressIndicator(
            value: level / 100,
            strokeWidth: 5,
            color: color,
            backgroundColor: color.withValues(alpha: 0.1),
            strokeCap: StrokeCap.round,
          ),
        ),
        Text(
          '$level%',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCompartmentLevels(BuildContext context, SmartBin bin) {
    return Wrap(
      spacing: EcoSpacing.s,
      runSpacing: EcoSpacing.s,
      alignment: WrapAlignment.spaceBetween,
      children: [
        _buildLevelMini(
          context,
          'Wet',
          bin.fillLevels[WasteCategory.wet] ?? 0,
          Colors.brown,
        ),
        _buildLevelMini(
          context,
          'Dry',
          bin.fillLevels[WasteCategory.dry] ?? 0,
          Colors.blue,
        ),
        _buildLevelMini(
          context,
          'Recyclable',
          bin.fillLevels[WasteCategory.recyclable] ?? 0,
          Colors.teal,
        ),
      ],
    );
  }

  Widget _buildLevelMini(
    BuildContext context,
    String label,
    int value,
    Color color,
  ) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Text(
            '$value%',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BinStatus status) {
    switch (status) {
      case BinStatus.online:
        return Colors.green;
      case BinStatus.full:
        return Colors.red;
      case BinStatus.collectionSoon:
        return Colors.orange;
      case BinStatus.maintenance:
        return Colors.blue;
      case BinStatus.offline:
        return Colors.grey;
    }
  }
}
