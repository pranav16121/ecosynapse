import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Central service responsible for initializing and exposing the Supabase client.
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  bool _isInitialized = false;

  /// Returns true if Supabase SDK was successfully initialized with credentials.
  bool get isInitialized => _isInitialized;

  /// Returns the global [SupabaseClient] instance if initialized.
  SupabaseClient get client {
    if (!_isInitialized) {
      throw StateError(
        'SupabaseService has not been initialized. Ensure initialize() is called at startup with valid SUPABASE_URL and SUPABASE_ANON_KEY environment variables.',
      );
    }
    return Supabase.instance.client;
  }

  /// Initializes the Supabase Flutter SDK using compile-time environment variables.
  Future<void> initialize() async {
    const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      debugPrint(
        '⚠️ Supabase credentials missing from environment (--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...). Falling back to uninitialized state.',
      );
      _isInitialized = false;
      return;
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _isInitialized = true;
      debugPrint('✅ Supabase initialized successfully for URL: $supabaseUrl');
    } catch (e) {
      _isInitialized = false;
      debugPrint('❌ Failed to initialize Supabase: $e');
    }
  }
}
