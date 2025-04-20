import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Notifier for the currently logged-in user state (Firebase User)
class AuthNotifier extends StateNotifier<fb_auth.User?> {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  late final StreamSubscription<fb_auth.User?> _authStateChangesSubscription;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthNotifier() : super(fb_auth.FirebaseAuth.instance.currentUser) {
    _authStateChangesSubscription = _firebaseAuth.authStateChanges().listen((user) {
       state = user;
    });
  }

  String? get currentUserId => state?.uid;
  
  bool get isEmailVerified => state?.emailVerified ?? false;

  Future<void> signIn(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      // Store refresh token securely
      if (userCredential.user != null) {
        final idTokenResult = await userCredential.user!.getIdTokenResult();
        await _secureStorage.write(
          key: 'refresh_token',
          value: idTokenResult.token,
        );
        
        // Clear password from memory after successful login
        password = '';
      }
    } catch (e) {
       rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      // Send email verification
      if (userCredential.user != null) {
        await userCredential.user!.sendEmailVerification();
        
        // Store refresh token securely
        final idTokenResult = await userCredential.user!.getIdTokenResult();
        await _secureStorage.write(
          key: 'refresh_token',
          value: idTokenResult.token,
        );
        
        // Clear password from memory after successful signup
        password = '';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> checkEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.reload();
        state = _firebaseAuth.currentUser;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      // Clear secure storage
      await _secureStorage.delete(key: 'refresh_token');
      
      // Sign out from Firebase
      await _firebaseAuth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _authStateChangesSubscription.cancel();
    super.dispose();
  }
}

// Provider for the AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, fb_auth.User?>((ref) {
  return AuthNotifier();
});

// Provider that exposes the auth state stream directly
final authStateChangesProvider = StreamProvider<fb_auth.User?>((ref) {
  return fb_auth.FirebaseAuth.instance.authStateChanges();
});

// Provider to easily access the current user ID based on the auth state stream
final userIdProvider = Provider<String?>((ref) {
  // Watch the stream provider's async value
  final authState = ref.watch(authStateChangesProvider);
  // Return the uid when data is available, otherwise null
  return authState.valueOrNull?.uid;
});

// Provider to check if email is verified
final isEmailVerifiedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.valueOrNull?.emailVerified ?? false;
});
