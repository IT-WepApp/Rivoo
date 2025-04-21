import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer';
// Import userIdProvider from auth_notifier
import 'package:user_app/features/auth/application/auth_notifier.dart';

// تعريف نموذج الطلب المبسط للاستخدام المحلي
class OrderModel {
  final String id;
  final String userId;
  final String status;
  final double totalAmount;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.items,
  });
}

// تعريف نموذج عنصر الطلب المبسط
class OrderItemModel {
  final String id;
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });
}

// واجهة خدمة الطلبات
abstract class OrderService {
  Future<List<OrderModel>> getOrdersByUser(String userId);
}

// تنفيذ خدمة الطلبات
class OrderServiceImpl implements OrderService {
  @override
  Future<List<OrderModel>> getOrdersByUser(String userId) async {
    // هذا تنفيذ مبسط، في التطبيق الحقيقي سيتم استدعاء API أو Firestore
    await Future.delayed(const Duration(seconds: 1)); // محاكاة تأخير الشبكة
    return []; // إرجاع قائمة فارغة للتبسيط
  }
}

// مزود خدمة الطلبات
final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderServiceImpl();
});

class OrdersNotifier extends Notifier<AsyncValue<List<OrderModel>>> {
  late final OrderService _orderService;
  late final String? _userId;

  @override
  AsyncValue<List<OrderModel>> build() {
    _orderService = ref.watch(orderServiceProvider);
    _userId = ref.watch(userIdProvider);
    
    // تأجيل جلب الطلبات إلى ما بعد بناء الحالة الأولية
    Future.microtask(() {
      if (_userId != null && _userId!.isNotEmpty) {
        fetchOrders();
      } else {
        state = const AsyncData([]);
      }
    });
    
    return const AsyncLoading();
  }

  Future<void> fetchOrders({bool forceRefresh = false}) async {
    // استخدام _userId المحلي الذي تم تمريره في المنشئ
    final currentUserId = _userId;
    if (currentUserId == null || currentUserId.isEmpty) {
      state = const AsyncData([]);
      return;
    }

    if (!forceRefresh && state is AsyncData && state.hasValue) {
      return;
    }

    state = const AsyncLoading();
    try {
      final orders = await _orderService.getOrdersByUser(currentUserId);

      orders.sort((a, b) {
        final dateA = a.createdAt;
        final dateB = b.createdAt;
        return dateB.compareTo(dateA);
      });

      state = AsyncData(orders);
    } catch (e, stacktrace) {
      log('Error fetching user orders',
          error: e, stackTrace: stacktrace, name: 'OrdersNotifier');
      state = AsyncError('Failed to fetch orders: $e', stacktrace);
    }
  }
}

final userOrdersProvider = NotifierProvider.autoDispose<OrdersNotifier,
    AsyncValue<List<OrderModel>>>(() {
  return OrdersNotifier();
});
