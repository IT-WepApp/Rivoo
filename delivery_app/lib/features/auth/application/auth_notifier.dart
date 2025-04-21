import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import the correct model name (DeliveryPersonModel) via the main export
import 'package:shared_models/shared_models.dart';
import 'package:shared_services/shared_services.dart';
import 'dart:developer'; // For logging

// StateNotifier for Delivery App Authentication - Use the correct model type
class AuthNotifier extends StateNotifier<DeliveryPersonModel?> {
  final AuthService _authService;
  // TODO: Inject DeliveryPersonService to fetch full model after login
  // final DeliveryPersonService _deliveryPersonService;

  // Use the correct model type in the constructor
  AuthNotifier(this._authService /*, this._deliveryPersonService*/)
      : super(null);

  Future<bool> signIn(String email, String password) async {
    try {
      final firebaseUser = await _authService.signIn(email, password);

      if (firebaseUser != null) {
        // TODO: Fetch the full DeliveryPersonModel using firebaseUser.uid
        // Example: final deliveryModel = await _deliveryPersonService.getDeliveryPerson(firebaseUser.uid);
        log('Login successful, Firebase UID: ${firebaseUser.uid}');

        // Create an instance of the correct model: DeliveryPersonModel
        state = DeliveryPersonModel(
          id: firebaseUser.uid,
          name: 'Delivery User (Fetched)', // Placeholder - fetch actual name
          email: firebaseUser.email, // Use email from Firebase user (nullable)
          currentLat: 0.0, // Placeholder - fetch actual location
          currentLng: 0.0, // Placeholder - fetch actual location
          isAvailable: true, // Placeholder - fetch actual availability
          vehicleDetails:
              'Placeholder Vehicle', // Placeholder - fetch actual details
        );
        return true;
      } else {
        state = null;
        return false;
      }
    } catch (e) {
      log('Sign in error: $e');
      state = null;
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = null; // Clear state on sign out
  }
}

// Provider for the AuthNotifier - Use the correct model type
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, DeliveryPersonModel?>((ref) {
  final authService = ref.read(authServiceProvider);
  // TODO: Read DeliveryPersonService provider when implemented
  // final deliveryPersonService = ref.read(deliveryPersonServiceProvider);
  return AuthNotifier(authService /*, deliveryPersonService*/);
});
