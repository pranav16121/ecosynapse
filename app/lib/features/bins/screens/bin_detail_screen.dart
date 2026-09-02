import 'package:flutter/material.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/widgets/eco_card.dart';

class BinDetailScreen extends StatelessWidget {
  final Map<String, dynamic> bin;
  const BinDetailScreen({super.key, required this.bin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(bin['id'])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(EcoSpacing.l),
        child: Column(
          children: [
            EcoCard(
              padding: const EdgeInsets.all(EcoSpacing.xl),
              child: Column(
                children: [
                  Text(
                    '${bin['fillLevel']}% Full',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: EcoSpacing.m),
                  LinearProgressIndicator(
                    value: bin['fillLevel'] / 100,
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                    color: _getStatusColor(bin['fillLevel']),
                  ),
                  const SizedBox(height: EcoSpacing.l),
                  Text(
                    bin['location'],
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Status: ${bin['status']}',
                    style: TextStyle(
                      color: _getStatusColor(bin['fillLevel']),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: EcoSpacing.l),
            _buildCompartments(context),
            const SizedBox(height: EcoSpacing.l),
            _buildRecentDeposits(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCompartments(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Compartments', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: EcoSpacing.m),
        Wrap(
          spacing: EcoSpacing.m,
          runSpacing: EcoSpacing.m,
          children: [
            _buildCompartmentItem(context, 'Wet', 30, Colors.brown),
            _buildCompartmentItem(context, 'Dry', 60, Colors.blue),
            _buildCompartmentItem(context, 'Recyclable', 45, Colors.teal),
          ],
        ),
      ],
    );
  }

  Widget _buildCompartmentItem(
    BuildContext context,
    String label,
    int value,
    Color color,
  ) {
    return Container(
      constraints: const BoxConstraints(minWidth: 100),
      child: EcoCard(
        child: Column(
          children: [
            Text(
              '$value%',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentDeposits(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Deposits', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: EcoSpacing.m),
        EcoCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildDepositItem(
                'Aarav Sharma',
                'Recyclable',
                '1.2 kg',
                '10:30 AM',
              ),
              const Divider(height: 1),
              _buildDepositItem('Priya Iyer', 'Wet', '0.8 kg', '09:45 AM'),
              const Divider(height: 1),
              _buildDepositItem('Vikram Singh', 'Dry', '2.5 kg', '08:15 AM'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDepositItem(
    String name,
    String type,
    String amount,
    String time,
  ) {
    return Padding(
      padding: const EdgeInsets.all(EcoSpacing.m),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                type,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                time,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(int level) {
    if (level > 80) return Colors.red;
    if (level > 50) return Colors.orange;
    return Colors.green;
  }
}
