import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';
import 'user_service.dart';

class AuthUserFlowService {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  Future<UserCredential> registerAndCreateProfile({
    required String email,
    required String password,
    required String fullName,
    int age = 0,
    double weightKg = 70.0,
    double heightCm = 170.0,
    String gender = '',
  }) async {
    final credential = await _authService.register(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('User registration failed');
    }

    await _userService.createUserProfile(
      uid: user.uid,
      email: email,
      fullName: fullName,
      age: age,
      weightKg: weightKg,
      heightCm: heightCm,
      gender: gender,
    );

    return credential;
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _authService.login(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithGoogleAndCreateProfile() async {
    final credential = await _authService.signInWithGoogle();
    final user = credential.user;

    if (user == null) {
      throw Exception('Google sign-in failed');
    }

    final existingProfile = await _userService.getUserProfile(user.uid);

    if (existingProfile == null) {
      await _userService.createUserProfile(
        uid: user.uid,
        email: user.email ?? '',
        fullName: user.displayName ??
            user.email?.split('@').first ??
            'RouteFit user',
      );
    }

    return credential;
  }
  
  Future<void> logout() {
    return _authService.logout();
  }

  User? get currentUser => _authService.currentUser;

  Stream<User?> get authStateChanges => _authService.authStateChanges;
}
