import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/lib/services/firestore_service.dart';
import 'package:shared_libs/lib/models/order.dart';

/// نموذج حالة الطلبات
class OrdersState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;

  OrdersState({
    required this.orders,
    this.isLoading = false,
    this.error,
  });

  /// نسخة أولية من الحالة
  factory OrdersState.initial() {
    return OrdersState(orders: []);
  }

  /// نسخة من الحالة مع تحميل
  OrdersState copyWithLoading() {
    return OrdersState(
      orders: orders,
      isLoading: true,
      error: null,
    );
  }

  /// نسخة من الحالة مع خطأ
  OrdersState copyWithError(String errorMessage) {
    return OrdersState(
      orders: orders,
      isLoading: false,
      error: errorMessage,
    );
  }

  /// نسخة من الحالة مع طلبات جديدة
  OrdersState copyWithOrders(List<Order> newOrders) {
    return OrdersState(
      orders: newOrders,
      isLoading: false,
      error: null,
    );
  }
}

/// مزود حالة الطلبات
final ordersProvider =
    StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return OrdersNotifier(firestoreService);
});

/// مزود طلب واحد بناءً على المعرف
final orderProvider = Provider.family<Order?, String>((ref, id) {
  final orders = ref.watch(ordersProvider).orders;
  return orders.firstWhere((order) => order.id == id, orElse: () => null);
});

/// مدير حالة الطلبات
class OrdersNotifier extends StateNotifier<OrdersState> {
  final FirestoreService _firestoreService;

  OrdersNotifier(this._firestoreService) : super(OrdersState.initial());

  /// جلب طلبات المستخدم
  Future<void> fetchUserOrders(String userId) async {
    state = state.copyWithLoading();

    try {
      final orders = await _firestoreService.getUserOrders(userId);
      state = state.copyWithOrders(orders);
    } catch (e) {
      state = state.copyWithError(e.toString());
    }
  }

  /// جلب طلبات المتجر
  Future<void> fetchStoreOrders(String storeId) async {
    state = state.copyWithLoading();

    try {
      final orders = await _firestoreService.getStoreOrders(storeId);
      state = state.copyWithOrders(orders);
    } catch (e) {
      state = state.copyWithError(e.toString());
    }
  }

  /// جلب طلبات التوصيل
  Future<void> fetchDeliveryOrders(String deliveryPersonId) async {
    state = state.copyWithLoading();

    try {
      final orders =
          await _firestoreService.getDeliveryOrders(deliveryPersonId);
      state = state.copyWithOrders(orders);
    } catch (e) {
      state = state.copyWithError(e.toString());
    }
  }

  /// تحديث حالة الطلب
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestoreService.updateOrderStatus(orderId, status);

      final updatedOrders = state.orders.map((order) {
        if (order.id == orderId) {
          return order.copyWith(status: status);
        }
        return order;
      }).toList();

      state = state.copyWithOrders(updatedOrders);
    } catch (e) {
      state = state.copyWithError(e.toString());
    }
  }

  /// إنشاء طلب جديد
  Future<String?> createOrder(Order order) async {
    state = state.copyWithLoading();

    try {
      final orderId = await _firestoreService.createOrder(order);

      if (orderId != null) {
        final newOrder = order.copyWith(id: orderId);
        final updatedOrders = [...state.orders, newOrder];
        state = state.copyWithOrders(updatedOrders);
      }

      return orderId;
    } catch (e) {
      state = state.copyWithError(e.toString());
      return null;
    }
  }
}
