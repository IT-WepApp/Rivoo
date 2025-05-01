import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/models/seller_model.dart'; // Import the updated SellerModel
import 'package:shared_libs/services/user_service.dart'; // Assuming UserService exists and returns UserEntity
import 'package:shared_libs/entities/user_entity.dart'; // Import UserEntity
import 'package:shared_libs/enums/user_role.dart'; // Import UserRole
import 'package:firebase_auth/firebase_auth.dart';

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
      // Assume _userService.getUser returns UserEntity?
      final userEntity = await _userService.getUser(_sellerUserId);
      if (userEntity != null && userEntity.role == UserRole.seller) {
        // Convert UserEntity to SellerModel if needed, or directly use if UserService returns SellerModel
        // Assuming direct use or simple conversion for now
        final sellerModel = SellerModel(
          id: userEntity.id,
          name: userEntity.name,
          email: userEntity.email ?? '', // Ensure email is not null
          phone: userEntity.phone,
          address: userEntity.address,
          avatarUrl: userEntity.avatarUrl,
          storeId: userEntity.storeId,
          // storeName might need to be fetched separately or added to UserEntity/SellerModel fetch
          createdAt: userEntity.createdAt, 
          updatedAt: userEntity.updatedAt,
          lastLoginAt: userEntity.lastLoginAt,
          isEmailVerified: userEntity.isEmailVerified,
          isPhoneVerified: userEntity.isPhoneVerified,
        );
        state = AsyncData(sellerModel);
      } else if (userEntity == null) {
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
      // updatedSeller is already a SellerModel which extends UserEntity
      // We might need to convert it back to a generic UserEntity or ensure updateUser accepts SellerModel
      // Assuming updateUser accepts UserEntity
      await _userService.updateUser(updatedSeller); 
      state = AsyncData(updatedSeller);
      return true;
    } catch (e, stacktrace) {
      state = AsyncError('فشل في تحديث الملف الشخصي: $e', stacktrace);
      if (previousState is AsyncData) state = previousState;
      return false;
    }
  }
}

// Assuming userServiceProvider exists and provides UserService
final sellerProfileProvider = StateNotifierProvider.autoDispose<ProfileNotifier,
    AsyncValue<SellerModel?>>((ref) {
  final userService = ref.watch(userServiceProvider);
  final sellerUserId = ref.watch(currentSellerIdProvider);
  return ProfileNotifier(userService, sellerUserId);
});

