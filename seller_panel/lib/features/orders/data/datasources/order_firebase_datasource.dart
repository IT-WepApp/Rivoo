import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seller_panel/features/orders/domain/entities/order_entity.dart';

/// مصدر بيانات Firebase للطلبات
abstract class OrderFirebaseDataSource {
  /// الحصول على قائمة الطلبات للبائع
  Future<List<OrderEntity>> getOrders(String sellerId);

  /// الحصول على تفاصيل طلب محدد
  Future<OrderEntity> getOrderDetails(String orderId);

  /// تحديث حالة الطلب
  Future<OrderEntity> updateOrderStatus(String orderId, String status);

  /// الحصول على إحصائيات الطلبات للبائع
  Future<Map<String, dynamic>> getOrderStatistics(String sellerId);

  /// البحث عن الطلبات
  Future<List<OrderEntity>> searchOrders(
    String sellerId, {
    String? query,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  });
}

/// تنفيذ مصدر بيانات Firebase للطلبات
class OrderFirebaseDataSourceImpl implements OrderFirebaseDataSource {
  final FirebaseFirestore _firestore;

  OrderFirebaseDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<OrderEntity>> getOrders(String sellerId) async {
    final querySnapshot = await _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('orderDate', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => _convertToOrderEntity(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<OrderEntity> getOrderDetails(String orderId) async {
    final docSnapshot = await _firestore.collection('orders').doc(orderId).get();

    if (!docSnapshot.exists) {
      throw Exception('الطلب غير موجود');
    }

    return _convertToOrderEntity(docSnapshot.id, docSnapshot.data()!);
  }

  @override
  Future<OrderEntity> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return getOrderDetails(orderId);
  }

  @override
  Future<Map<String, dynamic>> getOrderStatistics(String sellerId) async {
    final querySnapshot = await _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .get();

    final orders = querySnapshot.docs;
    
    // إجمالي الطلبات
    final totalOrders = orders.length;
    
    // إجمالي المبيعات
    double totalSales = 0;
    for (var doc in orders) {
      totalSales += (doc.data()['totalAmount'] as num).toDouble();
    }
    
    // عدد الطلبات حسب الحالة
    final pendingOrders = orders.where((doc) => doc.data()['status'] == 'pending').length;
    final processingOrders = orders.where((doc) => doc.data()['status'] == 'processing').length;
    final shippedOrders = orders.where((doc) => doc.data()['status'] == 'shipped').length;
    final deliveredOrders = orders.where((doc) => doc.data()['status'] == 'delivered').length;
    final cancelledOrders = orders.where((doc) => doc.data()['status'] == 'cancelled').length;

    return {
      'totalOrders': totalOrders,
      'totalSales': totalSales,
      'pendingOrders': pendingOrders,
      'processingOrders': processingOrders,
      'shippedOrders': shippedOrders,
      'deliveredOrders': deliveredOrders,
      'cancelledOrders': cancelledOrders,
    };
  }

  @override
  Future<List<OrderEntity>> searchOrders(
    String sellerId, {
    String? query,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query<Map<String, dynamic>> ordersQuery = _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId);

    if (status != null && status.isNotEmpty) {
      ordersQuery = ordersQuery.where('status', isEqualTo: status);
    }

    if (startDate != null && endDate != null) {
      ordersQuery = ordersQuery.where(
        'orderDate',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    } else if (startDate != null) {
      ordersQuery = ordersQuery.where(
        'orderDate',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    } else if (endDate != null) {
      ordersQuery = ordersQuery.where(
        'orderDate',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }

    final querySnapshot = await ordersQuery.get();
    
    List<OrderEntity> orders = querySnapshot.docs
        .map((doc) => _convertToOrderEntity(doc.id, doc.data()))
        .toList();

    if (query != null && query.isNotEmpty) {
      final lowercaseQuery = query.toLowerCase();
      orders = orders.where((order) {
        return order.customerName.toLowerCase().contains(lowercaseQuery) ||
            order.id.toLowerCase().contains(lowercaseQuery);
      }).toList();
    }

    return orders;
  }

  /// تحويل بيانات Firestore إلى كيان الطلب
  OrderEntity _convertToOrderEntity(String id, Map<String, dynamic> data) {
    final List<OrderItemEntity> items = [];
    
    if (data.containsKey('items') && data['items'] is List) {
      for (var item in data['items']) {
        items.add(OrderItemEntity(
          productId: item['productId'],
          productName: item['productName'],
          quantity: (item['quantity'] as num).toInt(),
          price: (item['price'] as num).toDouble(),
          discount: item['discount'] != null ? (item['discount'] as num).toDouble() : null,
          imageUrl: item['imageUrl'],
        ));
      }
    }

    return OrderEntity(
      id: id,
      customerId: data['customerId'],
      customerName: data['customerName'],
      sellerId: data['sellerId'],
      status: data['status'],
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      totalAmount: (data['totalAmount'] as num).toDouble(),
      items: items,
      shippingAddress: data['shippingAddress'],
      paymentMethod: data['paymentMethod'],
      paymentStatus: data['paymentStatus'],
      trackingNumber: data['trackingNumber'],
    );
  }
}
