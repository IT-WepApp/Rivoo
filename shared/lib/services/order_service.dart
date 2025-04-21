import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_models/shared_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderServiceProvider = Provider<OrderService>((ref) => OrderService());

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrder(OrderModel order) async {
    try {
      await _firestore.collection('orders').doc(order.id).set(order.toJson());
    } catch (e, st) {
      developer.log('Error creating order',
          error: e, stackTrace: st, name: 'OrderService');
      rethrow;
    }
  }

  Future<OrderModel?> getOrder(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e, st) {
      developer.log('Error getting order',
          error: e, stackTrace: st, name: 'OrderService');
      rethrow;
    }
  }

  Future<void> updateOrder(OrderModel order) async {
    try {
      await _firestore
          .collection('orders')
          .doc(order.id)
          .update(order.toJson());
    } catch (e, st) {
      developer.log('Error updating order',
          error: e, stackTrace: st, name: 'OrderService');
      rethrow;
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore
          .collection('orders')
          .doc(orderId)
          .update({'status': status});
    } catch (e, st) {
      developer.log('Error updating order status',
          error: e, stackTrace: st, name: 'OrderService');
      rethrow;
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).delete();
    } catch (e, st) {
      developer.log('Error deleting order',
          error: e, stackTrace: st, name: 'OrderService');
      rethrow;
    }
  }

  Future<List<OrderModel>> getOrdersByUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();
      return querySnapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data()))
          .toList();
    } catch (e, st) {
      developer.log('Error getting orders by user',
          error: e, stackTrace: st, name: 'OrderService');
      rethrow;
    }
  }

  Future<List<OrderModel>> getAllOrders() async {
    try {
      final querySnapshot = await _firestore.collection('orders').get();
      return querySnapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data()))
          .toList();
    } catch (e, st) {
      developer.log('Error getting all orders',
          error: e, stackTrace: st, name: 'OrderService');
      rethrow;
    }
  }

  Future<List<OrderModel>> getOrdersBySeller(String sellerId) async {
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: sellerId)
          .get();
      return querySnapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data()))
          .toList();
    } catch (e, st) {
      developer.log('Error getting orders by seller',
          error: e, stackTrace: st, name: 'OrderService');
      rethrow;
    }
  }

  Future<void> placeOrder(
      String userId, List<CartItemModel> cartItems, double totalPrice) async {
    final orderId = _firestore.collection('orders').doc().id;
    final now = Timestamp.now();

    final orderProducts = cartItems
        .map((item) => OrderProductItem(
              productId: item.productId,
              name: item.name,
              price: item.price,
              quantity: item.quantity,
            ))
        .toList();

    const String sellerId = 'seller_from_product_1';
    const String userAddress = 'default_address';

    final newOrder = OrderModel(
      id: orderId,
      userId: userId,
      sellerId: sellerId,
      products: orderProducts,
      total: totalPrice,
      status: 'pending',
      address: userAddress,
      createdAt: now,
    );

    await createOrder(newOrder);
  }

  Stream<OrderModel?> getOrderStream(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return OrderModel.fromJson(snapshot.data()!);
      }
      return null;
    });
  }

  Stream<List<OrderModel>> getDeliveryOrdersStream(String deliveryPersonId) {
    return _firestore
        .collection('orders')
        .where('deliveryId', isEqualTo: deliveryPersonId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromJson(doc.data()))
            .toList());
  }

  Future<List<OrderModel>> getAvailableOrders() async {
    final querySnapshot = await _firestore
        .collection('orders')
        .where('status', isEqualTo: 'processing')
        .get();
    return querySnapshot.docs
        .map((doc) => OrderModel.fromJson(doc.data()))
        .toList();
  }

  Future<void> acceptOrder(String orderId, String deliveryPersonId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'deliveryId': deliveryPersonId,
      'status': 'accepted',
    });
  }

  Future<void> completeOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'delivered',
    });
  }

  Future<OrderModel?> getOrderDetails(String orderId) async {
    return getOrder(orderId);
  }

  Future<List<OrderModel>> getDeliveredOrdersForPersonnel(
    String deliveryPersonnelId, {
    String? sortBy,
    String? sortOrder,
    String? filterByStatus,
  }) async {
    try {
      Query query = _firestore
          .collection('orders')
          .where('deliveryId', isEqualTo: deliveryPersonnelId)
          .where('status', isEqualTo: filterByStatus ?? 'delivered');

      if (sortBy != null && sortBy.isNotEmpty) {
        query = query.orderBy(sortBy, descending: sortOrder == 'desc');
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      developer.log('Error getting delivered orders for personnel',
          error: e, stackTrace: st, name: 'OrderService');
      rethrow;
    }
  }
}
