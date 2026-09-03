import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../models/user.dart';
import '../models/enums.dart';
import '../mock/mock_data.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';
import '../services/supabase_service.dart';

class AuthState extends ChangeNotifier {
  static const String _onboardingKey = 'onboarding_completed';

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  User? _currentUser;
  bool _isOnboardingComplete = false;
  bool _isLoading = false;
  String? _errorMessage;

  AuthState({
    AuthRepository? authRepository,
    UserRepository? userRepository,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _userRepository = userRepository ?? UserRepository() {
    _initSession();
  }

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isOnboardingComplete => _isOnboardingComplete;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isLiveMode => SupabaseService.instance.isInitialized;

  /// Completes onboarding and persists state permanently to SharedPreferences.
  Future<void> completeOnboarding() async {
    _isOnboardingComplete = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
    } catch (e) {
      debugPrint('Error persisting onboarding state to SharedPreferences: $e');
    }
  }

  /// Restores persistent onboarding state and Supabase Auth session on startup.
  Future<void> _initSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isOnboardingComplete = prefs.getBool(_onboardingKey) ?? false;
    } catch (e) {
      debugPrint('Error reading SharedPreferences onboarding flag: $e');
    }

    if (isLiveMode) {
      _isLoading = true;
      notifyListeners();
      try {
        final sbUser = _authRepository.currentUser;
        if (sbUser != null) {
          final profile = await _userRepository.getUserProfile(
            sbUser.id,
            authEmail: sbUser.email,
          );
          _currentUser = profile ??
              User(
                id: sbUser.id,
                fullName: sbUser.userMetadata?['full_name'] ??
                    sbUser.email?.split('@').first ??
                    'User',
                email: sbUser.email ?? '',
                role: UserRole.resident,
                communityId: '1',
              );
        }
      } catch (e) {
        debugPrint('Error restoring Supabase session profile: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Generic login method defaulting to Resident role.
  Future<void> login(String email, String password) async {
    await loginForRole(
      email: email,
      password: password,
      expectedRole: UserRole.resident,
    );
  }

  /// Dedicated Portal Login enforcing strict role verification against public.users.
  Future<void> loginForRole({
    required String email,
    required String password,
    required UserRole expectedRole,
  }) async {
    if (_isLoading && _currentUser != null) {
      return;
    }
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      if (isLiveMode) {
        final response = await _authRepository.signInWithPassword(
          email: email,
          password: password,
        );

        final sbUser = response.user;
        if (sbUser == null) {
          throw 'Authentication failed. Please check your credentials.';
        }

        // Fetch matching profile from public.users
        final profile = await _userRepository.getUserProfile(
          sbUser.id,
          authEmail: sbUser.email,
        );

        final User user = profile ??
            User(
              id: sbUser.id,
              fullName: sbUser.userMetadata?['full_name'] ??
                  sbUser.email?.split('@').first ??
                  'User',
              email: sbUser.email ?? email,
              role: UserRole.resident,
              communityId: '1',
            );

        // Strict role validation
        if (user.role != expectedRole) {
          await _authRepository.signOut();
          _currentUser = null;
          final String roleLabel = user.role.name.toUpperCase();
          throw 'This account is registered as $roleLabel. Please use the $roleLabel portal.';
        }

        _currentUser = user;
        _userRepository.updateLastLogin(sbUser.id);
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
        _currentUser = MockData.getMockUser(expectedRole);
      }
    } catch (e) {
      _errorMessage = _normalizeErrorMessage(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Selects role explicitly in demo/mock mode.
  void selectRole(UserRole role) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: role);
    } else {
      _currentUser = MockData.getMockUser(role);
    }
    notifyListeners();
  }

  /// Clears active session.
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (isLiveMode) {
        await _authRepository.signOut();
      }
      _currentUser = null;
    } catch (e) {
      debugPrint('Error during logout: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Dedicated Resident Signup method.
  Future<void> signUp({
    required String fullName,
    required String email,
    required String communityId,
    String? password,
    String? flatNo,
  }) async {
    if (_isLoading && _currentUser != null) return;
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      if (isLiveMode && password != null && password.isNotEmpty) {
        final response = await _authRepository.signUp(
          email: email,
          password: password,
          data: {'full_name': fullName, 'community_id': communityId},
        );

        final sbUser = response.user;
        if (sbUser != null) {
          final profile = await _userRepository.createUserProfile(
            id: sbUser.id,
            fullName: fullName,
            email: email,
            role: 'Resident',
            flatNo: flatNo,
          );

          _currentUser = profile ??
              User(
                id: sbUser.id,
                fullName: fullName,
                email: email,
                role: UserRole.resident,
                communityId: communityId,
                residentId: flatNo,
              );
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
        _currentUser = User(
          id: 'new_user',
          fullName: fullName,
          email: email,
          role: UserRole.resident,
          communityId: communityId,
          residentId: flatNo,
        );
      }
    } catch (e) {
      _errorMessage = _normalizeErrorMessage(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Triggers password reset email via Supabase Auth.
  Future<void> resetPassword(String email) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      if (isLiveMode) {
        await _authRepository.resetPasswordForEmail(email);
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e) {
      _errorMessage = _normalizeErrorMessage(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Converts technical Supabase/PostgREST exceptions into clean user messages.
  String _normalizeErrorMessage(dynamic error) {
    if (error == null) return 'An unexpected error occurred.';

    String msg = error.toString();
    if (error is sb.AuthException) {
      msg = error.message;
    } else if (error is sb.PostgrestException) {
      msg = error.message;
    }

    final String lower = msg.toLowerCase();

    if (lower.contains('over_email_send_rate_limit') || lower.contains('rate limit')) {
      return 'Email sending is temporarily rate-limited. Please wait before trying again.';
    }
    if (lower.contains('invalid login credentials') || lower.contains('invalid_credentials')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (lower.contains('email not confirmed') || lower.contains('email_not_confirmed')) {
      return 'Please verify your email address before signing in.';
    }
    if (lower.contains('users_pkey') || lower.contains('duplicate key')) {
      return 'An account with this profile already exists. Please sign in.';
    }
    if (lower.contains('user already registered') || lower.contains('already exists')) {
      return 'An account with this email is already registered. Please sign in.';
    }
    if (lower.contains('network') || lower.contains('socketexception') || lower.contains('connection')) {
      return 'Unable to connect to EcoSynapse. Check your internet connection.';
    }

    return msg
        .replaceAll(RegExp(r'^AuthApiException\(.*message:\s*'), '')
        .replaceAll(RegExp(r'^AuthException:\s*'), '')
        .replaceAll(RegExp(r'^PostgrestException:\s*'), '')
        .replaceAll(RegExp(r'\)$'), '')
        .trim();
  }
}
