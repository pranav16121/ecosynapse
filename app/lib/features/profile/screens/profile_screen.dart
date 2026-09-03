import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/models/user.dart';
import '../../../core/state/auth_state.dart';
import '../../../core/state/resident_state.dart';
import '../../../core/widgets/eco_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthState>().currentUser;
    final resState = context.watch<ResidentState>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(EcoSpacing.l),
        child: Column(
          children: [
            _buildProfileHeader(context, user, resState),
            const SizedBox(height: EcoSpacing.xl),
            _buildAchievements(context),
            const SizedBox(height: EcoSpacing.xl),
            _buildMenu(context),
            const SizedBox(height: EcoSpacing.xl),
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: EcoSpacing.m,
              runSpacing: EcoSpacing.s,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    await context.read<AuthState>().logout();
                    if (context.mounted) {
                      context.go('/auth-portal');
                    }
                  },
                  icon: const Icon(Icons.swap_horiz, size: 18),
                  label: const Text('Switch Portal'),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await context.read<AuthState>().logout();
                    if (context.mounted) {
                      context.go('/auth-portal');
                    }
                  },
                  icon: const Icon(Icons.logout, size: 18, color: Colors.red),
                  label: const Text('Log Out', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
            const SizedBox(height: EcoSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, User? user, ResidentState state) {
    final String name = user?.fullName ?? 'Resident';
    final String email = user?.email ?? '';
    final String roleLabel = (user?.role.name ?? 'resident').toUpperCase();
    final String residentId = user?.residentId != null && user!.residentId!.isNotEmpty
        ? ' | ID: ${user.residentId}'
        : '';

    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(Icons.person, size: 40, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: EcoSpacing.m),
        Text(
          name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          '$email $residentId',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: EcoSpacing.s),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(EcoRadius.small),
          ),
          child: Text(
            'ROLE: $roleLabel',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(height: EcoSpacing.l),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: EcoSpacing.xl,
          runSpacing: EcoSpacing.m,
          children: [
            _buildStatItem(context, 'EcoScore', '${state.ecoScore}'),
            _buildStatItem(context, 'EcoPoints', '${state.ecoPoints}'),
            _buildStatItem(context, 'Community Rank', '#12'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildAchievements(BuildContext context) {
    final badges = [
      {'name': 'Segregation Pro', 'icon': Icons.verified_user},
      {'name': '7 Day Streak', 'icon': Icons.bolt},
      {'name': 'Waste Reducer', 'icon': Icons.trending_down},
      {'name': 'Eco Contributor', 'icon': Icons.favorite},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Achievements', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: EcoSpacing.m),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: badges.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: EcoSpacing.m),
              child: EcoCard(
                padding: const EdgeInsets.all(EcoSpacing.m),
                child: Column(
                  children: [
                    Icon(
                      badges[index]['icon'] as IconData,
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      badges[index]['name'] as String,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenu(BuildContext context) {
    return EcoCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildMenuItem(Icons.person_outline, 'Personal Information', () {
            _showComingSoon(context);
          }),
          const Divider(height: 1),
          _buildMenuItem(Icons.business_outlined, 'My Community', () {
            _showComingSoon(context);
          }),
          const Divider(height: 1),
          _buildMenuItem(
            Icons.history,
            'Activity History',
            () => context.push('/activity'),
          ),
          const Divider(height: 1),
          _buildMenuItem(Icons.settings_outlined, 'App Settings', () {
            _showComingSoon(context);
          }),
          const Divider(height: 1),
          _buildMenuItem(Icons.help_outline, 'Help & Support', () {
            _showComingSoon(context);
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feature coming soon!')),
    );
  }
}
