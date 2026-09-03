import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/state/auth_state.dart';
import '../../../core/widgets/eco_card.dart';

class RecyclerProfileScreen extends StatelessWidget {
  const RecyclerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthState>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Facility Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(EcoSpacing.l),
        child: Column(
          children: [
            _buildProfileHeader(context, user),
            const SizedBox(height: EcoSpacing.xl),
            _buildFacilityStats(context),
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
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          child: Icon(Icons.factory_outlined, size: 50),
        ),
        const SizedBox(height: EcoSpacing.m),
        Text(
          'EcoCycle Bangalore',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const Text(
          'Facility ID: REC-001',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: EcoSpacing.l),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatItem(label: 'Capacity', value: '12 T'),
            SizedBox(width: EcoSpacing.xxl),
            _StatItem(label: 'Throughput', value: '8.4 T'),
            SizedBox(width: EcoSpacing.xxl),
            _StatItem(label: 'Recovery', value: '92%'),
          ],
        ),
      ],
    );
  }

  Widget _buildFacilityStats(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Materials Processed', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: EcoSpacing.m),
        Wrap(
          spacing: EcoSpacing.s,
          runSpacing: EcoSpacing.s,
          children: [
            _buildMaterialChip('Plastic', Colors.blue),
            _buildMaterialChip('Glass', Colors.teal),
            _buildMaterialChip('Paper', Colors.orange),
            _buildMaterialChip('Metal', Colors.red),
          ],
        ),
        const SizedBox(height: EcoSpacing.xl),
        const EcoCard(
          child: Column(
            children: [
              _CapabilityRow(label: 'Processing Speed', value: 'High'),
              Divider(),
              _CapabilityRow(label: 'Organic Composting', value: 'Medium'),
              Divider(),
              _CapabilityRow(label: 'Hazardous Disposal', value: 'Supported'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialChip(String label, Color color) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return EcoCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildMenuItem(Icons.business_outlined, 'Facility Information', () {}),
          const Divider(height: 1),
          _buildMenuItem(Icons.verified_outlined, 'Certifications', () {}),
          const Divider(height: 1),
          _buildMenuItem(Icons.history, 'Recovery Reports', () {}),
          const Divider(height: 1),
          _buildMenuItem(Icons.help_outline, 'Partner Support', () {}),
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

class _CapabilityRow extends StatelessWidget {
  final String label;
  final String value;
  const _CapabilityRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    );
  }
}
