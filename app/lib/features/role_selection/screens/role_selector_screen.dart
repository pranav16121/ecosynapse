import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/dimens.dart';
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
              Row(
                children: [
                  Icon(
                    Icons.eco,
                    size: 36,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: EcoSpacing.s),
                  Text(
                    'EcoSynapse',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: EcoSpacing.s),
              Text(
                'Select your portal to continue.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: EcoSpacing.xl),
              Expanded(
                child: ListView(
                  children: [
                    _RoleCard(
                      title: 'RESIDENT PORTAL',
                      description:
                          'Track personal sustainability, EcoScore, EcoPoints, and community progress.',
                      icon: Icons.person_outline,
                      badgeLabel: 'Public Access',
                      badgeColor: Colors.green,
                      onTap: () => context.push('/resident-login'),
                    ),
                    _RoleCard(
                      title: 'ADMIN PORTAL',
                      description:
                          'Manage community waste, smart bins, residents, logistics, and system performance.',
                      icon: Icons.admin_panel_settings_outlined,
                      badgeLabel: 'Restricted Access',
                      badgeColor: Colors.purple,
                      onTap: () => context.push('/admin-login'),
                    ),
                    _RoleCard(
                      title: 'COLLECTOR PORTAL',
                      description:
                          'Handle waste collection requests, pickup routes, and smart bin logistics.',
                      icon: Icons.local_shipping_outlined,
                      badgeLabel: 'Operational',
                      badgeColor: Colors.orange,
                      onTap: () => context.push('/collector-login'),
                    ),
                    _RoleCard(
                      title: 'RECYCLER PORTAL',
                      description:
                          'Track incoming recyclable batches, material purity, and processing recovery.',
                      icon: Icons.recycling_outlined,
                      badgeLabel: 'Processing',
                      badgeColor: Colors.teal,
                      onTap: () => context.push('/recycler-login'),
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
  final String badgeLabel;
  final Color badgeColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.badgeLabel,
    required this.badgeColor,
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
                color: badgeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(EcoRadius.medium),
              ),
              child: Icon(
                icon,
                color: badgeColor,
                size: 28,
              ),
            ),
            const SizedBox(width: EcoSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: EcoSpacing.xs,
                    runSpacing: 2,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(EcoRadius.small),
                        ),
                        child: Text(
                          badgeLabel,
                          style: TextStyle(
                            color: badgeColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
