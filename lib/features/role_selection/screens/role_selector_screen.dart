import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/models/user.dart';
import '../../../core/state/auth_state.dart';
import '../../../core/widgets/eco_card.dart';

class RoleSelectorScreen extends StatelessWidget {
  const RoleSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(EcoSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: EcoSpacing.xl),
              Text(
                'Choose your experience',
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: EcoSpacing.s),
              Text(
                'Explore EcoSynapse from every part of the waste ecosystem.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: EcoSpacing.xl),
              Expanded(
                child: ListView(
                  children: [
                    _RoleCard(
                      title: 'RESIDENT',
                      description:
                          'Track personal sustainability, EcoScore, EcoPoints and community progress.',
                      icon: Icons.person_outline,
                      onTap: () {
                        context.read<AuthState>().selectRole(UserRole.resident);
                        context.push('/resident');
                      },
                    ),
                    _RoleCard(
                      title: 'COMMUNITY ADMIN',
                      description:
                          'Manage community waste, bins, residents, collections and sustainability performance.',
                      icon: Icons.admin_panel_settings_outlined,
                      onTap: () {
                        context.read<AuthState>().selectRole(UserRole.admin);
                        context.push('/admin');
                      },
                    ),
                    _RoleCard(
                      title: 'COLLECTOR',
                      description:
                          'Handle collection requests, pickup priorities and waste logistics.',
                      icon: Icons.local_shipping_outlined,
                      onTap: () {
                        context.read<AuthState>().selectRole(
                          UserRole.collector,
                        );
                        context.push('/collector');
                      },
                    ),
                    _RoleCard(
                      title: 'RECYCLER',
                      description:
                          'Manage incoming recyclable material, processing and recovery impact.',
                      icon: Icons.recycling_outlined,
                      onTap: () {
                        context.read<AuthState>().selectRole(UserRole.recycler);
                        context.push('/recycler');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: EcoSpacing.m),
      child: EcoCard(
        onTap: onTap,
        padding: const EdgeInsets.all(EcoSpacing.l),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(EcoSpacing.m),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(EcoRadius.medium),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: EcoSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: EcoSpacing.xs),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: EcoSpacing.s),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.outline,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
