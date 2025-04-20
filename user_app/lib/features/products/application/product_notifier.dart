import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart'; // Use main export
import 'package:shared_services/shared_services.dart'; // Use main export
import 'dart:developer';

// Notifier for product-related states
class ProductNotifier extends StateNotifier<AsyncValue<List<Product>>> { // Use Product model
  final ProductService _productService; // Use ProductService
  final String? _storeId; // Optional store ID for filtering

  ProductNotifier(this._productService, [this._storeId]) : super(const AsyncLoading()) {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    state = const AsyncLoading();
    try {
      List<Product> products; // Use Product model
      if (_storeId != null) {
        products = await _productService.getProductsByStoreId(_storeId); 
      } else {
        products = await _productService.getAllProducts();
      }
      // mounted check removed
      state = AsyncData(products);
      
    } catch (e, stacktrace) {
      log('Error fetching products', error: e, stackTrace: stacktrace, name: 'ProductNotifier');
      // mounted check removed
      state = AsyncError(e, stacktrace);
       
    }
  }
}

// Provider for ALL products
final allProductsProvider = StateNotifierProvider.autoDispose<ProductNotifier, AsyncValue<List<Product>>>((ref) {
  final productService = ref.watch(productServiceProvider); // Use productServiceProvider
  return ProductNotifier(productService); 
});

// Provider family for products filtered by store ID
final productsByStoreProvider = StateNotifierProvider.autoDispose.family<
    ProductNotifier,
    AsyncValue<List<Product>>,
    String // Store ID
    >((ref, storeId) {
  final productService = ref.watch(productServiceProvider); // Use productServiceProvider
  return ProductNotifier(productService, storeId);
});
