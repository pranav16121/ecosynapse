import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../models/reward.dart';
import '../services/supabase_service.dart';

/// Repository for reward catalog operations in `public.rewards`.
class RewardRepository {
  sb.SupabaseClient? get _client =>
      SupabaseService.instance.isInitialized ? SupabaseService.instance.client : null;

  /// Fetches all reward catalog items from `public.rewards`.
  Future<List<Reward>> getRewards() async {
    final client = _client;
    if (client == null) return [];

    try {
      final response = await client.from('rewards').select().order('id');
      return (response as List<dynamic>)
          .map((json) => Reward.fromSupabase(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching rewards: $e');
      return [];
    }
  }
}
