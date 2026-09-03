import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/state/resident_state.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/eco_card.dart';
import '../../../core/widgets/eco_button.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final resState = context.watch<ResidentState>();

    return Scaffold(
      appBar: AppBar(title: const Text('EcoPoints & Rewards')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(EcoSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPointsSummary(context, resState),
                  const SizedBox(height: EcoSpacing.l),
                  _buildTierProgress(context, resState),
                  const SizedBox(height: EcoSpacing.xl),
                  Text(
                    'Reward Marketplace',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: EcoSpacing.m),
                  _buildCategories(),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: EcoSpacing.l),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final rewardList = resState.liveRewards.isNotEmpty
                      ? resState.liveRewards
                          .map((r) => {
                                'id': r.id,
                                'title': r.title,
                                'points': r.pointsCost,
                                'description': r.description,
                                'icon': r.icon,
                                'category': r.category,
                              })
                          .toList()
                      : MockData.rewards;
                  return _buildRewardCard(
                    context,
                    rewardList[index],
                    resState,
                  );
                },
                childCount: resState.liveRewards.isNotEmpty
                    ? resState.liveRewards.length
                    : MockData.rewards.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: EcoSpacing.xxl)),
        ],
      ),
    );
  }

  Widget _buildPointsSummary(BuildContext context, ResidentState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(EcoSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(EcoRadius.large),
      ),
      child: Column(
        children: [
          const Text('Your Balance', style: TextStyle(color: Colors.white70)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${state.ecoPoints}',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Text('EcoPoints', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildTierProgress(BuildContext context, ResidentState state) {
    return EcoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: EcoSpacing.s,
            children: [
              Text(
                'Silver Tier',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Text('Gold at 5,000 pts', style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: EcoSpacing.s),
          LinearProgressIndicator(
            value: state.ecoPoints / 5000,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: EcoSpacing.s),
          const Text(
            '2,550 points to next tier',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = ['All', 'Food', 'Shopping', 'Transport', 'Eco'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Text(categories[index]),
            selected: index == 0,
            onSelected: (_) {},
          ),
        ),
      ),
    );
  }

  Widget _buildRewardCard(
    BuildContext context,
    Map<String, dynamic> reward,
    ResidentState state,
  ) {
    final bool canAfford = state.ecoPoints >= (reward['points'] as int);

    return Padding(
      padding: const EdgeInsets.only(bottom: EcoSpacing.m),
      child: EcoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(EcoRadius.medium),
                  ),
                  child: Icon(
                    _getRewardIcon(reward['icon']),
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: EcoSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reward['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${reward['points']} EcoPoints',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: EcoSpacing.s),
            Text(
              reward['description'],
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: EcoSpacing.m),
            EcoButton(
              label: 'Redeem',
              onPressed: canAfford
                  ? () => _showRedeemDialog(context, reward, state)
                  : () {},
              type: canAfford ? EcoButtonType.primary : EcoButtonType.secondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showRedeemDialog(
    BuildContext context,
    Map<String, dynamic> reward,
    ResidentState state,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Redeem Reward?'),
        content: Text(
          'Do you want to redeem "${reward['title']}" for ${reward['points']} EcoPoints?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              state.redeemReward(reward['id'], reward['points']);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Redeemed ${reward['title']}!')),
              );
            },
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }

  IconData _getRewardIcon(String icon) {
    switch (icon) {
      case 'coffee':
        return Icons.coffee;
      case 'shopping_basket':
        return Icons.shopping_basket;
      case 'directions_bus':
        return Icons.directions_bus;
      case 'eco':
        return Icons.eco;
      default:
        return Icons.card_giftcard;
    }
  }
}
