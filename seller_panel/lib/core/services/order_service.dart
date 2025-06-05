import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/constants/app_constants.dart';
import 'package:shared_libs/services/auth_service.dart';

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

  // الحصول على إحصائيات المبيعات للبائع
  Future<Map<String, dynamic>> getSellerSalesStatistics({String? timeRange}) async {
    final authService = AuthService();
    final sellerId = await authService.getCurrentUserId();

    if (sellerId == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    final allOrders = await getSellerOrders();
    final completedOrders = allOrders
        .where((order) => order['status'] == AppConstants.orderStatusDelivered)
        .toList();

    // تصفية الطلبات حسب النطاق الزمني إذا تم تحديده
    List<Map<String, dynamic>> filteredOrders = completedOrders;
    if (timeRange != null) {
      final now = DateTime.now();
      DateTime startDate;
      
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
          startDate = DateTime(now.year, now.month, now.day - 30); // افتراضي: آخر 30 يوم
      }
      
      filteredOrders = completedOrders.where((order) {
        final createdAt = (order['createdAt'] as Timestamp?)?.toDate();
        if (createdAt == null) return false;
        return createdAt.isAfter(startDate);
      }).toList();
    }

    // حساب إجمالي المبيعات
    double totalSales = 0;
    for (final order in filteredOrders) {
      totalSales += (order['total'] as num? ?? 0).toDouble();
    }

    // حساب متوسط قيمة الطلب
    double averageOrderValue = filteredOrders.isEmpty
        ? 0
        : totalSales / filteredOrders.length;

    // حساب المبيعات الشهرية
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final monthlySales = <String, double>{};

    for (int i = 0; i < 6; i++) {
      final month = DateTime(currentMonth.year, currentMonth.month - i);
      final monthKey = '${month.month}-${month.year}';
      monthlySales[monthKey] = 0;
    }

    for (final order in filteredOrders) {
      final createdAt = (order['createdAt'] as Timestamp?)?.toDate();
      if (createdAt != null) {
        final monthKey = '${createdAt.month}-${createdAt.year}';
        if (monthlySales.containsKey(monthKey)) {
          monthlySales[monthKey] = (monthlySales[monthKey] ?? 0) +
              (order['total'] as num? ?? 0).toDouble();
        }
      }
    }

    return {
      'totalSales': totalSales,
      'completedOrders': filteredOrders.length,
      'averageOrderValue': averageOrderValue,
      'monthlySales': monthlySales,
    };
  }

  // الحصول على إحصائيات المنتجات للبائع
  Future<Map<String, dynamic>> getSellerProductsStatistics({String? timeRange}) async {
    final authService = AuthService();
    final sellerId = await authService.getCurrentUserId();

    if (sellerId == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    final allOrders = await getSellerOrders();
    final completedOrders = allOrders
        .where((order) => order['status'] == AppConstants.orderStatusDelivered)
        .toList();

    // تصفية الطلبات حسب النطاق الزمني إذا تم تحديده
    List<Map<String, dynamic>> filteredOrders = completedOrders;
    if (timeRange != null) {
      final now = DateTime.now();
      DateTime startDate;
      
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
          startDate = DateTime(now.year, now.month, now.day - 30); // افتراضي: آخر 30 يوم
      }
      
      filteredOrders = completedOrders.where((order) {
        final createdAt = (order['createdAt'] as Timestamp?)?.toDate();
        if (createdAt == null) return false;
        return createdAt.isAfter(startDate);
      }).toList();
    }

    // حساب المنتجات الأكثر مبيعًا
    final productSales = <String, int>{};
    final productRevenue = <String, double>{};

    for (final order in filteredOrders) {
      final items = order['items'] as List<dynamic>? ?? [];
      for (final item in items) {
        final productId = item['productId'] as String? ?? '';
        final quantity = (item['quantity'] as num? ?? 0).toInt();
        final price = (item['price'] as num? ?? 0).toDouble();

        productSales[productId] = (productSales[productId] ?? 0) + quantity;
        productRevenue[productId] =
            (productRevenue[productId] ?? 0) + (price * quantity);
      }
    }

    // ترتيب المنتجات حسب المبيعات
    final topProducts = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // ترتيب المنتجات حسب الإيرادات
    final topRevenueProducts = productRevenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'totalProducts': productSales.length,
      'topProducts': topProducts.take(10).toList(),
      'topRevenueProducts': topRevenueProducts.take(10).toList(),
    };
  }

  // الحصول على إحصائيات العملاء للبائع
  Future<Map<String, dynamic>> getSellerCustomersStatistics({String? timeRange}) async {
    final authService = AuthService();
    final sellerId = await authService.getCurrentUserId();

    if (sellerId == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    final allOrders = await getSellerOrders();
    final completedOrders = allOrders
        .where((order) => order['status'] == AppConstants.orderStatusDelivered)
        .toList();

    // تصفية الطلبات حسب النطاق الزمني إذا تم تحديده
    List<Map<String, dynamic>> filteredOrders = completedOrders;
    if (timeRange != null) {
      final now = DateTime.now();
      DateTime startDate;
      
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
          startDate = DateTime(now.year, now.month, now.day - 30); // افتراضي: آخر 30 يوم
      }
      
      filteredOrders = completedOrders.where((order) {
        final createdAt = (order['createdAt'] as Timestamp?)?.toDate();
        if (createdAt == null) return false;
        return createdAt.isAfter(startDate);
      }).toList();
    }

    // حساب العملاء الأكثر شراءً
    final customerOrders = <String, int>{};
    final customerSpending = <String, double>{};

    for (final order in filteredOrders) {
      final customerId = order['customerId'] as String? ?? '';
      final total = (order['total'] as num? ?? 0).toDouble();

      customerOrders[customerId] = (customerOrders[customerId] ?? 0) + 1;
      customerSpending[customerId] =
          (customerSpending[customerId] ?? 0) + total;
    }

    // ترتيب العملاء حسب عدد الطلبات
    final topCustomersByOrders = customerOrders.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // ترتيب العملاء حسب الإنفاق
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

  // الاستماع للطلبات الجديدة
  Stream<QuerySnapshot> listenToNewOrders() async* {
    final authService = AuthService();
    final sellerId = await authService.getCurrentUserId();

    if (sellerId == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    yield* _firestore
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
