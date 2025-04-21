import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_models/shared_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod

// Provider definition
final storeServiceProvider = Provider<StoreService>((ref) => StoreService());

class StoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'stores';

  // Use StoreModel from shared_models
  Future<List<StoreModel>> getAllStores() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionPath).get();
      // Correctly map using StoreModel.fromJson
      return querySnapshot.docs
          .map((doc) => StoreModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      log('Error getting all stores: $e');
      rethrow;
    }
  }

  Future<StoreModel?> getStore(String storeId) async {
    try {
      final doc =
          await _firestore.collection(_collectionPath).doc(storeId).get();
      if (doc.exists && doc.data() != null) {
        // Correctly use StoreModel.fromJson
        return StoreModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      log('Error getting store: $e');
      rethrow;
    }
  }

  Future<void> createStore(StoreModel store) async {
    try {
      // Use StoreModel object
      // TODO: Ensure StoreModel includes a status field, perhaps defaulting to 'pending'
      await _firestore
          .collection(_collectionPath)
          .doc(store.id)
          .set(store.toJson());
    } catch (e) {
      log('Error creating store: $e');
      rethrow;
    }
  }

  Future<void> updateStore(StoreModel store) async {
    try {
      // Use StoreModel object
      await _firestore
          .collection(_collectionPath)
          .doc(store.id)
          .update(store.toJson());
    } catch (e) {
      log('Error updating store: $e');
      rethrow;
    }
  }

  Future<void> deleteStore(String storeId) async {
    try {
      await _firestore.collection(_collectionPath).doc(storeId).delete();
    } catch (e) {
      log('Error deleting store: $e');
      rethrow;
    }
  }

  // --- Added Methods for Approval/Rejection ---

  Future<void> approveStore(String storeId) async {
    try {
      // TODO: Add a 'status' field to StoreModel if it doesn't exist
      await _firestore
          .collection(_collectionPath)
          .doc(storeId)
          .update({'status': 'approved'});
      log('Store approved: $storeId');
    } catch (e) {
      log('Error approving store $storeId: $e');
      rethrow;
    }
  }

  Future<void> rejectStore(String storeId) async {
    try {
      // TODO: Add a 'status' field to StoreModel if it doesn't exist
      await _firestore
          .collection(_collectionPath)
          .doc(storeId)
          .update({'status': 'rejected'});
      log('Store rejected: $storeId');
    } catch (e) {
      log('Error rejecting store $storeId: $e');
      rethrow;
    }
  }

  // --- End Added Methods ---

  // Methods needed by user_app
  Future<StoreModel?> getStoreDetails(String storeId) async {
    return getStore(storeId);
  }
}
