import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/user_model.dart';
import '../models/store_model.dart';

/// مزود خدمة Firestore
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// خدمة Firestore للتعامل مع قاعدة البيانات
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // المجموعات في Firestore
  final String _usersCollection = 'users';
  final String _productsCollection = 'products';
  final String _ordersCollection = 'orders';
  final String _storesCollection = 'stores';
  //final String _categoriesCollection = 'categories';

  /// الحصول على مستخدم بواسطة المعرف
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('فشل في الحصول على المستخدم: $e');
    }
  }

  /// الحصول على منتج بواسطة المعرف
  Future<Product?> getProduct(String productId) async {
    try {
      final doc = await _firestore.collection(_productsCollection).doc(productId).get();
      if (doc.exists && doc.data() != null) {
        return Product.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('فشل في الحصول على المنتج: $e');
    }
  }

  /// الحصول على قائمة المنتجات
  Future<List<Product>> getProducts() async {
    try {
      final snapshot = await _firestore.collection(_productsCollection).get();
      return snapshot.docs
          .map((doc) => Product.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('فشل في الحصول على المنتجات: $e');
    }
  }

  /// الحصول على منتجات متجر معين
  Future<List<Product>> getStoreProducts(String storeId) async {
    try {
      final snapshot = await _firestore
          .collection(_productsCollection)
          .where('sellerId', isEqualTo: storeId)
          .get();
      return snapshot.docs
          .map((doc) => Product.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('فشل في الحصول على منتجات المتجر: $e');
    }
  }

  /// الحصول على منتجات فئة معينة
  Future<List<Product>> getCategoryProducts(String categoryId) async {
    try {
      final snapshot = await _firestore
          .collection(_productsCollection)
          .where('categoryId', isEqualTo: categoryId)
          .get();
      return snapshot.docs
          .map((doc) => Product.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('فشل في الحصول على منتجات الفئة: $e');
    }
  }

  /// إنشاء منتج جديد
  Future<String?> createProduct(Product product) async {
    try {
      final docRef = _firestore.collection(_productsCollection).doc();
      await docRef.set(product.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('فشل في إنشاء المنتج: $e');
    }
  }

  /// تحديث منتج
  Future<void> updateProduct(Product product) async {
    try {
      await _firestore
          .collection(_productsCollection)
          .doc(product.id)
          .update(product.toJson());
    } catch (e) {
      throw Exception('فشل في تحديث المنتج: $e');
    }
  }

  /// حذف منتج
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection(_productsCollection).doc(productId).delete();
    } catch (e) {
      throw Exception('فشل في حذف المنتج: $e');
    }
  }

  /// الحصول على طلب بواسطة المعرف
  Future<OrderModel?> getOrder(String orderId) async {
    try {
      final doc = await _firestore.collection(_ordersCollection).doc(orderId).get();
      if (doc.exists && doc.data() != null) {
        return OrderModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('فشل في الحصول على الطلب: $e');
    }
  }

  /// الحصول على طلبات مستخدم معين
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_ordersCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('فشل في الحصول على طلبات المستخدم: $e');
    }
  }

  /// الحصول على طلبات متجر معين
  Future<List<OrderModel>> getStoreOrders(String storeId) async {
    try {
      final snapshot = await _firestore
          .collection(_ordersCollection)
          .where('sellerId', isEqualTo: storeId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('فشل في الحصول على طلبات المتجر: $e');
    }
  }

  /// الحصول على طلبات موصل معين
  Future<List<OrderModel>> getDeliveryOrders(String deliveryPersonId) async {
    try {
      final snapshot = await _firestore
          .collection(_ordersCollection)
          .where('deliveryPersonId', isEqualTo: deliveryPersonId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('فشل في الحصول على طلبات التوصيل: $e');
    }
  }

  /// إنشاء طلب جديد
  Future<String?> createOrder(OrderModel order) async {
    try {
      final docRef = _firestore.collection(_ordersCollection).doc();
      await docRef.set(order.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('فشل في إنشاء الطلب: $e');
    }
  }

  /// تحديث حالة طلب
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .update({'status': status, 'updatedAt': DateTime.now().toIso8601String()});
    } catch (e) {
      throw Exception('فشل في تحديث حالة الطلب: $e');
    }
  }

  /// الحصول على متجر بواسطة المعرف
  Future<StoreModel?> getStore(String storeId) async {
    try {
      final doc = await _firestore.collection(_storesCollection).doc(storeId).get();
      if (doc.exists && doc.data() != null) {
        return StoreModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('فشل في الحصول على المتجر: $e');
    }
  }

  /// الحصول على قائمة المتاجر
  Future<List<StoreModel>> getStores() async {
    try {
      final snapshot = await _firestore.collection(_storesCollection).get();
      return snapshot.docs
          .map((doc) => StoreModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('فشل في الحصول على المتاجر: $e');
    }
  }
}
