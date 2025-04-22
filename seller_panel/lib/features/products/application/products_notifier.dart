import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/lib/services/shared_services.dart';
import 'package:shared_libs/lib/models/shared_models.dart'; // تأكد أن shared_models.dart يصدر product.dart
import 'package:firebase_auth/firebase_auth.dart';

// Provider للحصول على ID البائع الحالي
final currentSellerIdProvider = Provider<String?>((ref) {
  return FirebaseAuth.instance.currentUser?.uid;
});

// Notifier لإدارة المنتجات الخاصة بالبائع
class ProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final ProductService _productService;
  final String? _sellerId;

  ProductsNotifier(this._productService, this._sellerId)
      : super(const AsyncLoading()) {
    if (_sellerId != null) {
      fetchProducts();
    } else {
      state = AsyncError('معرف البائع غير متوفر', StackTrace.current);
    }
  }

  Future<void> fetchProducts() async {
    if (_sellerId == null) return;
    state = const AsyncLoading();
    try {
      final products = await _productService.getProductsBySeller(_sellerId);
      state = AsyncData(products);
    } catch (e, stacktrace) {
      log('خطأ في جلب منتجات البائع',
          error: e, stackTrace: stacktrace, name: 'SellerProductsNotifier');
      state = AsyncError('فشل في جلب المنتجات: $e', stacktrace);
    }
  }

  Future<bool> addProduct(Product product) async {
    if (_sellerId == null) return false;
    final productWithSeller = product.copyWith(sellerId: _sellerId);
    final previousState = state;
    state = const AsyncLoading();
    try {
      await _productService.createProduct(productWithSeller);
      await fetchProducts();
      return true;
    } catch (e, stacktrace) {
      log('خطأ في إضافة المنتج',
          error: e, stackTrace: stacktrace, name: 'SellerProductsNotifier');
      state = AsyncError('فشل في إضافة المنتج: $e', stacktrace);
      if (previousState is AsyncData) state = previousState;
      return false;
    }
  }

  Future<bool> editProduct(Product product) async {
    if (_sellerId == null || product.id.isEmpty) return false;
    if (product.sellerId != _sellerId) {
      state = AsyncError('تم رفض الإذن: لا يمكن تعديل منتج ينتمي إلى بائع آخر',
          StackTrace.current);
      return false;
    }
    final previousState = state;
    state = const AsyncLoading();
    try {
      await _productService.updateProduct(product);
      await fetchProducts();
      return true;
    } catch (e, stacktrace) {
      log('خطأ في تعديل المنتج',
          error: e, stackTrace: stacktrace, name: 'SellerProductsNotifier');
      state = AsyncError('فشل في تعديل المنتج: $e', stacktrace);
      if (previousState is AsyncData) state = previousState;
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    if (_sellerId == null) return false;
    final previousState = state;
    state = const AsyncLoading();
    try {
      await _productService.deleteProduct(productId);
      await fetchProducts();
      return true;
    } catch (e, stacktrace) {
      log('خطأ في حذف المنتج',
          error: e, stackTrace: stacktrace, name: 'SellerProductsNotifier');
      state = AsyncError('فشل في حذف المنتج: $e', stacktrace);
      if (previousState is AsyncData) state = previousState;
      return false;
    }
  }
}

// Provider لإدارة الحالة
final sellerProductsProvider = StateNotifierProvider.autoDispose<
    ProductsNotifier, AsyncValue<List<Product>>>((ref) {
  final productService = ref.watch(productServiceProvider);
  final sellerId = ref.watch(currentSellerIdProvider);

  return ProductsNotifier(productService, sellerId);
});
