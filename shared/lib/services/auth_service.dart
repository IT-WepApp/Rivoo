import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:shared_services/src/services/secure_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod

// Provider definition
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(); // Assuming secureStorageServiceProvider exists
});

class AuthService {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;

  AuthService();

  Stream<fb_auth.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  fb_auth.User? get currentUser => _firebaseAuth.currentUser;

  Future<fb_auth.User?> signIn(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return credential.user;
  }

  Future<fb_auth.User?> signUp(String email, String password) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    return credential.user;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}

// Define secureStorageServiceProvider if it doesn't exist
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});
