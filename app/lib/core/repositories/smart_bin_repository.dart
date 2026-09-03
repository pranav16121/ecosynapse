import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../models/smart_bin.dart';
import '../services/supabase_service.dart';

/// Repository for smart waste bin operations in `public.bins`.
class SmartBinRepository {
  sb.SupabaseClient? get _client =>
      SupabaseService.instance.isInitialized ? SupabaseService.instance.client : null;

  /// Fetches all smart bins from `public.bins`.
  Future<List<SmartBin>> getBins() async {
    final client = _client;
    if (client == null) return [];

    try {
      final response = await client.from('bins').select().order('id');
      return (response as List<dynamic>)
          .map((json) => SmartBin.fromSupabase(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching smart bins: $e');
      return [];
    }
  }

  /// Fetches a single smart bin by ID.
  Future<SmartBin?> getBinById(String binId) async {
    final client = _client;
    if (client == null) return null;

    try {
      final response =
          await client.from('bins').select().eq('id', binId).maybeSingle();
      if (response == null) return null;
      return SmartBin.fromSupabase(response);
    } catch (e) {
      debugPrint('Error fetching smart bin $binId: $e');
      return null;
    }
  }

  /// Returns a real-time stream of smart bin updates from Supabase.
  Stream<List<SmartBin>> watchBins() {
    final client = _client;
    if (client == null) {
      return Stream.value([]);
    }

    try {
      return client.from('bins').stream(primaryKey: ['id']).map((rows) {
        return rows
            .map((json) => SmartBin.fromSupabase(json))
            .toList();
      });
    } catch (e) {
      debugPrint('Error establishing realtime bin stream: $e');
      return Stream.value([]);
    }
  }
}
