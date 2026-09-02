import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/state/auth_state.dart';
import '../../../core/state/resident_state.dart';
import '../../../core/state/navigation_state.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/eco_card.dart';
import '../../../core/widgets/eco_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthState>().currentUser;
    final resState = context.watch<ResidentState>();
    final metrics = MockData.getResidentMetrics();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildHeader(context, user),
            SliverPadding(
              padding: const EdgeInsets.all(EcoSpacing.l),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildEcoScoreHero(context, resState),
                  const SizedBox(height: EcoSpacing.l),
                  _buildEcoPointsCard(context, resState),
                  const SizedBox(height: EcoSpacing.l),
                  _buildWasteSummary(context, metrics),
                  const SizedBox(height: EcoSpacing.l),
                  _buildRecentActivity(context),
                  const SizedBox(height: EcoSpacing.xxl),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, user) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(EcoSpacing.l),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${user?.fullName.split(' ')[0] ?? 'Resident'}',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Greenwood Residency',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Badge(child: Icon(Icons.notifications_outlined)),
              onPressed: () => context.push('/notifications'),
            ),
            const SizedBox(width: EcoSpacing.s),
            const CircleAvatar(radius: 20, child: Icon(Icons.person)),
          ],
        ),
      ),
    );
  }

  Widget _buildEcoScoreHero(BuildContext context, ResidentState state) {
    return EcoCard(
      padding: const EdgeInsets.all(EcoSpacing.l),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EcoScore',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: EcoSpacing.xs),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${state.ecoScore}',
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        Text(
                          ' / 100',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: EcoSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(EcoRadius.small),
                      ),
                      child: const Text(
                        'Excellent',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: EcoSpacing.m),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 80,
                    width: 80,
                    child: CircularProgressIndicator(
                      value: state.ecoScore / 100,
                      strokeWidth: 8,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceVariant,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '+4',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: EcoSpacing.xl),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: EcoSpacing.m,
            runSpacing: EcoSpacing.m,
            children: [
              _buildScoreComponent(context, 'Segregation', '91%'),
              _buildScoreComponent(context, 'Recycling', '78%'),
              _buildScoreComponent(context, 'Reduction', '12%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreComponent(
    BuildContext context,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildEcoPointsCard(BuildContext context, ResidentState state) {
    return EcoCard(
      onTap: () => context.read<NavigationState>().setResidentIndex(2),
      child: Wrap(
        spacing: EcoSpacing.m,
        runSpacing: EcoSpacing.m,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(EcoSpacing.m),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.stars, color: Colors.amber, size: 28),
              ),
              const SizedBox(width: EcoSpacing.m),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${state.ecoPoints} EcoPoints',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Earned 150 pts this week',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          EcoButton(
            label: 'View Rewards',
            onPressed: () => context.read<NavigationState>().setResidentIndex(2),
            fullWidth: false,
            type: EcoButtonType.text,
          ),
        ],
      ),
    );
  }

  Widget _buildWasteSummary(
    BuildContext context,
    Map<String, dynamic> metrics,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your impact this month',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: EcoSpacing.m),
        Wrap(
          spacing: EcoSpacing.m,
          runSpacing: EcoSpacing.m,
          children: [
            _buildWasteCategory(
              context,
              'Wet',
              '${metrics['wetWaste']} kg',
              Icons.opacity,
              Colors.brown,
            ),
            _buildWasteCategory(
              context,
              'Dry',
              '${metrics['dryWaste']} kg',
              Icons.inventory_2,
              Colors.blue,
            ),
            _buildWasteCategory(
              context,
              'Recyclable',
              '${metrics['recyclableWaste']} kg',
              Icons.recycling,
              Colors.teal,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWasteCategory(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      constraints: const BoxConstraints(minWidth: 100),
      child: EcoCard(
        padding: const EdgeInsets.symmetric(
          vertical: EcoSpacing.m,
          horizontal: EcoSpacing.s,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: EcoSpacing.s),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () => context.push('/activity'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: EcoSpacing.s),
        ...MockData.activityHistory
            .take(3)
            .map((activity) => _buildActivityItem(context, activity)),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    Map<String, dynamic> activity,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: EcoSpacing.s),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(_getIcon(activity['icon']), size: 20),
          ),
          const SizedBox(width: EcoSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  activity['date'],
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            activity['value'],
            style: TextStyle(
              color: activity['value'].contains('+')
                  ? Colors.green
                  : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
