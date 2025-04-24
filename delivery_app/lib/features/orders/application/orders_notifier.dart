import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../shared_libs/lib/models/models.dart'; // يحتوي على OrderModel
import '../../../../../../shared_libs/lib/services/services.dart'; // يحتوي على OrderService

// مزود وهمي مؤقت لتجربة الـ deliveryPersonId
final currentDeliveryPersonIdProvider = Provider<String?>((ref) {
  // يفترض أن ترجع الـ ID من مصدر حقيقي مثل shared preferences أو auth
  return "123"; // قم بتغييرها حسب حالتك
});

class OrdersNotifier extends StateNotifier<AsyncValue<List<OrderModel>>> {
  final OrderService _orderService;
  final String? _deliveryPersonId;

  OrdersNotifier(this._orderService, this._deliveryPersonId)
      : super(const AsyncLoading()) {
    if (_deliveryPersonId != null) {
      fetchAssignedOrders();
    } else {
      state = AsyncError('User ID not available', StackTrace.current);
    }
  }

  Future<void> fetchAssignedOrders() async {
    if (_deliveryPersonId == null) return;
    state = const AsyncLoading();
    try {
      final allOrders = await _orderService.getAllOrders();
      final assignedOrders = allOrders
          .where((o) =>
              o.deliveryId == _deliveryPersonId &&
              (o.status == 'processing' || o.status == 'shipped'))
          .toList();

      state = AsyncData(assignedOrders);
    } catch (e, stacktrace) {
      state = AsyncError('Failed to fetch assigned orders: $e', stacktrace);
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    final previousState = state;
    try {
      await _orderService.updateOrderStatus(orderId, status);
      await fetchAssignedOrders();
      return true;
    } catch (e, stacktrace) {
      state = AsyncError('Failed to update order status: $e', stacktrace);
      if (previousState is AsyncData) state = previousState;
      return false;
    }
  }
}

final ordersProvider = StateNotifierProvider.autoDispose<OrdersNotifier,
    AsyncValue<List<OrderModel>>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  final deliveryPersonId = ref.watch(currentDeliveryPersonIdProvider);

  return OrdersNotifier(orderService, deliveryPersonId);
});
