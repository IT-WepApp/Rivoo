import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/architecture/domain/failure.dart';
import '../../../../core/architecture/presentation/base_view_model.dart';
import '../domain/entities/order.dart';
import '../domain/usecases/order_usecases.dart';
import '../data/repositories/order_repository_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class OrderViewModel extends BaseViewModel {
  final GetUserOrdersUseCase _getUserOrdersUseCase;
  final GetOrderDetailsUseCase _getOrderDetailsUseCase;
  final CreateOrderUseCase _createOrderUseCase;
  final CancelOrderUseCase _cancelOrderUseCase;
  final TrackOrderUseCase _trackOrderUseCase;
  final UpdateShippingAddressUseCase _updateShippingAddressUseCase;

  OrderViewModel({
    required GetUserOrdersUseCase getUserOrdersUseCase,
    required GetOrderDetailsUseCase getOrderDetailsUseCase,
    required CreateOrderUseCase createOrderUseCase,
    required CancelOrderUseCase cancelOrderUseCase,
    required TrackOrderUseCase trackOrderUseCase,
    required UpdateShippingAddressUseCase updateShippingAddressUseCase,
  })  : _getUserOrdersUseCase = getUserOrdersUseCase,
        _getOrderDetailsUseCase = getOrderDetailsUseCase,
        _createOrderUseCase = createOrderUseCase,
        _cancelOrderUseCase = cancelOrderUseCase,
        _trackOrderUseCase = trackOrderUseCase,
        _updateShippingAddressUseCase = updateShippingAddressUseCase,
        super();

  List<Order> _orders = [];
  List<Order> get orders => _orders;

  Order? _selectedOrder;
  Order? get selectedOrder => _selectedOrder;

  String? _trackingInfo;
  String? get trackingInfo => _trackingInfo;

  Future<void> loadUserOrders() async {
    setLoading(true);
    final result = await _getUserOrdersUseCase(NoParams());
    result.fold(
      (failure) => setError(failure.message),
      (orders) {
        _orders = orders;
        setLoading(false);
      },
    );
  }

  Future<void> getOrderDetails(String orderId) async {
    setLoading(true);
    final result = await _getOrderDetailsUseCase(orderId);
    result.fold(
      (failure) => setError(failure.message),
      (order) {
        _selectedOrder = order;
        setLoading(false);
      },
    );
  }

  Future<void> createOrder({
    required List<OrderItem> items,
    required double totalAmount,
    required String shippingAddress,
    required String paymentMethod,
  }) async {
    setLoading(true);
    final params = CreateOrderParams(
      items: items,
      totalAmount: totalAmount,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
    );
    final result = await _createOrderUseCase(params);
    result.fold(
      (failure) => setError(failure.message),
      (order) {
        _selectedOrder = order;
        loadUserOrders();
      },
    );
  }

  Future<void> cancelOrder(String orderId) async {
    setLoading(true);
    final result = await _cancelOrderUseCase(orderId);
    result.fold(
      (failure) => setError(failure.message),
      (_) {
        loadUserOrders();
        if (_selectedOrder != null && _selectedOrder!.id == orderId) {
          getOrderDetails(orderId);
        }
      },
    );
  }

  Future<void> trackOrder(String orderId) async {
    setLoading(true);
    final result = await _trackOrderUseCase(orderId);
    result.fold(
      (failure) => setError(failure.message),
      (trackingInfo) {
        _trackingInfo = trackingInfo;
        setLoading(false);
      },
    );
  }

  Future<void> updateShippingAddress(String orderId, String newAddress) async {
    setLoading(true);
    final params = UpdateShippingAddressParams(
      orderId: orderId,
      newAddress: newAddress,
    );
    final result = await _updateShippingAddressUseCase(params);
    result.fold(
      (failure) => setError(failure.message),
      (_) {
        if (_selectedOrder != null && _selectedOrder!.id == orderId) {
          getOrderDetails(orderId);
        } else {
          loadUserOrders();
        }
      },
    );
  }
}

// Providers
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    uuid: const Uuid(),
  );
});

final getUserOrdersUseCaseProvider = Provider<GetUserOrdersUseCase>((ref) {
  return GetUserOrdersUseCase(ref.watch(orderRepositoryProvider));
});

final getOrderDetailsUseCaseProvider = Provider<GetOrderDetailsUseCase>((ref) {
  return GetOrderDetailsUseCase(ref.watch(orderRepositoryProvider));
});

final createOrderUseCaseProvider = Provider<CreateOrderUseCase>((ref) {
  return CreateOrderUseCase(ref.watch(orderRepositoryProvider));
});

final cancelOrderUseCaseProvider = Provider<CancelOrderUseCase>((ref) {
  return CancelOrderUseCase(ref.watch(orderRepositoryProvider));
});

final trackOrderUseCaseProvider = Provider<TrackOrderUseCase>((ref) {
  return TrackOrderUseCase(ref.watch(orderRepositoryProvider));
});

final updateShippingAddressUseCaseProvider =
    Provider<UpdateShippingAddressUseCase>((ref) {
  return UpdateShippingAddressUseCase(ref.watch(orderRepositoryProvider));
});

final orderViewModelProvider = ChangeNotifierProvider<OrderViewModel>((ref) {
  return OrderViewModel(
    getUserOrdersUseCase: ref.watch(getUserOrdersUseCaseProvider),
    getOrderDetailsUseCase: ref.watch(getOrderDetailsUseCaseProvider),
    createOrderUseCase: ref.watch(createOrderUseCaseProvider),
    cancelOrderUseCase: ref.watch(cancelOrderUseCaseProvider),
    trackOrderUseCase: ref.watch(trackOrderUseCaseProvider),
    updateShippingAddressUseCase:
        ref.watch(updateShippingAddressUseCaseProvider),
  );
});
