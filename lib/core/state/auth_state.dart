import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/enums.dart';
import '../mock/mock_data.dart';

class AuthState extends ChangeNotifier {
  User? _currentUser;
  bool _isOnboardingComplete = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isOnboardingComplete => _isOnboardingComplete;

  void completeOnboarding() {
    _isOnboardingComplete = true;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    // Mock login delay
    await Future.delayed(const Duration(seconds: 1));

    // For prototype, any valid email format works.
    // Defaulting to resident if not specified by user input in a real case.
    _currentUser = MockData.getMockUser(UserRole.resident);
    notifyListeners();
  }

  void selectRole(UserRole role) {
    _currentUser = MockData.getMockUser(role);
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String communityId,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = User(
      id: 'new_user',
      fullName: fullName,
      email: email,
      role: UserRole.resident,
      communityId: communityId,
    );
    notifyListeners();
  }
}
