import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../models/collection.dart';
import '../models/enums.dart';
import '../services/supabase_service.dart';

/// Repository responsible for waste collection requests in `public.collection_requests`.
class CollectionRequestRepository {
  sb.SupabaseClient? get _client =>
      SupabaseService.instance.isInitialized ? SupabaseService.instance.client : null;

  /// Fetches all active and historical collection requests from Supabase.
  Future<List<CollectionRequest>> getCollectionRequests() async {
    final client = _client;
    if (client == null) return [];

    try {
      final response = await client
          .from('collection_requests')
          .select()
          .order('created_at', ascending: false);

      return (response as List<dynamic>).map((row) {
        return _mapRowToCollectionRequest(row as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching collection requests: $e');
      return [];
    }
  }

  /// Creates a new persistent collection request if no active request exists for the bin.
  Future<CollectionRequest?> createCollectionRequest({
    required String binId,
    required String requestedBy,
    required String communityId,
    int priority = 5,
  }) async {
    final client = _client;
    if (client == null) return null;

    try {
      // Check for active (pending/scheduled/inProgress) request for this bin
      final activeExisting = await client
          .from('collection_requests')
          .select()
          .eq('bin_id', binId)
          .neq('status', 'completed')
          .neq('status', 'cancelled')
          .maybeSingle();

      if (activeExisting != null) {
        debugPrint('Active collection request already exists for bin $binId.');
        return _mapRowToCollectionRequest(activeExisting);
      }

      final requestData = {
        'bin_id': binId,
        'requested_by': requestedBy,
        'status': 'pending',
        'priority': priority,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await client
          .from('collection_requests')
          .insert(requestData)
          .select()
          .single();

      return _mapRowToCollectionRequest(response);
    } catch (e) {
      if (e.toString().toLowerCase().contains('unique') ||
          e.toString().toLowerCase().contains('duplicate')) {
        debugPrint('PostgreSQL partial unique index prevented duplicate request for bin $binId.');
        final activeExisting = await client
            .from('collection_requests')
            .select()
            .eq('bin_id', binId)
            .neq('status', 'completed')
            .neq('status', 'cancelled')
            .maybeSingle();

        if (activeExisting != null) {
          return _mapRowToCollectionRequest(activeExisting);
        }
      }
      debugPrint('Error creating collection request for bin $binId: $e');
      rethrow;
    }
  }

  /// Updates status of a collection request in Supabase.
  Future<void> updateRequestStatus({
    required String requestId,
    required CollectionStatus status,
    String? completedBy,
  }) async {
    final client = _client;
    if (client == null) return;

    try {
      final updates = <String, dynamic>{
        'status': status.name,
      };

      if (status == CollectionStatus.completed) {
        updates['completed_at'] = DateTime.now().toIso8601String();
        if (completedBy != null && completedBy.isNotEmpty) {
          updates['completed_by'] = completedBy;
        }
      } else if (status == CollectionStatus.scheduled) {
        updates['scheduled_at'] = DateTime.now().toIso8601String();
      }

      await client
          .from('collection_requests')
          .update(updates)
          .eq('id', requestId);
    } catch (e) {
      debugPrint('Error updating collection request $requestId: $e');
      rethrow;
    }
  }

  /// Returns a real-time stream of collection requests from Supabase.
  Stream<List<CollectionRequest>> watchCollectionRequests() {
    final client = _client;
    if (client == null) {
      return Stream.value([]);
    }

    try {
      return client
          .from('collection_requests')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .map((rows) {
            return rows.map((row) => _mapRowToCollectionRequest(row)).toList();
          });
    } catch (e) {
      debugPrint('Error in collection requests realtime stream: $e');
      return Stream.value([]);
    }
  }

  CollectionRequest _mapRowToCollectionRequest(Map<String, dynamic> row) {
    CollectionStatus status;
    final String rawStatus = (row['status'] ?? 'pending').toString().toLowerCase();
    switch (rawStatus) {
      case 'scheduled':
        status = CollectionStatus.scheduled;
        break;
      case 'inprogress':
      case 'in_progress':
        status = CollectionStatus.inProgress;
        break;
      case 'completed':
        status = CollectionStatus.completed;
        break;
      case 'cancelled':
        status = CollectionStatus.cancelled;
        break;
      default:
        status = CollectionStatus.pending;
    }

    return CollectionRequest(
      id: row['id']?.toString() ?? '',
      binId: row['bin_id']?.toString() ?? row['binId']?.toString() ?? '',
      communityId: row['community_id']?.toString() ?? '1',
      status: status,
      priority: (row['priority'] as num? ?? 5).toInt(),
      createdAt: row['created_at'] != null
          ? DateTime.tryParse(row['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      scheduledAt: row['scheduled_at'] != null
          ? DateTime.tryParse(row['scheduled_at'].toString())
          : null,
      completedAt: row['completed_at'] != null
          ? DateTime.tryParse(row['completed_at'].toString())
          : null,
    );
  }
}
