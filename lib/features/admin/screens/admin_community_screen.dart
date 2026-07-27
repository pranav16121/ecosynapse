import 'package:flutter/material.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/eco_card.dart';

class AdminCommunityScreen extends StatelessWidget {
  const AdminCommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community Insights')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(EcoSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildParticipationStats(context),
            const SizedBox(height: EcoSpacing.l),
            Text(
              'Leaderboard Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: EcoSpacing.m),
            _buildLeaderboardPreview(context),
            const SizedBox(height: EcoSpacing.l),
            Text(
              'Active Challenges',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: EcoSpacing.m),
            _buildChallengesOverview(context),
            const SizedBox(height: EcoSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipationStats(BuildContext context) {
    return EcoCard(
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: EcoSpacing.m,
            mainAxisSpacing: EcoSpacing.m,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.4,
            children: [
              _buildStatItem(
                context,
                'Engagement',
                '92%',
                Icons.favorite_border,
                Colors.pink,
              ),
              _buildStatItem(
                context,
                'Accuracy',
                '91%',
                Icons.check_circle_outline,
                Colors.green,
              ),
              _buildStatItem(
                context,
                'Growth',
                '+15%',
                Icons.trending_up,
                Colors.blue,
              ),
              _buildStatItem(
                context,
                'Impact Badges',
                '1,240',
                Icons.workspace_premium_outlined,
                Colors.amber,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: EcoSpacing.s),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildLeaderboardPreview(BuildContext context) {
    final leaderboard = MockData.communityLeaderboard.take(3).toList();
    return EcoCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ...leaderboard.map(
            (item) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.1),
                child: Text(
                  '${leaderboard.indexOf(item) + 1}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                item['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('EcoScore: ${item['score']}'),
              trailing: Text(
                '${item['points']} pts',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Detailed leaderboard coming soon!'),
                ),
              );
            },
            child: const Text('View Full Leaderboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesOverview(BuildContext context) {
    final challenges = MockData.challenges;
    return Column(
      children: challenges
          .map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: EcoSpacing.s),
              child: EcoCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c['title'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${c['participants']} participants',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 40,
                      child: CircularProgressIndicator(
                        value: c['progress'],
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceVariant,
                        strokeWidth: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
