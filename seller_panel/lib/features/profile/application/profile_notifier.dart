import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/models/models.dart';
import 'package:shared_libs/services/services.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ضروري لـ currentSellerIdProvider

final currentSellerIdProvider = Provider<String?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  return user?.uid;
});

class ProfileNotifier extends StateNotifier<AsyncValue<SellerModel?>> {
  final UserService _userService;
  final String? _sellerUserId;

  ProfileNotifier(this._userService, this._sellerUserId)
      : super(const AsyncLoading()) {
    if (_sellerUserId != null) {
      fetchProfile();
    } else {
      state = AsyncError('معرف المستخدم غير متوفر', StackTrace.current);
    }
  }

  Future<void> fetchProfile() async {
    if (_sellerUserId == null) return;
    state = const AsyncLoading();
    try {
      final userModel = await _userService.getUser(_sellerUserId);
      if (userModel != null && userModel.role == 'seller') {
        final sellerModel = SellerModel(
          id: userModel.id,
          name: userModel.name,
          email: userModel.email,
          storeId: userModel.storeId ?? '',
        );
        state = AsyncData(sellerModel);
      } else if (userModel == null) {
        state = AsyncError('لم يتم العثور على ملف البائع', StackTrace.current);
      } else {
        state = AsyncError('المستخدم ليس بائعاً', StackTrace.current);
      }
    } catch (e, stacktrace) {
      state = AsyncError('فشل في جلب الملف الشخصي: $e', stacktrace);
    }
  }

  Future<bool> updateProfile(SellerModel updatedSeller) async {
    if (_sellerUserId == null || state is! AsyncData) return false;
    final previousState = state;
    state = const AsyncLoading();
    try {
      final userToUpdate = UserModel(
        id: updatedSeller.id,
        name: updatedSeller.name,
        email: updatedSeller.email,
        role: 'seller',
        storeId: updatedSeller.storeId,
      );
      await _userService.updateUser(userToUpdate);
      state = AsyncData(updatedSeller);
      return true;
    } catch (e, stacktrace) {
      state = AsyncError('فشل في تحديث الملف الشخصي: $e', stacktrace);
      if (previousState is AsyncData) state = previousState;
      return false;
    }
  }
}

final sellerProfileProvider = StateNotifierProvider.autoDispose<ProfileNotifier,
    AsyncValue<SellerModel?>>((ref) {
  final userService = ref.watch(userServiceProvider);
  final sellerUserId = ref.watch(currentSellerIdProvider);
  return ProfileNotifier(userService, sellerUserId);
});
