import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../models/user.dart';
import '../services/supabase_service.dart';

/// Repository responsible for user profile management in `public.users`.
class UserRepository {
  sb.SupabaseClient? get _client =>
      SupabaseService.instance.isInitialized ? SupabaseService.instance.client : null;

  /// Fetches a user profile from `public.users` by ID.
  Future<User?> getUserProfile(String userId, {String? authEmail}) async {
    final client = _client;
    if (client == null) return null;

    try {
      final response = await client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return User.fromSupabase(response, authEmail: authEmail);
    } catch (e) {
      debugPrint('Error fetching user profile for $userId: $e');
      return null;
    }
  }

  /// Safely & idempotently creates or loads a profile in `public.users`.
  /// Preserves existing profiles and points if already present.
  Future<User?> createUserProfile({
    required String id,
    required String fullName,
    required String email,
    required String role,
    String? flatNo,
  }) async {
    final client = _client;
    if (client == null) return null;

    // Check if profile already exists for this Auth UUID
    final existingProfile = await getUserProfile(id, authEmail: email);
    if (existingProfile != null) {
      debugPrint('Profile already exists for $id. Preserving existing profile data.');
      return existingProfile;
    }

    final profileData = {
      'id': id,
      'name': fullName,
      'email': email,
      'user_type': 'Resident', // Public signup is strictly forced to Resident
      'flat_no': flatNo ?? '',
      'eco_points': 0,
      'eco_score': 50,
      'total_disposals': 0,
      'rank': 100,
    };

    try {
      final response = await client
          .from('users')
          .insert(profileData)
          .select()
          .single();

      return User.fromSupabase(response, authEmail: email);
    } catch (e) {
      debugPrint('Error inserting user profile: $e. Checking for existing profile fallback.');
      final fallbackProfile = await getUserProfile(id, authEmail: email);
      if (fallbackProfile != null) return fallbackProfile;
      rethrow;
    }
  }

  /// Queries all user profiles from `public.users` for the Admin Account Management Dashboard.
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final client = _client;
    if (client == null) return [];

    try {
      final response = await client
          .from('users')
          .select()
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((row) => row as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint('Error fetching all user profiles for admin: $e');
      return [];
    }
  }

  /// Safely records the last login timestamp in `public.users` if column exists.
  Future<void> updateLastLogin(String userId) async {
    final client = _client;
    if (client == null) return;

    try {
      await client
          .from('users')
          .update({'last_login_at': DateTime.now().toIso8601String()})
          .eq('id', userId);
    } catch (e) {
      debugPrint('Note: last_login_at update skipped: $e');
    }
  }

  /// Queries the community leaderboard from `public.users`.
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    final client = _client;
    if (client == null) return [];

    try {
      final response = await client
          .from('users')
          .select('name, eco_score, eco_points, rank')
          .order('eco_points', ascending: false)
          .limit(20);

      return (response as List<dynamic>).map((row) {
        final map = row as Map<String, dynamic>;
        return {
          'name': map['name'] ?? 'Anonymous',
          'score': map['eco_score'] ?? 0,
          'points': map['eco_points'] ?? 0,
          'rank': map['rank'] ?? 0,
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching leaderboard: $e');
      return [];
    }
  }
}
