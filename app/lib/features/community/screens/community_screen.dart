import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/repositories/user_repository.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/state/resident_state.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/eco_card.dart';
import '../../../core/widgets/eco_button.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final UserRepository _userRepository = UserRepository();
  List<Map<String, dynamic>> _liveLeaderboard = [];
  bool _isLoadingLeaderboard = false;

  @override
  void initState() {
    super.initState();
    _loadLiveLeaderboard();
  }

  Future<void> _loadLiveLeaderboard() async {
    if (!SupabaseService.instance.isInitialized) return;
    setState(() => _isLoadingLeaderboard = true);
    try {
      final leaderboard = await _userRepository.getLeaderboard();
      if (mounted && leaderboard.isNotEmpty) {
        setState(() {
          _liveLeaderboard = leaderboard;
        });
      }
    } catch (e) {
      debugPrint('Error loading live leaderboard: $e');
    } finally {
      if (mounted) setState(() => _isLoadingLeaderboard = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Hub'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(EcoSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCommunityStats(context),
            const SizedBox(height: EcoSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text('Leaderboard', style: Theme.of(context).textTheme.titleLarge)),
                if (_isLoadingLeaderboard)
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
            const SizedBox(height: EcoSpacing.m),
            _buildLeaderboard(context),
            const SizedBox(height: EcoSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text('Community Challenges', style: Theme.of(context).textTheme.titleLarge)),
                Chip(
                  label: const Text('Simulated', style: TextStyle(fontSize: 9)),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: Colors.orange.withValues(alpha: 0.1),
                ),
              ],
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
                    const Text('Bangalore Society'),
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
    final leaderboardData = _liveLeaderboard.isNotEmpty
        ? _liveLeaderboard
        : MockData.communityLeaderboard;

    return EcoCard(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: leaderboardData.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final resident = leaderboardData[index];
          final bool isMe = resident['isCurrent'] ?? false;
          return Container(
            color: isMe
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
                : null,
            padding: const EdgeInsets.symmetric(
              horizontal: EcoSpacing.l,
              vertical: EcoSpacing.m,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: index < 3 ? Theme.of(context).colorScheme.primary : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: EcoSpacing.s),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: index == 0
                      ? Colors.amber.withValues(alpha: 0.2)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(
                    index == 0 ? Icons.emoji_events : Icons.person,
                    size: 16,
                    color: index == 0 ? Colors.amber : Colors.grey,
                  ),
                ),
                const SizedBox(width: EcoSpacing.m),
                Expanded(
                  child: Text(
                    resident['name'] ?? 'User',
                    style: TextStyle(
                      fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${resident['points'] ?? 0} pts',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Score: ${resident['score'] ?? 0}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
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
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
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
