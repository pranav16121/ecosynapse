import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/state/resident_state.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/eco_card.dart';
import '../../../core/widgets/eco_button.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community Hub')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(EcoSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCommunityStats(context),
            const SizedBox(height: EcoSpacing.xl),
            Text('Leaderboard', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: EcoSpacing.m),
            _buildLeaderboard(context),
            const SizedBox(height: EcoSpacing.xl),
            Text(
              'Active Challenges',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: EcoSpacing.m),
            _buildChallenges(context),
            const SizedBox(height: EcoSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityStats(BuildContext context) {
    return EcoCard(
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
                      'Greenwood Residency',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Rank #2 in Bangalore South'),
                  ],
                ),
              ),
              const SizedBox(width: EcoSpacing.m),
              const Icon(Icons.location_city, size: 32, color: Colors.grey),
            ],
          ),
          const Divider(height: EcoSpacing.xl),
          Wrap(
            spacing: EcoSpacing.m,
            runSpacing: EcoSpacing.m,
            alignment: WrapAlignment.spaceBetween,
            children: const [
              _StatItem(label: 'Community EcoScore', value: '86'),
              _StatItem(label: 'Waste Diverted', value: '1.2 Tons'),
              _StatItem(label: 'Active Residents', value: '450'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(BuildContext context) {
    return EcoCard(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: MockData.communityLeaderboard.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final resident = MockData.communityLeaderboard[index];
          final bool isMe = resident['isCurrent'] ?? false;
          return Container(
            color: isMe
                ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                : null,
            padding: const EdgeInsets.symmetric(
              horizontal: EcoSpacing.l,
              vertical: EcoSpacing.m,
            ),
            child: Row(
              children: [
                Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: EcoSpacing.m),
                const CircleAvatar(radius: 16, backgroundColor: Colors.grey),
                const SizedBox(width: EcoSpacing.m),
                Expanded(
                  child: Text(
                    resident['name'],
                    style: TextStyle(
                      fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                Text(
                  '${resident['score']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChallenges(BuildContext context) {
    final resState = context.watch<ResidentState>();
    return Column(
      children: MockData.challenges.map((challenge) {
        final bool isJoined = resState.joinedChallenges.contains(
          challenge['id'],
        );
        return Padding(
          padding: const EdgeInsets.only(bottom: EcoSpacing.m),
          child: EcoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        challenge['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: EcoSpacing.s),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: challenge['status'] == 'Active'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(EcoRadius.small),
                      ),
                      child: Text(
                        challenge['status'],
                        style: TextStyle(
                          color: challenge['status'] == 'Active'
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: EcoSpacing.s),
                Text(
                  '${challenge['participants']} participants',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: EcoSpacing.m),
                LinearProgressIndicator(
                  value: challenge['progress'],
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: EcoSpacing.m),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: EcoSpacing.m,
                  runSpacing: EcoSpacing.s,
                  children: [
                    Text(
                      'Reward: ${challenge['reward']} pts',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    EcoButton(
                      label: isJoined ? 'Joined' : 'Join Challenge',
                      onPressed: isJoined
                          ? () {}
                          : () => resState.joinChallenge(challenge['id']),
                      type: isJoined
                          ? EcoButtonType.secondary
                          : EcoButtonType.primary,
                      fullWidth: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 9),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
