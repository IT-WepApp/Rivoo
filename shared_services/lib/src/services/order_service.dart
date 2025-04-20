import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_models/shared_models.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // تحديث حالة الطلب
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({'status': newStatus});
      return true;
    } catch (e, st) {
      developer.log('Error updating order status: $e', stackTrace: st);
      return false;
    }
  }

  // تحديث موقع موظف التوصيل
  Future<bool> updateDeliveryPersonnelLocation(String orderId, DeliveryLocation location) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'deliveryPersonnelLocation': {
          'latitude': location.latitude,
          'longitude': location.longitude,
        }
      });
      return true;
    } catch (e, st) {
      developer.log('Error updating delivery personnel location: $e', stackTrace: st);
      return false;
    }
  }

  // استرجاع الطلبات المسلمة لشخص توصيل محدد
  Future<List<OrderModel>> getDeliveredOrdersForPersonnel(String deliveryPersonnelId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('deliveryId', isEqualTo: deliveryPersonnelId)
          .where('status', isEqualTo: 'delivered')
          .get();

      return snapshot.docs.map((doc) => OrderModel.fromJson(doc.data())).toList();
    } catch (e, st) {
      developer.log('Error getting delivered orders for personnel: $e', stackTrace: st);
      return [];
    }
  }

  // استرجاع تفاصيل طلب واحد
  Future<OrderModel?> getOrder(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists && doc.data() != null) {
        return OrderModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e, st) {
      developer.log('Error getting order: $e', stackTrace: st);
      return null;
    }
  }
}
