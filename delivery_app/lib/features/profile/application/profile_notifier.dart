import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart'; // يحتوي على DeliveryPersonModel
import 'package:shared_services/shared_services.dart'; // يحتوي على DeliveryPersonService

// مزود وهمي مؤقت لـ ID المندوب (عدّله لاحقاً حسب المصدر الحقيقي مثل Firebase Auth)
final currentDeliveryPersonIdProvider = Provider<String?>((ref) {
  return "123"; // ID مؤقت للتجربة
});

// مزود خدمة المندوب (من shared_services)
final deliveryPersonServiceProvider = Provider<DeliveryPersonService>((ref) {
  return DeliveryPersonService();
});

// Notifier لإدارة بيانات بروفايل المندوب
class ProfileNotifier extends StateNotifier<AsyncValue<DeliveryPersonModel?>> {
  final String? _deliveryPersonId;

  ProfileNotifier(this._deliveryPersonId) : super(const AsyncLoading()) {
    if (_deliveryPersonId != null) {
      fetchProfile();
    } else {
      state = AsyncError('User ID not available', StackTrace.current);
    }
  }

  Future<void> fetchProfile() async {
    if (_deliveryPersonId == null) return;
    state = const AsyncLoading();
    try {
      // بيانات مؤقتة، عدّلها لاحقًا لجلب حقيقي من API أو Database
      final deliveryPerson = DeliveryPersonModel(
        id: _deliveryPersonId,
        name: 'Test Deliverer',
        email: 'deliverer@test.com',
        currentLat: null,
        currentLng: null,
        isAvailable: true,
        vehicleDetails: null,
      );
      state = AsyncData(deliveryPerson);
    } catch (e) {
      state = AsyncError('Failed to fetch profile: $e', StackTrace.current);
    }
  }

  Future<bool> updateProfile(DeliveryPersonModel updatedDeliveryPerson) async {
    if (_deliveryPersonId == null || state is! AsyncData) return false;
    final previousState = state;
    state = const AsyncLoading();
    try {
      // عدّل هنا إذا عندك API لتحديث البيانات
      // await _deliveryPersonService.updateDeliveryPersonProfile(updatedDeliveryPerson);

      state = AsyncData(updatedDeliveryPerson); // تحديث تفاؤلي
      return true;
    } catch (e, stacktrace) {
      state = AsyncError('Failed to update profile: $e', stacktrace);
      if (previousState is AsyncData) state = previousState;
      return false;
    }
  }
}

// مزود الـ Notifier للبروفايل
final profileProvider =
    StateNotifierProvider.autoDispose<ProfileNotifier, AsyncValue<DeliveryPersonModel?>>((ref) {
  final deliveryPersonId = ref.watch(currentDeliveryPersonIdProvider);
  return ProfileNotifier(deliveryPersonId);
});
