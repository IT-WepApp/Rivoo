import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/lib/models/shared_models.dart';
import 'package:shared_libs/lib/services/shared_services.dart';
import 'dart:developer';
// Correctly import userIdProvider from auth_notifier
import 'package:user_app/features/auth/application/auth_notifier.dart';

class ProfileNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final UserService _userService;
  final String? _userId;

  ProfileNotifier(this._userService, this._userId)
      : super(const AsyncLoading()) {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    if (_userId == null) {
      state = const AsyncData(null);
      return;
    }
    state = const AsyncLoading();
    try {
      final user = await _userService.getUser(_userId);
      state = AsyncData(user);
    } catch (e, stackTrace) {
      log('Error fetching profile',
          error: e, stackTrace: stackTrace, name: 'ProfileNotifier');
      state = AsyncError(e, stackTrace);
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    try {
      await _userService.updateUser(updatedUser);
      state = AsyncData(updatedUser);
    } catch (e, stackTrace) {
      log('Error updating profile',
          error: e, stackTrace: stackTrace, name: 'ProfileNotifier');
    }
  }
}

final profileProvider =
    StateNotifierProvider.autoDispose<ProfileNotifier, AsyncValue<UserModel?>>(
        (ref) {
  final userService = ref.watch(userServiceProvider);
  // Use the userIdProvider from auth_notifier
  final userId = ref.watch(userIdProvider);
  return ProfileNotifier(userService, userId);
});
