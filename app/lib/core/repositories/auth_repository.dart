import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

/// Repository wrapping Supabase Auth operations.
class AuthRepository {
  SupabaseClient? get _client =>
      SupabaseService.instance.isInitialized ? SupabaseService.instance.client : null;

  /// Returns the current authenticated Supabase user, or null if not logged in.
  User? get currentUser => _client?.auth.currentUser;

  /// Returns the current active session, if any.
  Session? get currentSession => _client?.auth.currentSession;

  /// Stream of Supabase Auth state changes.
  Stream<AuthState>? get onAuthStateChange => _client?.auth.onAuthStateChange;

  /// Authenticates a user with email and password via Supabase Auth.
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase is not initialized.');
    }

    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    }
  }

  /// Registers a new user with email and password via Supabase Auth.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase is not initialized.');
    }

    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: data,
      );
      return response;
    } catch (e) {
      debugPrint('Error signing up: $e');
      rethrow;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    final client = _client;
    if (client == null) return;

    try {
      await client.auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  /// Sends a password reset email via Supabase Auth.
  Future<void> resetPasswordForEmail(String email) async {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase is not initialized.');
    }

    try {
      await client.auth.resetPasswordForEmail(email);
    } catch (e) {
      debugPrint('Error sending password reset: $e');
      rethrow;
    }
  }
}
