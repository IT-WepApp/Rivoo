import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart'; // Added import
import 'package:shared_services/shared_services.dart'; // Added import

// Updated to use AsyncValue
class StoreManagementNotifier extends StateNotifier<AsyncValue<List<StoreModel>>> {
  final StoreService _storeService;

  StoreManagementNotifier(this._storeService) : super(const AsyncLoading()) {
   fetchStores();
  }

  Future<void> fetchStores() async {
    state = const AsyncLoading();
    try {
      final stores = await _storeService.getAllStores(); // Ensure this method exists in StoreService
      state = AsyncData(stores);
    } catch (e, stacktrace) {
      state = AsyncError('Failed to load stores: $e', stacktrace);
    }
  }

  // Add methods for store approval/rejection if needed
  Future<bool> approveStore(String storeId) async {
     final previousState = state;
     // Optimistically update UI while waiting for backend confirmation (optional)
     // _optimisticUpdateStatus(storeId, 'approved'); 
     state = const AsyncLoading(); // Or just show loading
     try {
       await _storeService.approveStore(storeId); // Assuming this method exists
       await fetchStores(); // Refetch list to confirm update
       return true;
     } catch (e, stacktrace) {
        state = AsyncError('Failed to approve store: $e', stacktrace);
        if (previousState is AsyncData) state = previousState; // Revert on error
        return false;
     }
  }

   Future<bool> rejectStore(String storeId) async {
     final previousState = state;
     state = const AsyncLoading();
     try {
       await _storeService.rejectStore(storeId); // Assuming this method exists
       await fetchStores(); // Refetch list
       return true;
     } catch (e, stacktrace) {
        state = AsyncError('Failed to reject store: $e', stacktrace);
         if (previousState is AsyncData) state = previousState; // Revert on error
        return false;
     }
  }

   Future<bool> deleteStore(String storeId) async {
      final previousState = state;
      state = const AsyncLoading();
     try {
       await _storeService.deleteStore(storeId); // Assuming this method exists
       await fetchStores(); // Refetch list
       return true;
     } catch (e, stacktrace) {
       state = AsyncError('Failed to delete store: $e', stacktrace);
       if (previousState is AsyncData) state = previousState; // Revert on error
       return false;
     }
  }

  // Helper for optimistic updates (optional)
  // void _optimisticUpdateStatus(String storeId, String newStatus) {
  //   if (state is AsyncData<List<StoreModel>>) {
  //     final currentStores = (state as AsyncData<List<StoreModel>>).value;
  //     final updatedStores = currentStores.map((store) {
  //       if (store.id == storeId) {
  //         return store.copyWith(status: newStatus); // Assuming StoreModel has copyWith & status
  //       }
  //       return store;
  //     }).toList();
  //     state = AsyncData(updatedStores);
  //   }
  // }
}

// Provider for StoreService (defined in shared_services)
// We assume storeServiceProvider is imported from shared_services

// Provider for the Notifier
final storeManagementProvider = StateNotifierProvider<StoreManagementNotifier, AsyncValue<List<StoreModel>>>((ref) {
  // Read the StoreService provider (imported from shared_services)
  final storeService = ref.read(storeServiceProvider);
  return StoreManagementNotifier(storeService);
});
