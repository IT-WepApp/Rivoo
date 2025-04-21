import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart'; // Import OrderModel
import 'package:shared_services/shared_services.dart'; // Import OrderService and orderServiceProvider

// Define the state for Order History
class OrderHistoryState {
  final List<OrderModel> orders;
  final bool isLoading;
  final String? sortBy;
  final String? sortOrder;
  final String? filterByStatus;
  final String? error;

  OrderHistoryState({
    this.orders = const [],
    this.isLoading = false,
    this.sortBy, // Added sortBy
    this.sortOrder, // Added sortOrder
    this.filterByStatus, // Added filterByStatus
    this.error,
  });

  OrderHistoryState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    String? sortBy,
    String? sortOrder,
    String? filterByStatus,
    // Allow clearing the error by passing null
    String? error,
    bool clearError = false, // Optional flag to explicitly clear error
  }) {
    return OrderHistoryState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      filterByStatus: filterByStatus ?? this.filterByStatus,
      // If clearError is true, set error to null, otherwise use provided error or existing one.
      error: clearError ? null : error ?? this.error,
    );
  }
}

class OrderHistoryNotifier extends StateNotifier<OrderHistoryState> {
  final OrderService _orderService;

  OrderHistoryNotifier(this._orderService) : super(OrderHistoryState());

  Future<void> loadOrderHistory(
    String deliveryPersonnelId, {
    String? sortBy,
    String? sortOrder,
    String? filterByStatus,
  }) async {
    state = state.copyWith(
      isLoading: true,
      // Clear previous error when loading
      clearError: true,
      sortBy: sortBy,
      sortOrder: sortOrder,
      filterByStatus: filterByStatus,
    );
    try {
      // Assume getDeliveredOrdersForPersonnel exists and returns List<OrderModel>
      final orders = await _orderService.getDeliveredOrdersForPersonnel(
        deliveryPersonnelId,
        sortBy: sortBy,
        sortOrder: sortOrder,
        filterByStatus: filterByStatus,
      );
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Failed to load order history: $e');
    }
  }
}

// Provide the notifier using a StateNotifierProvider
final orderHistoryNotifierProvider =
    StateNotifierProvider.autoDispose<OrderHistoryNotifier, OrderHistoryState>(
        (ref) {
  final orderService = ref.watch(orderServiceProvider); // Use imported provider
  return OrderHistoryNotifier(orderService);
});

// Removed the example comment as the provider should come from shared_services
