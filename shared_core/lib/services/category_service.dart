import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_models/shared_models.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod

// Provider definition
final categoryServiceProvider = Provider<CategoryService>((ref) => CategoryService());

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'categories';

  // Use Category from shared_models
  Future<List<Category>> getAllCategories() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionPath).get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID to data
        return Category.fromJson(data);
      }).toList();
    } catch (e) {
      log('Error getting all categories: $e');
      rethrow;
    }
  }

  Future<Category?> getCategory(String categoryId) async {
    try {
      final doc = await _firestore.collection(_collectionPath).doc(categoryId).get();
      if (doc.exists && doc.data() != null) {
         final data = doc.data()!;
         data['id'] = doc.id;
         return Category.fromJson(data);
      }
      return null;
    } catch (e) {
      log('Error getting category: $e');
      rethrow;
    }
  }

  Future<void> addCategory(Category category) async {
    // Assuming category model doesn't include ID initially, Firestore generates it
    // Or if the model requires ID, ensure it's provided before calling toJson
    try {
      await _firestore.collection(_collectionPath).add(category.toJson());
      // If using document ID from model:
      // await _firestore.collection(_collectionPath).doc(category.id).set(category.toJson());
    } catch (e) {
      log('Error adding category: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      // Ensure category object has the correct document ID
      await _firestore.collection(_collectionPath).doc(category.id).update(category.toJson());
    } catch (e) {
      log('Error updating category: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection(_collectionPath).doc(categoryId).delete();
    } catch (e) {
      log('Error deleting category: $e');
      rethrow;
    }
  }
}