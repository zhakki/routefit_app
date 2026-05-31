import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static bool _googleInitialized = false;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> register({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> _initializeGoogleSignIn() async {
    if (_googleInitialized) return;

    final serverClientId = dotenv.env['GOOGLE_SERVER_CLIENT_ID'];

    debugPrint(
      'GOOGLE_SERVER_CLIENT_ID exists: ${serverClientId != null && serverClientId.isNotEmpty}',
    );

    if (serverClientId == null || serverClientId.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-google-server-client-id',
        message: 'GOOGLE_SERVER_CLIENT_ID puudub .env failis',
      );
    }

    await GoogleSignIn.instance.initialize(
      serverClientId: serverClientId,
    );

    _googleInitialized = true;
  }

  Future<UserCredential> signInWithGoogle() async {
    await _initializeGoogleSignIn();

    final googleUser = await GoogleSignIn.instance.authenticate();
    final googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    return _auth.signInWithCredential(credential);
  }

  Future<void> logout() async {
    if (_googleInitialized) {
      await GoogleSignIn.instance.signOut();
    }

    await _auth.signOut();
  }
}