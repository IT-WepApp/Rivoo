import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../shared_libs/lib/models/models.dart'; // Use main export
import '../../../../../../shared_libs/lib/services/services.dart'; // Use main export

// Updated to use AsyncValue
class UserManagementNotifier
    extends StateNotifier<AsyncValue<List<UserModel>>> {
  final UserService _userService;

  UserManagementNotifier(this._userService) : super(const AsyncLoading()) {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    state = const AsyncLoading();
    try {
      final users = await _userService.getAllUsers(); // Make sure this exists
      state = AsyncData(users);
    } catch (e, stacktrace) {
      state = AsyncError('Failed to load users: $e', stacktrace);
    }
  }

  // Admins typically might not *add* users directly (users register themselves)
  // but they might edit roles or delete users.

  // Future<void> addUser(UserModel user) async { ... }

  Future<bool> editUser(UserModel user) async {
    // Return bool for success indication
    final previousState = state;
    state = const AsyncLoading();
    try {
      await _userService.updateUser(user); // Assuming updateUser exists
      await fetchUsers(); // Refetch to update the UI
      return true;
    } catch (e, stacktrace) {
      state = AsyncError('Failed to edit user: $e', stacktrace);
      state = previousState; // Revert on error
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    // Return bool for success indication
    final previousState = state;
    state = const AsyncLoading();
    try {
      await _userService.deleteUser(userId);
      await fetchUsers(); // Refetch
      return true;
    } catch (e, stacktrace) {
      state = AsyncError('Failed to delete user: $e', stacktrace);
      state = previousState;
      return false;
    }
  }
}

// Assuming UserService provider exists
final userServiceProvider = Provider<UserService>((ref) {
  return UserService(); // Or get from another provider
});

final userManagementProvider =
    StateNotifierProvider<UserManagementNotifier, AsyncValue<List<UserModel>>>(
        (ref) {
  final userService = ref.read(userServiceProvider);
  return UserManagementNotifier(userService);
});
