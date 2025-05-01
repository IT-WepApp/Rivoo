import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/models/delivery_person_model.dart'; // Import the updated DeliveryPersonModel
import 'package:shared_libs/services/auth_service.dart'; // Import unified AuthService
import 'package:shared_libs/entities/user_entity.dart'; // Import UserEntity
import 'package:shared_libs/enums/user_role.dart'; // Import UserRole
// Assuming AppLogger or similar is used within AuthService for logging/crash reporting

/// StateNotifier for Delivery App Authentication
class AuthNotifier extends StateNotifier<AsyncValue<DeliveryPersonModel?>> {
  final AuthService _authService;
  // TODO: Inject DeliveryPersonService if needed to fetch full model details

  AuthNotifier(this._authService) : super(const AsyncLoading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = const AsyncLoading();
    try {
      final userEntity = await _authService.getCurrentUser();
      if (userEntity != null && userEntity.role == UserRole.driver) {
        // Convert UserEntity to DeliveryPersonModel
        // This assumes DeliveryPersonModel has a constructor or factory from UserEntity
        // Or, if AuthService can return the specific subtype, use that.
        // For now, creating a basic model from the entity.
        final deliveryModel = DeliveryPersonModel(
          id: userEntity.id,
          name: userEntity.name,
          email: userEntity.email,
          phone: userEntity.phone,
          address: userEntity.address,
          avatarUrl: userEntity.avatarUrl,
          isAvailable: true, // Placeholder - fetch actual availability
          vehicleDetails: null, // Placeholder - fetch actual details
          currentLat: null, // Placeholder
          currentLng: null, // Placeholder
          createdAt: userEntity.createdAt,
          updatedAt: userEntity.updatedAt,
          lastLoginAt: userEntity.lastLoginAt,
          isEmailVerified: userEntity.isEmailVerified,
          isPhoneVerified: userEntity.isPhoneVerified,
        );
        state = AsyncData(deliveryModel);
      } else {
        state = const AsyncData(null); // No driver logged in
      }
    } catch (e, stacktrace) {
      // Error logged within AuthService
      state = AsyncError('فشل التحقق من حالة المصادقة: $e', stacktrace);
    }
  }

  Future<bool> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      final userEntity = await _authService.signInWithEmailPassword(email: email, password: password);
      if (userEntity.role == UserRole.driver) {
         final deliveryModel = DeliveryPersonModel(
          id: userEntity.id,
          name: userEntity.name,
          email: userEntity.email,
          phone: userEntity.phone,
          address: userEntity.address,
          avatarUrl: userEntity.avatarUrl,
          isAvailable: true, // Placeholder
          vehicleDetails: null, // Placeholder
          currentLat: null, // Placeholder
          currentLng: null, // Placeholder
          createdAt: userEntity.createdAt,
          updatedAt: userEntity.updatedAt,
          lastLoginAt: userEntity.lastLoginAt,
          isEmailVerified: userEntity.isEmailVerified,
          isPhoneVerified: userEntity.isPhoneVerified,
        );
        state = AsyncData(deliveryModel);
        return true;
      } else {
        // Log out user if role is incorrect for this app
        await _authService.signOut();
        state = AsyncError('الوصول مرفوض: المستخدم ليس مندوب توصيل.', StackTrace.current);
        return false;
      }
    } catch (e, stacktrace) {
      // Error logged within AuthService
      state = AsyncError('فشل تسجيل الدخول: $e', stacktrace);
      return false;
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await _authService.signOut();
      state = const AsyncData(null); // Clear state on sign out
    } catch (e, stacktrace) {
      // Error logged within AuthService
      state = AsyncError('فشل تسجيل الخروج: $e', stacktrace);
    }
  }
}

// Provider for the AuthNotifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<DeliveryPersonModel?>>((ref) {
  final authService = ref.watch(authServiceProvider); // Use unified AuthService provider
  return AuthNotifier(authService);
});

