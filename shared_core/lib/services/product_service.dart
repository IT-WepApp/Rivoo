import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_models/shared_models.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/src/models/promotion.dart';

final productServiceProvider = Provider<ProductService>((ref) => ProductService());

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createProduct(Product product) async {
    try {
      await _firestore.collection('products').doc(product.id).set(product.toJson());
    } catch (e) {
      log('Error creating product: $e');
      rethrow;
    }
  }

  Future<Product?> getProduct(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return Product.fromJson(doc.data()!..['id'] = doc.id);
      }
      return null;
    } catch (e) {
      log('Error getting product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _firestore.collection('products').doc(product.id).update(product.toJson());
    } catch (e) {
      log('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      log('Error deleting product: $e');
      rethrow;
    }
  }

  Future<List<Product>> getProductsBySeller(String sellerId) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .get();
      return querySnapshot.docs
          .map((doc) => Product.fromJson(doc.data()..['id'] = doc.id))
          .toList();
    } catch (e) {
      log('Error getting products by seller: $e');
      rethrow;
    }
  }

  Future<List<Product>> getAllProducts() async {
    try {
      final querySnapshot = await _firestore.collection('products').get();
      return querySnapshot.docs
          .map((doc) => Product.fromJson(doc.data()..['id'] = doc.id))
          .toList();
    } catch (e) {
      log('Error getting all products: $e');
      rethrow;
    }
  }

  Future<void> approveProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).update({'status': 'approved'}); 
    } catch (e) {
      log('Error approving product: $e');
      rethrow;
    }
  }

  Future<void> rejectProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).update({'status': 'rejected'});
    } catch (e) {
      log('Error rejecting product: $e');
      rethrow;
    }
  }

  Future<List<Product>> getProductsByStoreId(String storeId) async {
    return getProductsBySeller(storeId);
  }

  Stream<List<Product>> getAllProductsStream() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      try {
        return snapshot.docs
            .map((doc) => Product.fromJson(doc.data()..['id'] = doc.id))
            .toList();
      } catch (e) {
        log('Error mapping products stream: $e');
        return [];
      }
    });
  }

  Future<void> updatePromotion(String productId, Promotion promotion) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'hasPromotion': true,
        'promotionType': promotion.type.name,
        'promotionValue': promotion.value,
        'promotionStartDate': promotion.startDate,
        'promotionEndDate': promotion.endDate,
      });
    } catch (e) {
      log('Error updating promotion: $e');
      rethrow;
    }
  }

  Future<void> removePromotion(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'hasPromotion': false,
        'promotionType': null,
        'promotionValue': null,
        'promotionStartDate': null,
        'promotionEndDate': null,
      });
    } catch (e) {
      log('Error removing promotion: $e');
      rethrow;
    }
  }
}
