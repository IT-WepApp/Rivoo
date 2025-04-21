import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import 'auth_service.dart';

/// خدمة إدارة المنتجات للبائعين
class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // الحصول على قائمة منتجات البائع
  Future<List<Map<String, dynamic>>> getSellerProducts() async {
    final authService = AuthService();
    final sellerId = await authService.getCurrentUserId();

    if (sellerId == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    final snapshot = await _firestore
        .collection(AppConstants.productsCollection)
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // الحصول على منتج محدد
  Future<Map<String, dynamic>?> getProduct(String productId) async {
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

  // إضافة منتج جديد
  Future<String> addProduct(Map<String, dynamic> productData) async {
    final authService = AuthService();
    final sellerId = await authService.getCurrentUserId();

    if (sellerId == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    // إضافة معرف البائع وتاريخ الإنشاء
    productData['sellerId'] = sellerId;
    productData['createdAt'] = FieldValue.serverTimestamp();
    productData['updatedAt'] = FieldValue.serverTimestamp();

    // التأكد من وجود الحقول الإلزامية
    _validateProductData(productData);

    // إضافة المنتج إلى Firestore
    final docRef = await _firestore
        .collection(AppConstants.productsCollection)
        .add(productData);
    return docRef.id;
  }

  // تحديث منتج موجود
  Future<void> updateProduct(
      String productId, Map<String, dynamic> productData) async {
    final authService = AuthService();
    final sellerId = await authService.getCurrentUserId();

    if (sellerId == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    // التحقق من ملكية المنتج
    final product = await getProduct(productId);
    if (product == null) {
      throw Exception('المنتج غير موجود');
    }

    if (product['sellerId'] != sellerId) {
      throw Exception('ليس لديك صلاحية تعديل هذا المنتج');
    }

    // إضافة تاريخ التحديث
    productData['updatedAt'] = FieldValue.serverTimestamp();

    // تحديث المنتج في Firestore
    await _firestore
        .collection(AppConstants.productsCollection)
        .doc(productId)
        .update(productData);
  }

  // حذف منتج
  Future<void> deleteProduct(String productId) async {
    final authService = AuthService();
    final sellerId = await authService.getCurrentUserId();

    if (sellerId == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    // التحقق من ملكية المنتج
    final product = await getProduct(productId);
    if (product == null) {
      throw Exception('المنتج غير موجود');
    }

    if (product['sellerId'] != sellerId) {
      throw Exception('ليس لديك صلاحية حذف هذا المنتج');
    }

    // حذف المنتج من Firestore
    await _firestore
        .collection(AppConstants.productsCollection)
        .doc(productId)
        .delete();
  }

  // تغيير حالة توفر المنتج
  Future<void> toggleProductAvailability(
      String productId, bool isAvailable) async {
    await updateProduct(productId, {'isAvailable': isAvailable});
  }

  // البحث عن منتجات
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final authService = AuthService();
    final sellerId = await authService.getCurrentUserId();

    if (sellerId == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    // البحث في اسم المنتج ووصفه
    final snapshot = await _firestore
        .collection(AppConstants.productsCollection)
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('name')
        .startAt([query]).endAt(['$query\uf8ff']).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // الحصول على منتجات حسب الفئة
  Future<List<Map<String, dynamic>>> getProductsByCategory(
      String category) async {
    final authService = AuthService();
    final sellerId = await authService.getCurrentUserId();

    if (sellerId == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    final snapshot = await _firestore
        .collection(AppConstants.productsCollection)
        .where('sellerId', isEqualTo: sellerId)
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // التحقق من صحة بيانات المنتج
  void _validateProductData(Map<String, dynamic> productData) {
    if (productData['name'] == null || productData['name'].toString().isEmpty) {
      throw Exception('اسم المنتج مطلوب');
    }

    if (productData['price'] == null ||
        (productData['price'] is num && productData['price'] <= 0)) {
      throw Exception('سعر المنتج يجب أن يكون أكبر من صفر');
    }

    if (productData['category'] == null ||
        productData['category'].toString().isEmpty) {
      throw Exception('فئة المنتج مطلوبة');
    }

    if (productData['description'] == null ||
        productData['description'].toString().isEmpty) {
      throw Exception('وصف المنتج مطلوب');
    }
  }
}

// مزود خدمة المنتجات
final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

// مزود قائمة منتجات البائع
final sellerProductsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final productService = ref.watch(productServiceProvider);
  return await productService.getSellerProducts();
});

// مزود منتج محدد
final productProvider = FutureProvider.family<Map<String, dynamic>?, String>(
    (ref, productId) async {
  final productService = ref.watch(productServiceProvider);
  return await productService.getProduct(productId);
});

// مزود منتجات حسب الفئة
final productsByCategoryProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, category) async {
  final productService = ref.watch(productServiceProvider);
  return await productService.getProductsByCategory(category);
});
