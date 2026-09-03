import 'enums.dart';

/// Represents a system or community notification for a user
class EcoNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;

  EcoNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  EcoNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    NotificationType? type,
  }) {
    return EcoNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }

  factory EcoNotification.fromJson(Map<String, dynamic> json) {
    return EcoNotification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: NotificationType.values.firstWhere((e) => e.name == json['type']),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  /// Converts a Supabase database row from `public.system_events` into an [EcoNotification] model
  factory EcoNotification.fromSupabase(Map<String, dynamic> json) {
    final rawType = (json['type'] ?? 'system').toString().toLowerCase();
    NotificationType nType = NotificationType.system;
    if (rawType.contains('point')) {
      nType = NotificationType.points;
    } else if (rawType.contains('collection') || rawType.contains('bin') || rawType.contains('fill')) {
      nType = NotificationType.collection;
    } else if (rawType.contains('challenge')) {
      nType = NotificationType.challenge;
    } else if (rawType.contains('reward')) {
      nType = NotificationType.reward;
    }

    return EcoNotification(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      title: json['type']?.toString() ?? json['title']?.toString() ?? 'System Event',
      message: json['message']?.toString() ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      type: nType,
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'isRead': isRead,
    };
  }
}
