import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/services/order_service_provider.dart';
import 'package:shared_libs/services/services.dart';
import 'package:shared_libs/models/models.dart';
import 'package:firebase_auth/firebase_auth.dart';

final currentSellerIdProvider = Provider<String?>((ref) {
  return FirebaseAuth.instance.currentUser?.uid;
});

class OrdersNotifier extends StateNotifier<AsyncValue<List<OrderModel>>> {
  final OrderService _orderService;
  final String? _sellerId;

  OrdersNotifier(this._orderService, this._sellerId)
      : super(const AsyncLoading()) {
    if (_sellerId != null) {
      fetchOrders();
    } else {
      state = AsyncError('معرف البائع غير متوفر', StackTrace.current);
    }
  }

  Future<void> fetchOrders() async {
    if (_sellerId == null) return;
    state = const AsyncLoading();
    try {
      final orders = await _orderService.getOrdersBySeller(_sellerId);
      state = AsyncData(orders);
    } catch (e, stacktrace) {
      log('خطأ في جلب طلبات البائع',
          error: e, stackTrace: stacktrace, name: 'SellerOrdersNotifier');
      state = AsyncError('فشل في جلب الطلبات: $e', stacktrace);
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    final previousState = state;
    try {
      await _orderService.updateOrderStatus(orderId, status);
      await fetchOrders();
      return true;
    } catch (e, stacktrace) {
      log('خطأ في تحديث حالة الطلب بواسطة البائع',
          error: e, stackTrace: stacktrace, name: 'SellerOrdersNotifier');
      state = AsyncError('فشل في تحديث حالة الطلب: $e', stacktrace);
      if (previousState is AsyncData) state = previousState;
      return false;
    }
  }
}

final sellerOrdersProvider = StateNotifierProvider.autoDispose<OrdersNotifier,
    AsyncValue<List<OrderModel>>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  final sellerId = ref.watch(currentSellerIdProvider);
  return OrdersNotifier(orderService, sellerId);
});
