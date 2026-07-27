import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          TextButton(
            onPressed: () => resState.markAllNotificationsAsRead(),
            child: const Text('Mark all as read'),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('No notifications'))
          : ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final n = notifications[index];
                return ListTile(
                  tileColor: n['isRead']
                      ? null
                      : Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceVariant,
                    child: Icon(_getIcon(n['title']), size: 20),
                  ),
                  title: Text(
                    n['title'],
                    style: TextStyle(
                      fontWeight: n['isRead']
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n['message'], softWrap: true),
                      const SizedBox(height: 4),
                      Text(
                        n['time'],
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  onTap: () => resState.markNotificationAsRead(n['id']),
                );
              },
            ),
    );
  }

  IconData _getIcon(String title) {
    if (title.contains('Points')) return Icons.stars;
    if (title.contains('Challenge')) return Icons.bolt;
    if (title.contains('Collection')) return Icons.local_shipping;
    if (title.contains('Reward')) return Icons.card_giftcard;
    return Icons.notifications;
  }
}
