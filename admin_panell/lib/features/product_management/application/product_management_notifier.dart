import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/lib/models/shared_models.dart'; // Added import for ProductModel
import 'package:shared_libs/lib/services/shared_services.dart'; // Added import for ProductService

// Updated to use AsyncValue
class ProductManagementNotifier
    extends StateNotifier<AsyncValue<List<Product>>> {
  // Changed ProductModel to Product
  final ProductService _productService;

  // Use Product from shared_models
  ProductManagementNotifier(this._productService)
      : super(const AsyncLoading()) {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    state = const AsyncLoading();
    try {
      // Use Product from shared_models
      final products = await _productService
          .getAllProducts(); // Ensure this method returns List<Product>
      state = AsyncData(products);
    } catch (e, stacktrace) {
      state = AsyncError('Failed to load products: $e', stacktrace);
    }
  }

  Future<void> approveProduct(String productId) async {
    // Keep previous state for optimistic update or error recovery
    // final previousState = state; // Uncomment if needed for error recovery
    state = const AsyncLoading();
    try {
      await _productService
          .approveProduct(productId); // Ensure this method exists
      // Refetch to get the updated list
      await fetchProducts();
      // Example of optimistic update (if Product has copyWith and status):
      // if (previousState is AsyncData<List<Product>>) {
      //   final updatedList = previousState.value.map((prod) {
      //     if (prod.id == productId) {
      //       return prod.copyWith(status: 'approved');
      //     }
      //     return prod;
      //   }).toList();
      //   state = AsyncData(updatedList);
      // } else {
      //    await fetchProducts(); // Fetch if previous state wasn't data
      // }
    } catch (e, stacktrace) {
      state = AsyncError('Failed to approve product: $e', stacktrace);
      // Optionally revert state if optimistic update was used
      // if (previousState != null) state = previousState;
    }
  }

  Future<void> rejectProduct(String productId) async {
    // final previousState = state; // Uncomment if needed for error recovery
    state = const AsyncLoading();
    try {
      await _productService
          .rejectProduct(productId); // Ensure this method exists
      await fetchProducts(); // Refetch to get updated list
    } catch (e, stacktrace) {
      state = AsyncError('Failed to reject product: $e', stacktrace);
      // Optionally revert state
      // if (previousState != null) state = previousState;
    }
  }

  // Admin might not edit products directly, but maybe view details?
  // If editing is needed, implement similarly to approve/reject
  // Future<void> editProduct(Product product) async { ... }
}

// Provider for ProductService (already defined in shared_services)
// We assume productServiceProvider from shared_services is imported and used.

// Provider for the Notifier
final productManagementProvider =
    StateNotifierProvider<ProductManagementNotifier, AsyncValue<List<Product>>>(
        (ref) {
  // Changed ProductModel to Product
  // Read the ProductService provider (assuming it's available from shared_services)
  final productService = ref.read(productServiceProvider);
  return ProductManagementNotifier(productService);
});
