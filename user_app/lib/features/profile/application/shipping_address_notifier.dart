import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/features/profile/domain/models/shipping_address.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/features/auth/application/auth_notifier.dart';
import 'package:uuid/uuid.dart';

class ShippingAddressNotifier extends StateNotifier<List<ShippingAddress>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? _userId;
  
  ShippingAddressNotifier(this._userId) : super([]) {
    if (_userId != null) {
      loadAddresses();
    }
  }

  Future<void> loadAddresses() async {
    if (_userId == null) return;
    
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('shipping_addresses')
          .get();
      
      final addresses = snapshot.docs
          .map((doc) => ShippingAddress.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
      
      state = addresses;
    } catch (e) {
      // Handle error
      print('Error loading shipping addresses: $e');
    }
  }

  Future<void> addAddress(ShippingAddress address) async {
    if (_userId == null) return;
    
    try {
      // Check if this is the first address, make it default if so
      final isFirst = state.isEmpty;
      final addressWithId = address.copyWith(
        id: const Uuid().v4(),
        userId: _userId,
        isDefault: isFirst ? true : address.isDefault,
      );
      
      // If this address is set as default, update all other addresses
      if (addressWithId.isDefault) {
        await _updateDefaultAddresses();
      }
      
      // Add the new address to Firestore
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('shipping_addresses')
          .doc(addressWithId.id)
          .set(addressWithId.toMap());
      
      // Update local state
      state = [...state, addressWithId];
    } catch (e) {
      // Handle error
      print('Error adding shipping address: $e');
      rethrow;
    }
  }

  Future<void> updateAddress(ShippingAddress address) async {
    if (_userId == null) return;
    
    try {
      // If this address is set as default, update all other addresses
      if (address.isDefault) {
        await _updateDefaultAddresses();
      }
      
      // Update the address in Firestore
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('shipping_addresses')
          .doc(address.id)
          .update(address.toMap());
      
      // Update local state
      state = state.map((a) => a.id == address.id ? address : a).toList();
    } catch (e) {
      // Handle error
      print('Error updating shipping address: $e');
      rethrow;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    if (_userId == null) return;
    
    try {
      // Delete the address from Firestore
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('shipping_addresses')
          .doc(addressId)
          .delete();
      
      // Update local state
      state = state.where((a) => a.id != addressId).toList();
      
      // If the deleted address was the default one and we have other addresses,
      // make the first one the default
      if (state.isNotEmpty && !state.any((a) => a.isDefault)) {
        final newDefault = state.first.copyWith(isDefault: true);
        await updateAddress(newDefault);
      }
    } catch (e) {
      // Handle error
      print('Error deleting shipping address: $e');
      rethrow;
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    if (_userId == null) return;
    
    try {
      // Update all addresses to not be default
      await _updateDefaultAddresses();
      
      // Set the selected address as default
      final address = state.firstWhere((a) => a.id == addressId);
      final updatedAddress = address.copyWith(isDefault: true);
      
      // Update the address in Firestore
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('shipping_addresses')
          .doc(addressId)
          .update({'isDefault': true});
      
      // Update local state
      state = state.map((a) => a.id == addressId ? updatedAddress : a).toList();
    } catch (e) {
      // Handle error
      print('Error setting default shipping address: $e');
      rethrow;
    }
  }

  Future<void> _updateDefaultAddresses() async {
    if (_userId == null) return;
    
    try {
      // Get all addresses that are currently set as default
      final batch = _firestore.batch();
      final defaultAddresses = state.where((a) => a.isDefault).toList();
      
      // Update them to not be default in Firestore
      for (final address in defaultAddresses) {
        final docRef = _firestore
            .collection('users')
            .doc(_userId)
            .collection('shipping_addresses')
            .doc(address.id);
        batch.update(docRef, {'isDefault': false});
      }
      
      await batch.commit();
      
      // Update local state
      state = state.map((a) => a.isDefault ? a.copyWith(isDefault: false) : a).toList();
    } catch (e) {
      // Handle error
      print('Error updating default shipping addresses: $e');
      rethrow;
    }
  }
}

final shippingAddressProvider = StateNotifierProvider<ShippingAddressNotifier, List<ShippingAddress>>((ref) {
  final userId = ref.watch(userIdProvider);
  return ShippingAddressNotifier(userId);
});

final defaultAddressProvider = Provider<ShippingAddress?>((ref) {
  final addresses = ref.watch(shippingAddressProvider);
  return addresses.isEmpty ? null : addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
});
