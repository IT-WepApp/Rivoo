import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_services/shared_services.dart';
import 'package:shared_models/shared_models.dart';
import 'package:firebase_auth/firebase_auth.dart';

final currentSellerIdProvider = Provider<String?>((ref) {
  return FirebaseAuth.instance.currentUser?.uid;
});

class OrdersNotifier extends StateNotifier<AsyncValue<List<OrderModel>>> {
  final OrderService _orderService;
  final String? _sellerId;

  OrdersNotifier(this._orderService, this._sellerId) : super(const AsyncLoading()) {
    if (_sellerId != null) {
      fetchOrders();
    } else {
      state = AsyncError('Seller ID not available', StackTrace.current);
    }
  }

  Future<void> fetchOrders() async {
    if (_sellerId == null) return;
    state = const AsyncLoading();
    try {
      final orders = await _orderService.getOrdersBySeller(_sellerId);
      state = AsyncData(orders);
    } catch (e, stacktrace) {
      log('Error fetching seller orders', error: e, stackTrace: stacktrace, name: 'SellerOrdersNotifier');
      state = AsyncError('Failed to fetch orders: $e', stacktrace);
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    final previousState = state;
    try {
      await _orderService.updateOrderStatus(orderId, status);
      await fetchOrders();
      return true;
    } catch (e, stacktrace) {
      log('Error updating order status by seller', error: e, stackTrace: stacktrace, name: 'SellerOrdersNotifier');
      state = AsyncError('Failed to update order status: $e', stacktrace);
      if (previousState is AsyncData) state = previousState;
      return false;
    }
  }
}

final sellerOrdersProvider = StateNotifierProvider.autoDispose<OrdersNotifier, AsyncValue<List<OrderModel>>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  final sellerId = ref.watch(currentSellerIdProvider);
  return OrdersNotifier(orderService, sellerId);
});
