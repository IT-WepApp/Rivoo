import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import 'auth_service.dart';

/// خدمة إدارة الطلبات للبائعين
class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // الحصول على قائمة طلبات البائع
  Future<List<Map<String, dynamic>>> getSellerOrders() async {
    final authService = AuthService();
    final sellerId = await authService.getCurrentUserId();

    if (sellerId == null) {
      throw Exception('المستخدم غير مسجل الدخول');
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

  // الحصول على طلب محدد
  Future<Map<String, dynamic>?> getOrder(String orderId) async {
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
  
  // الحصول على تفاصيل طلب محدد
  Future<Map<String, dynamic>?> getOrderDetails(String orderId) async {
    return await getOrder(orderId);
  }

  // تحديث حالة الطلب
  Future<void> updateOrderStatus(String orderId, String status) async {
    final authService = AuthService();
    final sellerId = await authService.getCurrentUserId();

    if (sellerId == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    // التحقق من ملكية الطلب
    final order = await getOrder(orderId);
    if (order == null) {
      throw Exception('الطلب غير موجود');
    }

    if (order['sellerId'] != sellerId) {
      throw Exception('ليس لديك صلاحية تعديل هذا الطلب');
    }

    // تحديث حالة الطلب في Firestore
    await _firestore
        .collection(AppConstants.ordersCollection)
        .doc(orderId)
        .update({
      'status': status,
      'statusUpdatedAt': FieldValue.serverTimestamp(),
      'statusHistory': FieldValue.arrayUnion([
        {
          'status': status,
          'timestamp': FieldValue.serverTimestamp(),
        }
      ]),
    });
  }

  // الحصول على طلبات حسب الحالة
  Future<List<Map<String, dynamic>>> getOrdersByStatus(String status) async {
    final authService = AuthService();
    final sellerId = await authService.getCurrentUserId();

    if (sellerId == null) {
      throw Exception('المستخدم غير مسجل الدخول');
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

  // الحصول على الطلبات الجديدة
  Future<List<Map<String, dynamic>>> getNewOrders() async {
    return await getOrdersByStatus(AppConstants.orderStatusPending);
  }

  // الحصول على الطلبات قيد التحضير
  Future<List<Map<String, dynamic>>> getPreparingOrders() async {
    return await getOrdersByStatus(AppConstants.orderStatusPreparing);
  }

  // الحصول على الطلبات قيد التوصيل
  Future<List<Map<String, dynamic>>> getDeliveringOrders() async {
    return await getOrdersByStatus(AppConstants.orderStatusDelivering);
  }

  // الحصول على الطلبات المكتملة
  Future<List<Map<String, dynamic>>> getCompletedOrders() async {
    return await getOrdersByStatus(AppConstants.orderStatusDelivered);
  }

  // الحصول على الطلبات الملغاة
  Future<List<Map<String, dynamic>>> getCancelledOrders() async {
    return await getOrdersByStatus(AppConstants.orderStatusCancelled);
  }

  // البحث عن طلبات
  Future<List<Map<String, dynamic>>> searchOrders(String query) async {
    final authService = AuthService();
    final sellerId = await authService.getCurrentUserId();

    if (sellerId == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    // البحث في معرف الطلب واسم العميل
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

  // الحصول على إحصائيات الطلبات
  Future<Map<String, dynamic>> getOrderStatistics() async {
    final authService = AuthService();
    final sellerId = await authService.getCurrentUserId();

    if (sellerId == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    final allOrders = await getSellerOrders();

    // حساب عدد الطلبات حسب الحالة
    final pendingCount = allOrders
        .where((order) => order['status'] == AppConstants.orderStatusPending)
        .length;
    final preparingCount = allOrders
        .where((order) => order['status'] == AppConstants.orderStatusPreparing)
        .length;
    final deliveringCount = allOrders
        .where((order) => order['status'] == AppConstants.orderStatusDelivering)
        .length;
    final deliveredCount = allOrders
        .where((order) => order['status'] == AppConstants.orderStatusDelivered)
        .length;
    final cancelledCount = allOrders
        .where((order) => order['status'] == AppConstants.orderStatusCancelled)
        .length;

    // حساب إجمالي المبيعات
    double totalSales = 0;
    for (final order in allOrders) {
      if (order['status'] == AppConstants.orderStatusDelivered) {
        totalSales += (order['total'] as num).toDouble();
      }
    }

    // حساب عدد الطلبات اليومية
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayOrders = allOrders.where((order) {
      final createdAt = (order['createdAt'] as Timestamp?)?.toDate();
      if (createdAt == null) return false;
      final orderDate =
          DateTime(createdAt.year, createdAt.month, createdAt.day);
      return orderDate.isAtSameMomentAs(today);
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

  // الاستماع للطلبات الجديدة
  Stream<QuerySnapshot> listenToNewOrders() {
    final authService = AuthService();
    final sellerId = authService.getCurrentUserId();
    
    if (sellerId == null) {
      // إرجاع تدفق فارغ في حالة عدم وجود مستخدم
      return Stream.empty();
    }
    
    return _firestore
        .collection(AppConstants.ordersCollection)
        .where('sellerId', isEqualTo: sellerId)
        .where('status', isEqualTo: AppConstants.orderStatusPending)
        .snapshots();
  }
}

// مزود خدمة الطلبات
final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

// مزود قائمة طلبات البائع
final sellerOrdersProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final orderService = ref.watch(orderServiceProvider);
  return await orderService.getSellerOrders();
});

// مزود طلب محدد
final orderProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, orderId) async {
  final orderService = ref.watch(orderServiceProvider);
  return await orderService.getOrder(orderId);
});

// مزود الطلبات الجديدة
final newOrdersProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final orderService = ref.watch(orderServiceProvider);
  return await orderService.getNewOrders();
});

// مزود إحصائيات الطلبات
final orderStatisticsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final orderService = ref.watch(orderServiceProvider);
  return await orderService.getOrderStatistics();
});

// مزود الاستماع للطلبات الجديدة
final newOrdersStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.listenToNewOrders();
});
