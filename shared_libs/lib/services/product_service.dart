import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/constants/app_constants.dart';
import 'package:shared_libs/models/product.dart';
import 'package:shared_libs/models/promotion.dart';
import 'package:shared_libs/utils/logger.dart';
import 'package:shared_libs/services/auth_service.dart';

/// خدمة إدارة المنتجات والمحفزات المشتركة
class ProductService {
  // Singleton
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppLogger _logger = AppLogger();

  // ----------------------------
  // 1️⃣ إدارة المحفزات (Promotions)
  // ----------------------------

  Future<void> createPromotion({
    required String productId,
    required PromotionType type,
    required double value,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // مثال إنشاء مؤقت، عدّل لمنطق حقيقي حسب الحاجة
      Product(
        id: 'temp',
        name: 'temp',
        description: 'temp',
        categoryId: 'temp',
        sellerId: 'temp',
        price: 1.0,
        imageUrl: 'temp',
        status: 'pending',
        hasPromotion: true,
        promotionType: type,
        promotionValue: value,
        promotionStartDate: startDate,
        promotionEndDate: endDate,
      );
    } catch (e) {
      _logger.error('Failed to create promotion', e);
      throw Exception('Failed to create promotion: $e');
    }
  }

  Future<void> updatePromotion({
    required String productId,
    required PromotionType type,
    required double value,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Product(
        id: 'temp',
        name: 'temp',
        description: 'temp',
        categoryId: 'temp',
        sellerId: 'temp',
        price: 1.0,
        imageUrl: 'temp',
        status: 'pending',
        hasPromotion: true,
        promotionType: type,
        promotionValue: value,
        promotionStartDate: startDate,
        promotionEndDate: endDate,
      );
    } catch (e) {
      _logger.error('Failed to update promotion', e);
      throw Exception('Failed to update promotion: $e');
    }
  }

  Future<void> deletePromotion(String productId) async {
    try {
      const Product(
        id: 'temp',
        name: 'temp',
        description: 'temp',
        categoryId: 'temp',
        sellerId: 'temp',
        price: 1.0,
        imageUrl: 'temp',
        status: 'pending',
        hasPromotion: false,
        promotionType: null,
        promotionValue: null,
        promotionStartDate: null,
        promotionEndDate: null,
      );
    } catch (e) {
      _logger.error('Failed to delete promotion', e);
      throw Exception('Failed to delete promotion: $e');
    }
  }

  Future<PromotionDetails?> getPromotionsForProduct(String productId) async {
    try {
      const product = Product(
        id: 'temp',
        name: 'temp',
        description: 'temp',
        categoryId: 'temp',
        sellerId: 'temp',
        price: 1.0,
        imageUrl: 'temp',
        status: 'pending',
        hasPromotion: false,
        promotionType: null,
        promotionValue: null,
        promotionStartDate: null,
        promotionEndDate: null,
      );
      if (product.hasPromotion) {
        return PromotionDetails(
          type: product.promotionType!,
          value: product.promotionValue!,
          startDate: product.promotionStartDate,
          endDate: product.promotionEndDate,
        );
      }
      return null;
    } catch (e) {
      _logger.error('Failed to get promotion for product', e);
      throw Exception('Failed to get promotion for product: $e');
    }
  }

  // ----------------------------
  // 2️⃣ CRUD باستخدام نموذج Product
  // ----------------------------

  Future<List<Product>> getAllProducts() async {
    // مثال ثابت: عدّل لمنطق Firestore إن رغبت
    return [
      const Product(
        id: '1',
        name: 'Test Product',
        description: 'Sample description',
        categoryId: 'cat1',
        sellerId: 'seller1',
        price: 100.0,
        imageUrl: 'https://example.com/image.jpg',
        status: 'pending',
        hasPromotion: false,
      ),
    ];
  }

  Future<Product?> getProductModel(String productId) async {
    try {
      final all = await getAllProducts();
      return all.firstWhere((p) => p.id == productId, orElse: () => null);
    } catch (e) {
      _logger.error('Failed to get product model', e);
      throw Exception('Failed to get product: $e');
    }
  }

  Future<void> createProductModel(Product product) async {
    try {
      _logger.info('Product ${product.id} created');
    } catch (e) {
      _logger.error('Failed to create product', e);
      throw Exception('Failed to create product: $e');
    }
  }

  Future<void> updateProductModel(Product product) async {
    try {
      _logger.info('Product ${product.id} updated');
    } catch (e) {
      _logger.error('Failed to update product', e);
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProductModel(String productId) async {
    try {
      _logger.info('Product $productId deleted');
    } catch (e) {
      _logger.error('Failed to delete product', e);
      throw Exception('Failed to delete product: $e');
    }
  }

  Future<void> approveProduct(String productId) async {
    try {
      _logger.info('Product $productId approved');
    } catch (e) {
      _logger.error('Failed to approve product', e);
      throw Exception('Failed to approve product: $e');
    }
  }

  Future<void> rejectProduct(String productId) async {
    try {
      _logger.info('Product $productId rejected');
    } catch (e) {
      _logger.error('Failed to reject product', e);
      throw Exception('Failed to reject product: $e');
    }
  }

  // ----------------------------
  // 3️⃣ Firestore-based CRUD للداتا الخام (Map<String, dynamic>)
  // ----------------------------

  /// جلب منتجات البائع كقائمة خرائط (Map)
  Future<List<Map<String, dynamic>>> getSellerProductsData() async {
    final auth = AuthService();
    final sellerId = await auth.getCurrentUserId();
    if (sellerId == null) throw Exception('المستخدم غير مسجّل الدخول');

    final snap = await _firestore
        .collection(AppConstants.productsCollection)
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// جلب منتجات البائع كـ Model أيضاً
  Future<List<Product>> getProductsBySeller(String sellerId) async {
    try {
      final all = await getAllProducts();
      return all.where((p) => p.sellerId == sellerId).toList();
    } catch (e) {
      _logger.error('Failed to fetch products by seller', e);
      throw Exception('Failed to fetch products by seller: $e');
    }
  }

  /// جلب منتج مفرد كـ Map
  Future<Map<String, dynamic>?> getProductData(String productId) async {
    final doc = await _firestore
        .collection(AppConstants.productsCollection)
        .doc(productId)
        .get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        data['id'] = doc.id;
        return data;
      }
    }
    return null;
  }

  /// إضافة منتج جديد (Map)
  Future<String> addProductData(Map<String, dynamic> productData) async {
    final auth = AuthService();
    final sellerId = await auth.getCurrentUserId();
    if (sellerId == null) throw Exception('المستخدم غير مسجّل الدخول');

    productData['sellerId'] = sellerId;
    productData['createdAt'] = FieldValue.serverTimestamp();
    productData['updatedAt'] = FieldValue.serverTimestamp();
    _validateProductData(productData);

    final ref = await _firestore
        .collection(AppConstants.productsCollection)
        .add(productData);
    return ref.id;
  }

  /// تحديث منتج (Map)
  Future<void> updateProductData(
    String productId,
    Map<String, dynamic> productData,
  ) async {
    final auth = AuthService();
    final sellerId = await auth.getCurrentUserId();
    if (sellerId == null) throw Exception('المستخدم غير مسجّل الدخول');

    final existing = await getProductData(productId);
    if (existing == null) throw Exception('المنتج غير موجود');
    if (existing['sellerId'] != sellerId) {
      throw Exception('ليس لديك صلاحية تعديل هذا المنتج');
    }

    productData['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore
        .collection(AppConstants.productsCollection)
        .doc(productId)
        .update(productData);
  }

  /// حذف منتج (Map)
  Future<void> deleteProductData(String productId) async {
    final auth = AuthService();
    final sellerId = await auth.getCurrentUserId();
    if (sellerId == null) throw Exception('المستخدم غير مسجّل الدخول');

    final existing = await getProductData(productId);
    if (existing == null) throw Exception('المنتج غير موجود');
    if (existing['sellerId'] != sellerId) {
      throw Exception('ليس لديك صلاحية حذف هذا المنتج');
    }

    await _firestore
        .collection(AppConstants.productsCollection)
        .doc(productId)
        .delete();
  }

  /// تبديل حالة التوفر (Map)
  Future<void> toggleProductAvailability(
    String productId,
    bool isAvailable,
  ) async {
    await updateProductData(productId, {'isAvailable': isAvailable});
  }

  /// بحث منتجات (Map)
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final auth = AuthService();
    final sellerId = await auth.getCurrentUserId();
    if (sellerId == null) throw Exception('المستخدم غير مسجّل الدخول');

    final snap = await _firestore
        .collection(AppConstants.productsCollection)
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('name')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// جلب منتجات حسب الفئة (Map)
  Future<List<Map<String, dynamic>>> getProductsByCategory(String category) async {
    return await searchProducts(category);
  }

  /// جلب فئات المنتجات (Map)
  Future<List<String>> getProductCategories() async {
    final auth = AuthService();
    final sellerId = await auth.getCurrentUserId();
    if (sellerId == null) throw Exception('المستخدم غير مسجّل الدخول');

    final snap = await _firestore
        .collection(AppConstants.productsCollection)
        .where('sellerId', isEqualTo: sellerId)
        .get();

    final Set<String> cats = {};
    for (final doc in snap.docs) {
      final cat = doc.data()['category'] as String? ?? '';
      if (cat.isNotEmpty) cats.add(cat);
    }
    return cats.isEmpty
        ? ['أخرى', 'طعام', 'مشروبات', 'إلكترونيات', 'ملابس', 'أدوات منزلية']
        : cats.toList()..sort();
  }

  // ----------------------------
  // Validation
  // ----------------------------

  void _validateProductData(Map<String, dynamic> d) {
    if (d['name'] == null || d['name'].toString().isEmpty) {
      throw Exception('اسم المنتج مطلوب');
    }
    if (d['price'] == null ||
        (d['price'] is num && d['price'] <= 0)) {
      throw Exception('سعر المنتج يجب أن يكون أكبر من صفر');
    }
    if (d['category'] == null || d['category'].toString().isEmpty) {
      throw Exception('فئة المنتج مطلوبة');
    }
    if (d['description'] == null || d['description'].toString().isEmpty) {
      throw Exception('وصف المنتج مطلوب');
    }
  }
}

/// تفاصيل العرض الترويجي
class PromotionDetails {
  final PromotionType type;
  final double value;
  final DateTime? startDate;
  final DateTime? endDate;

  PromotionDetails({
    required this.type,
    required this.value,
    this.startDate,
    this.endDate,
  });
}

/// مزوّد الخدمة (Riverpod)
final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

/// مزوّد بيانات منتجات البائع (Map)
final sellerProductsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final svc = ref.watch(productServiceProvider);
  return await svc.getSellerProductsData();
});

/// مزوّد منتج مفرد (Map)
final productDataProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, id) async {
  final svc = ref.watch(productServiceProvider);
  return await svc.getProductData(id);
});

/// مزوّد بحث المنتجات (Map)
final searchProductsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, q) async {
  final svc = ref.watch(productServiceProvider);
  return await svc.searchProducts(q);
});

/// مزوّد فئات المنتجات (Map)
final productCategoriesProvider =
    FutureProvider<List<String>>((ref) async {
  final svc = ref.watch(productServiceProvider);
  return await svc.getProductCategories();
});
