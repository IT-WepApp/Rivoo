import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/services/services.dart'; // ✅ لاستيراد OrderService
import 'package:shared_libs/models/models.dart'; // ✅ لاستيراد OrderModel

// استخدام OrderModel بدلاً من Order
class OrderManagementNotifier
    extends StateNotifier<AsyncValue<List<OrderModel>>> {
  final OrderService _orderService;

  OrderManagementNotifier(this._orderService) : super(const AsyncLoading()) {
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    state = const AsyncLoading();
    try {
      final orders = await _orderService.getAllOrders();
      state = AsyncData(orders);
    } catch (e, stacktrace) {
      state = AsyncError('Failed to load orders: $e', stacktrace);
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    state = const AsyncLoading();
    try {
      await _orderService.updateOrderStatus(orderId, status);
      await fetchOrders();
    } catch (e, stacktrace) {
      state = AsyncError('Failed to update order status: $e', stacktrace);
    }
  }
}

// ✅ Provider للخدمة
final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

// ✅ Provider للـ Notifier
final orderManagementProvider = StateNotifierProvider<OrderManagementNotifier,
    AsyncValue<List<OrderModel>>>((ref) {
  final orderService = ref.read(orderServiceProvider);
  return OrderManagementNotifier(orderService);
});
