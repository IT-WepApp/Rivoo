import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/delivery_location_model.dart';
import '../models/order.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // تحديث حالة الطلب
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore
          .collection('orders')
          .doc(orderId)
          .update({'status': newStatus});
      return true;
    } catch (e, st) {
      developer.log('Error updating order status: $e', stackTrace: st);
      return false;
    }
  }

  // تحديث موقع موظف التوصيل
  Future<bool> updateDeliveryPersonnelLocation(
      String orderId, DeliveryLocation location) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'deliveryPersonnelLocation': {
          'latitude': location.latitude,
          'longitude': location.longitude,
        }
      });
      return true;
    } catch (e, st) {
      developer.log('Error updating delivery personnel location: $e',
          stackTrace: st);
      return false;
    }
  }

  // استرجاع الطلبات المسلمة لشخص توصيل محدد مع دعم الفلترة والفرز
  Future<List<OrderModel>> getDeliveredOrdersForPersonnel(
    String deliveryPersonnelId, {
    String? sortBy,
    String? sortOrder,
    String? filterByStatus,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('orders')
          .where('deliveryId', isEqualTo: deliveryPersonnelId);

      if (filterByStatus != null) {
        query = query.where('status', isEqualTo: filterByStatus);
      } else {
        query = query.where('status', isEqualTo: 'delivered');
      }

      if (sortBy != null) {
        query = query.orderBy(sortBy, descending: sortOrder == 'desc');
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data()))
          .toList();
    } catch (e, st) {
      developer.log('Error getting delivered orders for personnel: $e',
          stackTrace: st);
      return [];
    }
  }

  // استرجاع جميع الطلبات
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final snapshot = await _firestore.collection('orders').get();
      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data()))
          .toList();
    } catch (e, st) {
      developer.log('Error getting all orders: $e', stackTrace: st);
      return [];
    }
  }

  // استرجاع تفاصيل طلب واحد
  Future<OrderModel?> getOrder(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      final data = doc.data();
      if (doc.exists && data != null) {
        return OrderModel.fromJson(data);
      }
      return null;
    } catch (e, st) {
      developer.log('Error getting order: $e', stackTrace: st);
      return null;
    }
  }
}
