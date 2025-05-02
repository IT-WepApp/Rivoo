import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/constants/app_constants.dart';
import 'package:shared_libs/models/order.dart';
import 'package:shared_libs/models/delivery_location_model.dart';
import 'package:shared_libs/services/auth_service.dart';

/// خدمة إدارة الطلبيات المشتركة
class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 1️⃣ تحديث حالة الطلب (نسخة عامّة، ترجع نجاح/فشل)
  Future<bool> updateOrderStatus(
    String orderId,
    String newStatus,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.ordersCollection)
          .doc(orderId)
          .update({'status': newStatus});
      return true;
    } catch (e, st) {
      developer.log('Error updating order status: $e', stackTrace: st);
      return false;
    }
  }

  /// 2️⃣ تحديث موقع الموصّل
  Future<bool> updateDeliveryPersonnelLocation(
      String orderId, DeliveryLocation location) async {
    try {
      await _firestore.collection(AppConstants.ordersCollection).doc(orderId).update({
        'deliveryPersonnelLocation': {
          'latitude': location.latitude,
          'longitude': location.longitude,
        }
      });
      return true;
    } catch (e, st) {
      developer.log(
          'Error updating delivery personnel location: $e', stackTrace: st);
      return false;
    }
  }

  /// 3️⃣ جلب طلبيات تم تسليمها لموظّف توصيل
  Future<List<OrderModel>> getDeliveredOrdersForPersonnel(
    String deliveryPersonnelId, {
    String? sortBy,
    String? sortOrder,
    String? filterByStatus,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(AppConstants.ordersCollection)
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
      return snapshot.docs.map((doc) => OrderModel.fromJson(doc.data())).toList();
    } catch (e, st) {
      developer.log(
          'Error getting delivered orders for personnel: $e', stackTrace: st);
      return [];
    }
  }

  /// 4️⃣ جلب جميع الطلبيات كنموذج
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final snapshot = await _firestore.collection(AppConstants.ordersCollection).get();
      return snapshot.docs.map((doc) => OrderModel.fromJson(doc.data())).toList();
    } catch (e, st) {
      developer.log('Error getting all orders: $e', stackTrace: st);
      return [];
    }
  }

  /// 5️⃣ جلب طلب محدد كنموذج
  Future<OrderModel?> getOrderModel(String orderId) async {
    try {
      final doc = await _firestore.collection(AppConstants.ordersCollection).doc(orderId).get();
      final data = doc.data();
      if (doc.exists && data != null) {
        return OrderModel.fromJson(data);
      }
      return null;
    } catch (e, st) {
      developer.log('Error getting order model: $e', stackTrace: st);
      return null;
    }
  }

  /// 6️⃣ جلب طلبيات لمُبسِّط (Seller) كنموذج
  Future<List<OrderModel>> getOrdersBySellerModel(String sellerId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.ordersCollection)
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data()))
          .toList();
    } catch (e, st) {
      developer.log('Error getting orders by seller (model): $e', stackTrace: st);
      return [];
    }
  }

  /// 7️⃣ جلب طلبيات البائع (Seller) كخريطة بيانات
  Future<List<Map<String, dynamic>>> getSellerOrders() async {
    final authService = AuthService();
    final sellerId = await authService.getCurrentUserId();

    if (sellerId == null) {
      throw Exception('المستخدم غير مسجّل الدخول');
    }

    final snapshot = await _firestore
        .collection(AppConstants.ordersCollection)
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// 8️⃣ جلب طلب البائع كخريطة بيانات
  Future<Map<String, dynamic>?> getOrderData(String orderId) async {
    final doc = await _firestore
        .collection(AppConstants.ordersCollection)
        .doc(orderId)
        .get();

    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        data['id'] = doc.id;
        return data;
      }
    }

    return null;
  }

  /// 9️⃣ تفاصيل الطلب (يطابق getOrderData)
  Future<Map<String, dynamic>?> getOrderDetails(String orderId) =>
      getOrderData(orderId);

  /// 🔟 تحديث حالة الطلب مع سجل التاريخ (للبائع)
  Future<void> updateOrderStatusWithHistory(String orderId, String status) async {
    final authService = AuthService();
    final sellerId = await authService.getCurrentUserId();

    if (sellerId == null) {
      throw Exception('المستخدم غير مسجّل الدخول');
    }

    final order = await getOrderData(orderId);
    if (order == null) {
      throw Exception('الطلب غير موجود');
    }

    if (order['sellerId'] != sellerId) {
      throw Exception('ليس لديك صلاحية تعديل هذا الطلب');
    }

    await _firestore
        .collection(AppConstants.ordersCollection)
        .doc(orderId)
        .update({
      'status': status,
      'statusUpdatedAt': FieldValue.serverTimestamp(),
      'statusHistory': FieldValue.arrayUnion([
        {'status': status, 'timestamp': FieldValue.serverTimestamp()}
      ]),
    });
  }

  /// 1️⃣1️⃣ جلب طلبيات حسب الحالة (للبائع)
  Future<List<Map<String, dynamic>>> getOrdersByStatus(String status) async {
    final authService = AuthService();
    final sellerId = await authService.getCurrentUserId();
    if (sellerId == null) {
      throw Exception('المستخدم غير مسجّل الدخول');
    }
    final snapshot = await _firestore
        .collection(AppConstants.ordersCollection)
        .where('sellerId', isEqualTo: sellerId)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// 1️⃣2️⃣ جلب طلبيات جديدة (حالة pending)
  Future<List<Map<String, dynamic>>> getNewOrders() async =>
      getOrdersByStatus(AppConstants.orderStatusPending);

  /// 1️⃣3️⃣ جلب طلبيات التحضير
  Future<List<Map<String, dynamic>>> getPreparingOrders() async =>
      getOrdersByStatus(AppConstants.orderStatusPreparing);

  /// 1️⃣4️⃣ جلب طلبيات التوصيل الجارية
  Future<List<Map<String, dynamic>>> getDeliveringOrders() async =>
      getOrdersByStatus(AppConstants.orderStatusDelivering);

  /// 1️⃣5️⃣ جلب طلبيات مكتملة
  Future<List<Map<String, dynamic>>> getCompletedOrders() async =>
      getOrdersByStatus(AppConstants.orderStatusDelivered);

  /// 1️⃣6️⃣ جلب طلبيات ملغاة
  Future<List<Map<String, dynamic>>> getCancelledOrders() async =>
      getOrdersByStatus(AppConstants.orderStatusCancelled);

  /// 1️⃣7️⃣ بحث في الطلبيات حسب اسم العميل
  Future<List<Map<String, dynamic>>> searchOrders(String query) async {
    final authService = AuthService();
    final sellerId = await authService.getCurrentUserId();
    if (sellerId == null) {
      throw Exception('المستخدم غير مسجّل الدخول');
    }
    final snapshot = await _firestore
        .collection(AppConstants.ordersCollection)
        .where('sellerId', isEqualTo: sellerId)
        .where('customerName', isGreaterThanOrEqualTo: query)
        .where('customerName', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// 1️⃣8️⃣ إحصائيات الطلبات العامة
  Future<Map<String, dynamic>> getOrderStatistics() async {
    final authService = AuthService();
    final sellerId = await authService.getCurrentUserId();
    if (sellerId == null) {
      throw Exception('المستخدم غير مسجّل الدخول');
    }
    final allOrders = await getSellerOrders();
    final pendingCount = allOrders
        .where((o) => o['status'] == AppConstants.orderStatusPending)
        .length;
    final preparingCount = allOrders
        .where((o) => o['status'] == AppConstants.orderStatusPreparing)
        .length;
    final deliveringCount = allOrders
        .where((o) => o['status'] == AppConstants.orderStatusDelivering)
        .length;
    final deliveredCount = allOrders
        .where((o) => o['status'] == AppConstants.orderStatusDelivered)
        .length;
    final cancelledCount = allOrders
        .where((o) => o['status'] == AppConstants.orderStatusCancelled)
        .length;
    double totalSales = 0;
    for (final order in allOrders) {
      if (order['status'] == AppConstants.orderStatusDelivered) {
        totalSales += (order['total'] as num).toDouble();
      }
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayOrders = allOrders.where((o) {
      final ts = (o['createdAt'] as Timestamp?)?.toDate();
      if (ts == null) return false;
      return DateTime(ts.year, ts.month, ts.day).isAtSameMomentAs(today);
    }).length;
    return {
      'totalOrders': allOrders.length,
      'pendingOrders': pendingCount,
      'preparingOrders': preparingCount,
      'deliveringOrders': deliveringCount,
      'deliveredOrders': deliveredCount,
      'cancelledOrders': cancelledCount,
      'totalSales': totalSales,
      'todayOrders': todayOrders,
    };
  }

  /// 1️⃣9️⃣ إحصائيات مبيعات البائع
  Future<Map<String, dynamic>> getSellerSalesStatistics({String? timeRange}) async {
    final authService = AuthService();
    final sellerId = await authService.getCurrentUserId();
    if (sellerId == null) {
      throw Exception('المستخدم غير مسجّل الدخول');
    }
    final allOrders = await getSellerOrders();
    final completedOrders = allOrders
        .where((o) => o['status'] == AppConstants.orderStatusDelivered)
        .toList();

    DateTime startDate;
    final now = DateTime.now();
    switch (timeRange) {
      case 'week':
        startDate = DateTime(now.year, now.month, now.day - 7);
        break;
      case 'month':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'quarter':
        startDate = DateTime(now.year, now.month - 3, now.day);
        break;
      case 'year':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day - 30);
    }
    final filtered = completedOrders.where((o) {
      final ts = (o['createdAt'] as Timestamp?)?.toDate();
      return ts != null && ts.isAfter(startDate);
    }).toList();

    double totalSales = 0;
    for (final o in filtered) {
      totalSales += (o['total'] as num? ?? 0).toDouble();
    }
    double averageValue = filtered.isEmpty ? 0 : totalSales / filtered.length;

    final monthlySales = <String, double>{};
    final base = DateTime(now.year, now.month);
    for (int i = 0; i < 6; i++) {
      final m = DateTime(base.year, base.month - i);
      monthlySales['${m.month}-${m.year}'] = 0;
    }
    for (final o in filtered) {
      final ts = (o['createdAt'] as Timestamp?)?.toDate();
      if (ts != null) {
        final key = '${ts.month}-${ts.year}';
        monthlySales[key] = (monthlySales[key] ?? 0) + (o['total'] as num? ?? 0).toDouble();
      }
    }

    return {
      'totalSales': totalSales,
      'completedOrders': filtered.length,
      'averageOrderValue': averageValue,
      'monthlySales': monthlySales,
    };
  }

  /// 2️⃣0️⃣ إحصائيات منتجات البائع
  Future<Map<String, dynamic>> getSellerProductsStatistics({String? timeRange}) async {
    final authService = AuthService();
    final sellerId = await authService.getCurrentUserId();
    if (sellerId == null) {
      throw Exception('المستخدم غير مسجّل الدخول');
    }
    final allOrders = await getSellerOrders();
    final completedOrders = allOrders.where((o) => o['status'] == AppConstants.orderStatusDelivered).toList();

    DateTime startDate;
    final now = DateTime.now();
    switch (timeRange) {
      case 'week':
        startDate = DateTime(now.year, now.month, now.day - 7);
        break;
      case 'month':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'quarter':
        startDate = DateTime(now.year, now.month - 3, now.day);
        break;
      case 'year':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day - 30);
    }
    final filteredOrders = completedOrders.where((o) {
      final ts = (o['createdAt'] as Timestamp?)?.toDate();
      return ts != null && ts.isAfter(startDate);
    }).toList();

    final productSales = <String, int>{};
    final productRevenue = <String, double>{};

    for (final o in filteredOrders) {
      final items = o['items'] as List<dynamic>? ?? [];
      for (final item in items) {
        final pid = item['productId'] as String? ?? '';
        final qty = (item['quantity'] as num? ?? 0).toInt();
        final price = (item['price'] as num? ?? 0).toDouble();
        productSales[pid] = (productSales[pid] ?? 0) + qty;
        productRevenue[pid] = (productRevenue[pid] ?? 0) + (price * qty);
      }
    }

    final topProducts = productSales.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topRevenueProducts = productRevenue.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return {
      'totalProducts': productSales.length,
      'topProducts': topProducts.take(10).toList(),
      'topRevenueProducts': topRevenueProducts.take(10).toList(),
    };
  }

  /// 2️⃣1️⃣ إحصائيات عملاء البائع
  Future<Map<String, dynamic>> getSellerCustomersStatistics({String? timeRange}) async {
    final authService = AuthService();
    final sellerId = await authService.getCurrentUserId();
    if (sellerId == null) {
      throw Exception('المستخدم غير مسجّل الدخول');
    }
    final allOrders = await getSellerOrders();
    final completedOrders = allOrders.where((o) => o['status'] == AppConstants.orderStatusDelivered).toList();

    DateTime startDate;
    final now = DateTime.now();
    switch (timeRange) {
      case 'week':
        startDate = DateTime(now.year, now.month, now.day - 7);
        break;
      case 'month':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'quarter':
        startDate = DateTime(now.year, now.month - 3, now.day);
        break;
      case 'year':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day - 30);
    }
    final filteredOrders = completedOrders.where((o) {
      final ts = (o['createdAt'] as Timestamp?)?.toDate();
      return ts != null && ts.isAfter(startDate);
    }).toList();

    final customerOrders = <String, int>{};
    final customerSpending = <String, double>{};

    for (final o in filteredOrders) {
      final cid = o['customerId'] as String? ?? '';
      final total = (o['total'] as num? ?? 0).toDouble();
      customerOrders[cid] = (customerOrders[cid] ?? 0) + 1;
      customerSpending[cid] = (customerSpending[cid] ?? 0) + total;
    }

    final topCustomersByOrders = customerOrders.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCustomersBySpending = customerSpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'totalCustomers': customerOrders.length,
      'topCustomersByOrders': topCustomersByOrders.take(10).toList(),
      'topCustomersBySpending': topCustomersBySpending.take(10).toList(),
      'averageCustomerSpending': customerSpending.isEmpty
          ? 0
          : customerSpending.values.reduce((a, b) => a + b) /
              customerSpending.length,
    };
  }

  /// 2️⃣2️⃣ الاستماع لطلبيات جديدة في الوقت الحقيقي (Stream)
  Stream<QuerySnapshot> listenToNewOrders() {
    return _firestore
        .collection(AppConstants.ordersCollection)
        .where('status', isEqualTo: AppConstants.orderStatusPending)
        .snapshots();
  }
}

/// موفر حالة الخدمة (Riverpod)
final orderServiceProvider = Provider<OrderService>((ref) => OrderService());
