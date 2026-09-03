import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/state/resident_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final resState = context.watch<ResidentState>();
    final notifications = resState.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () => resState.markAllNotificationsAsRead(),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(EcoSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: EcoSpacing.m),
                    Text(
                      'No Notifications Yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: EcoSpacing.s),
                    Text(
                      SupabaseService.instance.isInitialized
                          ? 'Real-time bin telemetry and system alerts will appear here.'
                          : 'No active notifications in demo mode.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: EcoSpacing.s),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final n = notifications[index];
                final bool isRead = n['isRead'] as bool? ?? false;
                final String title = n['title']?.toString() ?? 'Notification';
                final String message = n['message']?.toString() ?? '';
                final String time = n['time']?.toString() ?? 'Just now';

                return ListTile(
                  tileColor: isRead
                      ? null
                      : Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Icon(_getIcon(title), size: 20, color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(
                    title,
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(message, softWrap: true),
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                  onTap: () => resState.markNotificationAsRead(n['id']?.toString() ?? ''),
                );
              },
            ),
    );
  }

  IconData _getIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('point')) return Icons.stars;
    if (lower.contains('challenge')) return Icons.bolt;
    if (lower.contains('collection') || lower.contains('bin') || lower.contains('fill')) return Icons.delete_outline;
    if (lower.contains('reward')) return Icons.card_giftcard;
    if (lower.contains('leak') || lower.contains('contamination')) return Icons.warning_amber_rounded;
    return Icons.notifications;
  }
}
