import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:developer';

// مصدر بيانات المنتجات من Firebase
class ProductFirebaseDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // الحصول على قائمة المنتجات للبائع
  Future<List<Map<String, dynamic>>> getProducts(String sellerId) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e, stackTrace) {
      log('Error getting products', error: e, stackTrace: stackTrace);
      throw Exception('فشل في الحصول على المنتجات: $e');
    }
  }

  // الحصول على منتج محدد بواسطة المعرف
  Future<Map<String, dynamic>?> getProductById(String productId) async {
    try {
      final docSnapshot =
          await _firestore.collection('products').doc(productId).get();

      if (!docSnapshot.exists) {
        return null;
      }

      final data = docSnapshot.data()!;
      data['id'] = docSnapshot.id;
      return data;
    } catch (e, stackTrace) {
      log('Error getting product by ID', error: e, stackTrace: stackTrace);
      throw Exception('فشل في الحصول على المنتج: $e');
    }
  }

  // إضافة منتج جديد
  Future<String> addProduct(Map<String, dynamic> productData) async {
    try {
      final docRef = await _firestore.collection('products').add(productData);
      return docRef.id;
    } catch (e, stackTrace) {
      log('Error adding product', error: e, stackTrace: stackTrace);
      throw Exception('فشل في إضافة المنتج: $e');
    }
  }

  // تحديث منتج موجود
  Future<bool> updateProduct(
      String productId, Map<String, dynamic> productData) async {
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .update(productData);
      return true;
    } catch (e, stackTrace) {
      log('Error updating product', error: e, stackTrace: stackTrace);
      throw Exception('فشل في تحديث المنتج: $e');
    }
  }

  // حذف منتج
  Future<bool> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      return true;
    } catch (e, stackTrace) {
      log('Error deleting product', error: e, stackTrace: stackTrace);
      throw Exception('فشل في حذف المنتج: $e');
    }
  }

  // تغيير حالة توفر المنتج
  Future<bool> toggleProductAvailability(
      String productId, bool isAvailable) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'isAvailable': isAvailable,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e, stackTrace) {
      log('Error toggling product availability',
          error: e, stackTrace: stackTrace);
      throw Exception('فشل في تغيير حالة توفر المنتج: $e');
    }
  }

  // رفع صور متعددة للمنتج
  Future<List<String>> uploadProductImages(
      String productId, List<String> localImagePaths) async {
    try {
      List<String> imageUrls = [];

      for (int i = 0; i < localImagePaths.length; i++) {
        final path = localImagePaths[i];
        final file = File(path);
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final storageRef =
            _storage.ref().child('products/$productId/$fileName');

        final uploadTask = storageRef.putFile(file);
        final snapshot = await uploadTask;
        final url = await snapshot.ref.getDownloadURL();

        imageUrls.add(url);
      }

      return imageUrls;
    } catch (e, stackTrace) {
      log('Error uploading product images', error: e, stackTrace: stackTrace);
      throw Exception('فشل في رفع صور المنتج: $e');
    }
  }

  // حذف صورة من صور المنتج
  Future<bool> deleteProductImage(String productId, String imageUrl) async {
    try {
      // استخراج المسار من URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final imagePath =
          pathSegments.sublist(pathSegments.indexOf('o') + 1).join('/');
      final decodedPath = Uri.decodeComponent(imagePath);

      // حذف الصورة من التخزين
      await _storage.ref(decodedPath).delete();

      return true;
    } catch (e, stackTrace) {
      log('Error deleting product image', error: e, stackTrace: stackTrace);
      throw Exception('فشل في حذف صورة المنتج: $e');
    }
  }
}
