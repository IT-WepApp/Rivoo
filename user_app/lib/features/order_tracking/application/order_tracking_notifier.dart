import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_services/shared_services.dart';
import 'package:shared_models/shared_models.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

// نموذج موقع المندوب
class DeliveryLocationModel {
  final double latitude;
  final double longitude;
  final double? heading;
  final double? speed;
  final DateTime timestamp;

  DeliveryLocationModel({
    required this.latitude,
    required this.longitude,
    this.heading,
    this.speed,
    required this.timestamp,
  });

  factory DeliveryLocationModel.fromMap(Map<String, dynamic> map) {
    return DeliveryLocationModel(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      heading: map['heading'] != null ? (map['heading'] as num).toDouble() : null,
      speed: map['speed'] != null ? (map['speed'] as num).toDouble() : null,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  LocationData toLocationData() {
    return LocationData.fromMap({
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading,
      'speed': speed,
      'time': timestamp.millisecondsSinceEpoch.toDouble(),
    });
  }
}

// حالة تتبع الطلب
class OrderTrackingState {
  final AsyncValue<OrderModel?> orderData;
  final AsyncValue<LocationData?> deliveryLocation;
  final AsyncValue<List<LocationData>> locationHistory;
  final bool isLoading;
  final String? error;

  OrderTrackingState({
    this.orderData = const AsyncLoading(),
    this.deliveryLocation = const AsyncLoading(),
    this.locationHistory = const AsyncData([]),
    this.isLoading = false,
    this.error,
  });

  OrderTrackingState copyWith({
    AsyncValue<OrderModel?>? orderData,
    AsyncValue<LocationData?>? deliveryLocation,
    AsyncValue<List<LocationData>>? locationHistory,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return OrderTrackingState(
      orderData: orderData ?? this.orderData,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      locationHistory: locationHistory ?? this.locationHistory,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

// مدير حالة تتبع الطلب
class OrderTrackingNotifier extends StateNotifier<OrderTrackingState> {
  final OrderService _orderService;
  final FirebaseFirestore _firestore;
  final String _orderId;
  StreamSubscription? _orderSubscription;
  StreamSubscription? _locationSubscription;
  final Location _location = Location();
  final List<LocationData> _locationHistoryList = [];

  OrderTrackingNotifier(this._orderService, this._firestore, this._orderId) : super(OrderTrackingState()) {
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    state = state.copyWith(isLoading: true, orderData: const AsyncLoading());
    try {
      _orderSubscription?.cancel();
      _orderSubscription = _orderService.getOrderStream(_orderId).listen((order) {
        state = state.copyWith(orderData: AsyncData(order), isLoading: false);
        
        if (order?.deliveryId != null && 
            (order?.status == 'out_for_delivery' || order?.status == 'shipped')) {
          _trackDeliveryLocation(order!.deliveryId!);
        } else {
          // إيقاف تتبع المندوب إذا تم تسليم الطلب أو إلغاؤه
          _locationSubscription?.cancel();
          state = state.copyWith(
            deliveryLocation: const AsyncData(null),
          );
        }
      }, onError: (error, stackTrace) {
        log('Error fetching order stream', error: error, stackTrace: stackTrace, name: 'OrderTrackingNotifier');
        state = state.copyWith(orderData: AsyncError(error, stackTrace), isLoading: false);
      });
    } catch (e, stackTrace) {
      log('Error setting up order stream', error: e, stackTrace: stackTrace, name: 'OrderTrackingNotifier');
      state = state.copyWith(orderData: AsyncError(e, stackTrace), isLoading: false);
    }
  }

  // تتبع موقع المندوب في الوقت الفعلي
  Future<void> _trackDeliveryLocation(String deliveryPersonId) async {
    // التأكد من تفعيل خدمة الموقع والأذونات
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
    
    // إلغاء الاشتراك السابق إن وجد
    _locationSubscription?.cancel();
    
    state = state.copyWith(deliveryLocation: const AsyncLoading());
    
    // الاشتراك في تحديثات موقع المندوب من Firestore
    _locationSubscription = _firestore
        .collection('delivery_locations')
        .doc(deliveryPersonId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        try {
          final locationData = DeliveryLocationModel.fromMap(snapshot.data()!).toLocationData();
          
          // إضافة الموقع الجديد إلى سجل المواقع
          _locationHistoryList.add(locationData);
          if (_locationHistoryList.length > 20) {
            _locationHistoryList.removeAt(0); // الاحتفاظ بآخر 20 موقع فقط
          }
          
          state = state.copyWith(
            deliveryLocation: AsyncData(locationData),
            locationHistory: AsyncData(_locationHistoryList),
          );
        } catch (e, stackTrace) {
          log('Error parsing location data', error: e, stackTrace: stackTrace, name: 'OrderTrackingNotifier');
          state = state.copyWith(
            deliveryLocation: AsyncError('Failed to parse location data: $e', stackTrace),
          );
        }
      } else {
        // إذا لم يتم العثور على بيانات الموقع، استخدم محاكاة للاختبار
        _simulateLocationUpdates(deliveryPersonId);
      }
    }, onError: (error, stackTrace) {
      log('Error in location stream', error: error, stackTrace: stackTrace, name: 'OrderTrackingNotifier');
      state = state.copyWith(
        deliveryLocation: AsyncError('Error tracking delivery location: $error', stackTrace),
      );
      
      // في حالة الخطأ، استخدم محاكاة للاختبار
      _simulateLocationUpdates(deliveryPersonId);
    });
  }

  // محاكاة تحديثات الموقع للاختبار
  void _simulateLocationUpdates(String deliveryPersonId) {
    log("Simulating location tracking for $deliveryPersonId", name: 'OrderTrackingNotifier');
    
    // إلغاء الاشتراك السابق إن وجد
    _locationSubscription?.cancel();
    
    // محاكاة تحديثات الموقع كل 3 ثوانٍ
    _locationSubscription = Stream.periodic(const Duration(seconds: 3)).listen((_) {
      // إنشاء موقع عشوائي قريب من الموقع الحالي
      final LocationData locationData = _generateRandomLocation();
      
      // إضافة الموقع الجديد إلى سجل المواقع
      _locationHistoryList.add(locationData);
      if (_locationHistoryList.length > 20) {
        _locationHistoryList.removeAt(0); // الاحتفاظ بآخر 20 موقع فقط
      }
      
      state = state.copyWith(
        deliveryLocation: AsyncData(locationData),
        locationHistory: AsyncData(_locationHistoryList),
      );
    });
  }

  // إنشاء موقع عشوائي للمحاكاة
  LocationData _generateRandomLocation() {
    // استخدام الموقع السابق إن وجد، وإلا استخدم موقع افتراضي
    final previousLocation = state.deliveryLocation.whenOrNull(
      data: (loc) => loc,
    );
    
    // إنشاء موقع عشوائي قريب من الموقع السابق
    final latitude = previousLocation?.latitude ?? 24.7136;
    final longitude = previousLocation?.longitude ?? 46.6753;
    
    // إضافة تغيير صغير للموقع لمحاكاة الحركة
    final newLatitude = latitude + (DateTime.now().millisecondsSinceEpoch % 10 - 5) * 0.0001;
    final newLongitude = longitude + (DateTime.now().millisecondsSinceEpoch % 10 - 5) * 0.0001;
    
    return LocationData.fromMap({
      'latitude': newLatitude,
      'longitude': newLongitude,
      'heading': (DateTime.now().millisecondsSinceEpoch % 360).toDouble(),
      'speed': 30.0, // سرعة ثابتة للمحاكاة (كم/ساعة)
      'time': DateTime.now().millisecondsSinceEpoch.toDouble(),
    });
  }

  // حساب المسافة المتبقية والوقت المتوقع للوصول
  Map<String, dynamic> calculateETA(LocationData deliveryLocation, LocationData destinationLocation) {
    // حساب المسافة بين موقعين باستخدام صيغة هافرساين
    const double earthRadius = 6371; // نصف قطر الأرض بالكيلومتر
    final double lat1 = deliveryLocation.latitude! * (3.14159 / 180);
    final double lon1 = deliveryLocation.longitude! * (3.14159 / 180);
    final double lat2 = destinationLocation.latitude! * (3.14159 / 180);
    final double lon2 = destinationLocation.longitude! * (3.14159 / 180);
    
    final double dlon = lon2 - lon1;
    final double dlat = lat2 - lat1;
    final double a = (dlat / 2).sin() * (dlat / 2).sin() +
        lat1.cos() * lat2.cos() * (dlon / 2).sin() * (dlon / 2).sin();
    final double c = 2 * a.sqrt().atan2((1 - a).sqrt());
    final double distance = earthRadius * c;
    
    // حساب الوقت المتوقع بناءً على السرعة
    final double speed = deliveryLocation.speed ?? 30; // كم/ساعة
    final double timeInHours = distance / speed;
    final int timeInMinutes = (timeInHours * 60).round();
    
    return {
      'distance': distance,
      'time': timeInMinutes,
    };
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    _locationSubscription?.cancel();
    super.dispose();
  }
}

// مزود لخدمة تتبع الطلب
final orderTrackingProvider = StateNotifierProvider.autoDispose.family<
    OrderTrackingNotifier,
    OrderTrackingState,
    String>((ref, orderId) {
  final orderService = ref.watch(orderServiceProvider);
  final firestore = FirebaseFirestore.instance;
  return OrderTrackingNotifier(orderService, firestore, orderId);
});
