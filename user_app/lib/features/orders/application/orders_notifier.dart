import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart'; 
import 'package:shared_services/shared_services.dart'; 
import 'dart:developer'; 
// Import userIdProvider from auth_notifier
import 'package:user_app/features/auth/application/auth_notifier.dart'; 

class OrdersNotifier extends StateNotifier<AsyncValue<List<OrderModel>>> {
  final OrderService _orderService;
  final String? _userId;

  OrdersNotifier(this._orderService, this._userId) : super(const AsyncLoading()) {
    if (_userId != null && _userId.isNotEmpty) {
      fetchOrders();
    } else {
      state = const AsyncData([]); 
    }
  }

  Future<void> fetchOrders({bool forceRefresh = false}) async {
    // Use local _userId passed in constructor
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
      log('Error fetching user orders', error: e, stackTrace: stacktrace, name: 'OrdersNotifier');
      state = AsyncError('Failed to fetch orders: $e', stacktrace);
    }
  }
}

final userOrdersProvider = StateNotifierProvider.autoDispose<OrdersNotifier, AsyncValue<List<OrderModel>>>((ref) {
  final orderService = ref.watch(orderServiceProvider); 
  final userId = ref.watch(userIdProvider); // Watch userIdProvider from auth_notifier
  return OrdersNotifier(orderService, userId);
});
