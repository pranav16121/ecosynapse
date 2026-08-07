import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/dimens.dart';
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
            TextButton(
              onPressed: () {
                context.read<AuthState>().logout();
                context.go('/login');
              },
              child: const Text('Log Out', style: TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: EcoSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user, ResidentState state) {
    return Column(
      children: [
        const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
        const SizedBox(height: EcoSpacing.m),
        Text(
          'Pranav Powell',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'Greenwood Residency | ID: RES-2026-042',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: EcoSpacing.l),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: EcoSpacing.xl,
          runSpacing: EcoSpacing.m,
          children: [
            _buildStatItem(context, 'EcoScore', '${state.ecoScore}'),
            _buildStatItem(context, 'EcoPoints', '${state.ecoPoints}'),
            _buildStatItem(context, 'Rank', '#12'),
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
      const SnackBar(content: Text('Feature coming soon in Stage 2!')),
    );
  }
}
