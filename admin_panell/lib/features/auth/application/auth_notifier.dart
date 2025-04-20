import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart'; // Import the shared models

class AuthNotifier extends StateNotifier<AdminModel?> { // Use AdminModel from shared_models
  AuthNotifier() : super(null); // Initially, no user is logged in

  Future<void> signIn(String email, String password) async {
    //  Implement your authentication logic here
    // For example, call an authentication service
    // and update the state accordingly.
    // This is a placeholder for actual authentication.
    if (email == 'admin@example.com' && password == 'password') {
      // Replace with actual user data fetching/creation logic
      // Removed the non-existent 'email' parameter
      state = AdminModel(id: '1', name: 'Admin User'); 
    } else {
      state = null; // Authentication failed
    }
  }

  Future<void> signOut() async {
    //  Implement your sign out logic here,
    // such as clearing tokens or session data.
    state = null; // No user is logged in after signing out
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AdminModel?>((ref) => AuthNotifier());
