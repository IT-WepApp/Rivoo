import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_services/shared_services.dart'; // Import shared services
import 'package:shared_models/shared_models.dart'; // Import shared models
import 'package:location/location.dart'; // Import location package
import 'dart:developer'; // Import log

// State for Order Tracking
class OrderTrackingState {
  final AsyncValue<OrderModel?> orderData;
  final AsyncValue<LocationData?> deliveryLocation;
  final bool isLoading;
  final String? error;

  OrderTrackingState({
    this.orderData = const AsyncLoading(),
    this.deliveryLocation = const AsyncLoading(),
    this.isLoading = false,
    this.error,
  });

  OrderTrackingState copyWith({
    AsyncValue<OrderModel?>? orderData,
    AsyncValue<LocationData?>? deliveryLocation,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return OrderTrackingState(
      orderData: orderData ?? this.orderData,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

// Notifier for Order Tracking
class OrderTrackingNotifier extends StateNotifier<OrderTrackingState> {
  final OrderService _orderService;
  final String _orderId;
  StreamSubscription? _orderSubscription;
  StreamSubscription? _locationSubscription;
  final Location _location = Location(); // Location service instance

  OrderTrackingNotifier(this._orderService, this._orderId) : super(OrderTrackingState()) {
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    state = state.copyWith(isLoading: true, orderData: const AsyncLoading());
    try {
      _orderSubscription?.cancel(); // Cancel previous subscription
      _orderSubscription = _orderService.getOrderStream(_orderId).listen((order) {
        // mounted check removed
           state = state.copyWith(orderData: AsyncData(order), isLoading: false);
           // Potentially start tracking location based on order status/delivery person
           if (order?.deliveryId != null && order?.status == 'out_for_delivery') {
              _trackDeliveryLocation(order!.deliveryId!); 
           }
      }, onError: (error, stackTrace) { 
        log('Error fetching order stream', error: error, stackTrace: stackTrace, name: 'OrderTrackingNotifier');
         // mounted check removed
           state = state.copyWith(orderData: AsyncError(error, stackTrace), isLoading: false);
      });
    } catch (e, stackTrace) { 
      log('Error setting up order stream', error: e, stackTrace: stackTrace, name: 'OrderTrackingNotifier');
       // mounted check removed
         state = state.copyWith(orderData: AsyncError(e, stackTrace), isLoading: false);
    }
  }

  // Placeholder for tracking delivery person's location
  Future<void> _trackDeliveryLocation(String deliveryPersonId) async {
     // Ensure location permissions are granted
     bool serviceEnabled = await _location.serviceEnabled();
     if (!serviceEnabled) {
       serviceEnabled = await _location.requestService();
       if (!serviceEnabled) {
         state = state.copyWith(deliveryLocation: const AsyncError('Location service disabled', StackTrace.empty));
         return;
       }
     }

     PermissionStatus permissionGranted = await _location.hasPermission();
     if (permissionGranted == PermissionStatus.denied) {
       permissionGranted = await _location.requestPermission();
       if (permissionGranted != PermissionStatus.granted) {
          state = state.copyWith(deliveryLocation: const AsyncError('Location permission denied', StackTrace.empty));
         return;
       }
     }
     
    // Replace with actual stream from Firestore listening to delivery person's location
    log("Simulating location tracking for $deliveryPersonId");
    state = state.copyWith(deliveryLocation: const AsyncLoading());
    
    // Simulating receiving a location update after a delay
    await Future.delayed(const Duration(seconds: 2)); 
    // mounted check removed
      // Replace with actual LocationData from Firestore stream for delivery person
      // Ensure LocationData.fromMap is handled correctly (might need manual mapping)
      try {
        state = state.copyWith(deliveryLocation: AsyncData(LocationData.fromMap({'latitude': 37.42, 'longitude': -122.08}))); 
      } catch (e) {
         state = state.copyWith(deliveryLocation: AsyncError('Failed to parse location data', StackTrace.current));
      }
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    _locationSubscription?.cancel();
    super.dispose();
  }
}

// Provider definition
final orderTrackingProvider = StateNotifierProvider.autoDispose.family<
    OrderTrackingNotifier,
    OrderTrackingState,
    String // Order ID as the family parameter
    >((ref, orderId) {
  final orderService = ref.watch(orderServiceProvider);
  return OrderTrackingNotifier(orderService, orderId);
});
