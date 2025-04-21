import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../models/product.dart';

/// نموذج حالة المنتجات
class ProductsState {
  final List<Product> products;
  final bool isLoading;
  final String? error;

  ProductsState({
    required this.products,
    this.isLoading = false,
    this.error,
  });

  /// نسخة أولية من الحالة
  factory ProductsState.initial() {
    return ProductsState(products: []);
  }

  /// نسخة من الحالة مع تحميل
  ProductsState copyWithLoading() {
    return ProductsState(
      products: products,
      isLoading: true,
      error: null,
    );
  }

  /// نسخة من الحالة مع خطأ
  ProductsState copyWithError(String errorMessage) {
    return ProductsState(
      products: products,
      isLoading: false,
      error: errorMessage,
    );
  }

  /// نسخة من الحالة مع منتجات جديدة
  ProductsState copyWithProducts(List<Product> newProducts) {
    return ProductsState(
      products: newProducts,
      isLoading: false,
      error: null,
    );
  }
}

/// مزود خدمة Firestore
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// مزود حالة المنتجات
final productsProvider = StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return ProductsNotifier(firestoreService);
});

/// مزود منتج واحد بناءً على المعرف
final productProvider = Provider.family<Product?, String>((ref, id) {
  final products = ref.watch(productsProvider).products;
  return products.firstWhere((product) => product.id == id, orElse: () => null);
});

/// مزود منتجات حسب الفئة
final productsByCategoryProvider = Provider.family<List<Product>, String>((ref, categoryId) {
  final products = ref.watch(productsProvider).products;
  return products.where((product) => product.categoryId == categoryId).toList();
});

/// مدير حالة المنتجات
class ProductsNotifier extends StateNotifier<ProductsState> {
  final FirestoreService _firestoreService;

  ProductsNotifier(this._firestoreService) : super(ProductsState.initial()) {
    fetchProducts();
  }

  /// جلب المنتجات
  Future<void> fetchProducts() async {
    state = state.copyWithLoading();
    
    try {
      final products = await _firestoreService.getProducts();
      state = state.copyWithProducts(products);
    } catch (e) {
      state = state.copyWithError(e.toString());
    }
  }

  /// البحث عن منتجات
  Future<void> searchProducts(String query) async {
    state = state.copyWithLoading();
    
    try {
      final products = await _firestoreService.searchProducts(query);
      state = state.copyWithProducts(products);
    } catch (e) {
      state = state.copyWithError(e.toString());
    }
  }

  /// جلب منتجات حسب الفئة
  Future<void> fetchProductsByCategory(String categoryId) async {
    state = state.copyWithLoading();
    
    try {
      final products = await _firestoreService.getProductsByCategory(categoryId);
      state = state.copyWithProducts(products);
    } catch (e) {
      state = state.copyWithError(e.toString());
    }
  }
}
