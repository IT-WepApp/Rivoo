import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_libs/lib/models/shared_models.dart'; // Corrected import
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod

// Provider definition
final userServiceProvider = Provider<UserService>((ref) => UserService());

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'users'; // Or differentiate based on user type

  // Use UserModel from shared_models
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(_collectionPath)
          .doc(user.id)
          .set(user.toJson());
    } catch (e) {
      log('Error creating user: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final doc =
          await _firestore.collection(_collectionPath).doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      log('Error getting user: $e');
      rethrow;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(_collectionPath)
          .doc(user.id)
          .update(user.toJson());
    } catch (e) {
      log('Error updating user: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(_collectionPath).doc(userId).delete();
    } catch (e) {
      log('Error deleting user: $e');
      rethrow;
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionPath).get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      log('Error getting all users: $e');
      rethrow;
    }
  }

  // Methods needed by user_app/profile_notifier.dart
  Future<UserModel?> getUserProfile() async {
    // This likely needs the current user's ID from auth state
    // String? userId = FirebaseAuth.instance.currentUser?.uid;
    // if (userId == null) return null;
    // return getUser(userId);
    // Placeholder: Replace with actual logic using auth state
    return null;
  }

  Future<bool> updateUserProfile(UserModel updatedUser) async {
    try {
      await updateUser(updatedUser);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Method needed by admin_panell login
  Future<String> getUserTypeFromDatabase(String userId) async {
    final user = await getUser(userId);
    return user?.role ?? 'unknown'; // Assuming UserModel has a 'role' field
  }
}
