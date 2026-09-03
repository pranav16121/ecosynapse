import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/state/operational_state.dart';
import '../../../core/widgets/eco_card.dart';

class BinsScreen extends StatelessWidget {
  const BinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final opState = context.watch<OperationalState>();
    final List<Map<String, dynamic>> displayedBins = opState.bins.isNotEmpty
        ? opState.bins
            .map((b) => {
                  'id': b.id,
                  'location': b.location,
                  'fillLevel': b.maxFillLevel,
                  'status': b.status.name,
                  'categories': ['Wet', 'Dry', 'Recyclable'],
                })
            .toList()
        : MockData.bins;

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Bins')),
      body: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 48, color: Colors.grey),
                  Text(
                    'Community Bin Map',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    '(Mockup only)',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(EcoSpacing.l),
              itemCount: displayedBins.length,
              itemBuilder: (context, index) =>
                  _buildBinCard(context, displayedBins[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBinCard(BuildContext context, Map<String, dynamic> bin) {
    final int fillLevel = bin['fillLevel'];
    final Color statusColor = fillLevel > 80
        ? Colors.red
        : (fillLevel > 50 ? Colors.orange : Colors.green);

    return Padding(
      padding: const EdgeInsets.only(bottom: EcoSpacing.m),
      child: EcoCard(
        onTap: () => context.push('/bin-detail', extra: bin),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 60,
                  width: 60,
                  child: CircularProgressIndicator(
                    value: fillLevel / 100,
                    strokeWidth: 6,
                    color: statusColor,
                    backgroundColor: statusColor.withOpacity(0.1),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  '$fillLevel%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(width: EcoSpacing.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bin['id'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    bin['location'],
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: EcoSpacing.xs),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: (bin['categories'] as List<String>)
                        .map((cat) => _buildCategoryChip(cat))
                        .toList(),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  bin['status'],
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: const TextStyle(fontSize: 8)),
    );
  }
}
