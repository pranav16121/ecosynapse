import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../models/notification.dart';
import '../services/supabase_service.dart';

/// Repository for system event logs and notifications in `public.system_events`.
class SystemEventRepository {
  sb.SupabaseClient? get _client =>
      SupabaseService.instance.isInitialized ? SupabaseService.instance.client : null;

  /// Fetches system events from `public.system_events`.
  Future<List<EcoNotification>> getSystemEvents() async {
    final client = _client;
    if (client == null) return [];

    try {
      final response =
          await client.from('system_events').select().order('timestamp', ascending: false);
      return (response as List<dynamic>)
          .map((json) => EcoNotification.fromSupabase(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching system events: $e');
      return [];
    }
  }

  /// Returns a real-time stream of system events.
  Stream<List<EcoNotification>> watchSystemEvents() {
    final client = _client;
    if (client == null) {
      return Stream.value([]);
    }

    try {
      return client
          .from('system_events')
          .stream(primaryKey: ['id'])
          .order('timestamp', ascending: false)
          .map((rows) {
            return rows
                .map((json) => EcoNotification.fromSupabase(json))
                .toList();
          });
    } catch (e) {
      debugPrint('Error establishing realtime system events stream: $e');
      return Stream.value([]);
    }
  }
}
