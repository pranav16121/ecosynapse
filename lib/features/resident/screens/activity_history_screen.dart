import 'package:flutter/material.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/eco_card.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final filteredHistory = _selectedFilter == 'All'
        ? MockData.activityHistory
        : MockData.activityHistory
              .where((a) => a['type'] == _selectedFilter)
              .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Activity History')),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(EcoSpacing.l),
              itemCount: filteredHistory.length,
              itemBuilder: (context, index) =>
                  _buildHistoryItem(context, filteredHistory[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['All', 'Waste', 'Recycling', 'Points', 'Rewards'];
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: EcoSpacing.l,
          vertical: 10,
        ),
        itemCount: filters.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(filters[index]),
            selected: _selectedFilter == filters[index],
            onSelected: (selected) {
              if (selected) setState(() => _selectedFilter = filters[index]);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: EcoSpacing.m),
      child: EcoCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(EcoSpacing.m),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(_getIcon(item['icon']), size: 24),
            ),
            const SizedBox(width: EcoSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item['date'],
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: EcoSpacing.s),
            Flexible(
              child: Text(
                item['value'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: item['value'].contains('+')
                      ? Colors.green
                      : (item['value'].contains('-') ? Colors.red : null),
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'check_circle':
        return Icons.check_circle;
      case 'delete':
        return Icons.delete;
      case 'trending_up':
        return Icons.trending_up;
      case 'card_giftcard':
        return Icons.card_giftcard;
      default:
        return Icons.info;
    }
  }
}
