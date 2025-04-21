import 'package:shared_core/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Need riverpod

// Provider for AuthenticationRepository
final authenticationRepositoryProvider =
    Provider<AuthenticationRepository>((ref) {
  // Get instances of dependencies from other providers
  final authService = ref.watch(authServiceProvider);
  return AuthenticationRepository(authService);
});

class AuthenticationRepository {
  // Make _authService final and receive it in the constructor
  final AuthService _authService;

  AuthenticationRepository(this._authService);

  Future<void> signIn(String email, String password) async {
    await _authService.signIn(email, password);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  // Assuming SecureStorageService holds token info for simplicity
  // You might need more sophisticated token management
  // Future<bool> hasRefreshToken() async {
  //   final token = await _secureStorageService.read('refreshToken');
  //   return token != null && token.isNotEmpty;
  // }

  // Add other methods as needed
}
