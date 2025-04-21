import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:user_app/core/state/connectivity_provider.dart';
import 'package:user_app/features/products/domain/product_model.dart';

part 'products_provider.freezed.dart';
part 'products_provider.g.dart';

/// حالة قائمة المنتجات باستخدام Freezed
@freezed
class ProductsState with _$ProductsState {
  /// حالة التحميل الأولي
  const factory ProductsState.initial() = _Initial;

  /// حالة التحميل
  const factory ProductsState.loading() = _Loading;

  /// حالة النجاح مع قائمة المنتجات
  const factory ProductsState.loaded(List<ProductModel> products) = _Loaded;

  /// حالة الخطأ
  const factory ProductsState.error(String message) = _Error;
}

/// مزود حالة المنتجات باستخدام Riverpod المُولّد
@riverpod
class ProductsNotifier extends _$ProductsNotifier {
  late final FirebaseFirestore _firestore;

  @override
  ProductsState build() {
    _firestore = FirebaseFirestore.instance;
    // تحميل المنتجات عند بناء المزود
    _loadProducts();
    return const ProductsState.initial();
  }

  /// تحميل قائمة المنتجات من Firestore
  Future<void> _loadProducts() async {
    state = const ProductsState.loading();

    try {
      // التحقق من الاتصال بالإنترنت قبل تحميل البيانات
      final isConnected = await ref.read(isNetworkConnectedProvider.future);

      if (!isConnected) {
        state = const ProductsState.error("لا يوجد اتصال بالإنترنت");
        return;
      }

      final snapshot = await _firestore.collection('products').get();
      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data()..['id'] = doc.id))
          .toList();

      state = ProductsState.loaded(products);
    } catch (e) {
      state = ProductsState.error(e.toString());
    }
  }

  /// إعادة تحميل المنتجات
  Future<void> refreshProducts() async {
    await _loadProducts();
  }

  /// البحث عن منتجات
  Future<void> searchProducts(String query) async {
    state = const ProductsState.loading();

    try {
      final snapshot = await _firestore
          .collection('products')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data()..['id'] = doc.id))
          .toList();

      state = ProductsState.loaded(products);
    } catch (e) {
      state = ProductsState.error(e.toString());
    }
  }

  /// تصفية المنتجات حسب الفئة
  Future<void> filterByCategory(String category) async {
    state = const ProductsState.loading();

    try {
      final snapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .get();

      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data()..['id'] = doc.id))
          .toList();

      state = ProductsState.loaded(products);
    } catch (e) {
      state = ProductsState.error(e.toString());
    }
  }
}

/// مزود لمنتج محدد حسب المعرف
@riverpod
Future<ProductModel?> product(ProductRef ref, String productId) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .get();

    if (!doc.exists) return null;

    return ProductModel.fromJson(doc.data()!..['id'] = doc.id);
  } catch (e) {
    return null;
  }
}
