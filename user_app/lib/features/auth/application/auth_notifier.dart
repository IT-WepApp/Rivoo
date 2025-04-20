import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

// Notifier for the currently logged-in user state (Firebase User)
class AuthNotifier extends StateNotifier<fb_auth.User?> {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  late final StreamSubscription<fb_auth.User?> _authStateChangesSubscription;

  AuthNotifier() : super(fb_auth.FirebaseAuth.instance.currentUser) {
    _authStateChangesSubscription = _firebaseAuth.authStateChanges().listen((user) {
       state = user;
    });
  }

  String? get currentUserId => state?.uid;

  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
       rethrow;
    }
  }

   Future<void> signUp(String email, String password) async {
     try {
       await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
     } catch (e) {
       rethrow;
     }
   }

  Future<void> signOut() async {
    try {
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
  // If using AuthService, potentially return ref.watch(authServiceProvider).authStateChanges;
  return fb_auth.FirebaseAuth.instance.authStateChanges();
});

// Provider to easily access the current user ID based on the auth state stream
// This is often preferred as it reacts instantly to auth changes
final userIdProvider = Provider<String?>((ref) {
  // Watch the stream provider's async value
  final authState = ref.watch(authStateChangesProvider);
  // Return the uid when data is available, otherwise null
  return authState.valueOrNull?.uid;
});
