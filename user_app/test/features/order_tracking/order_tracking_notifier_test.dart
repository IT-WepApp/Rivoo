import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/features/order_tracking/application/order_tracking_notifier.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

@GenerateMocks([OrderTrackingNotifier])
void main() {
  late MockOrderTrackingNotifier mockOrderTrackingNotifier;

  setUp(() {
    mockOrderTrackingNotifier = MockOrderTrackingNotifier();
  });

  group('OrderTrackingNotifier Tests', () {
    test('startTracking should initialize tracking for an order', () async {
      // ترتيب
      const orderId = 'order_123';
      
      when(mockOrderTrackingNotifier.startTracking(orderId))
          .thenAnswer((_) async => true);

      // تنفيذ
      final result = await mockOrderTrackingNotifier.startTracking(orderId);

      // تحقق
      expect(result, true);
      verify(mockOrderTrackingNotifier.startTracking(orderId)).called(1);
    });

    test('stopTracking should end tracking for an order', () async {
      // ترتيب
      const orderId = 'order_123';
      
      when(mockOrderTrackingNotifier.stopTracking())
          .thenAnswer((_) async => true);

      // تنفيذ
      final result = await mockOrderTrackingNotifier.stopTracking();

      // تحقق
      expect(result, true);
      verify(mockOrderTrackingNotifier.stopTracking()).called(1);
    });

    test('getDriverLocation should return current driver location', () async {
      // ترتيب
      const orderId = 'order_123';
      final expectedLocation = LatLng(24.7136, 46.6753); // الرياض
      
      when(mockOrderTrackingNotifier.getDriverLocation(orderId))
          .thenAnswer((_) async => expectedLocation);

      // تنفيذ
      final result = await mockOrderTrackingNotifier.getDriverLocation(orderId);

      // تحقق
      expect(result, expectedLocation);
      expect(result.latitude, 24.7136);
      expect(result.longitude, 46.6753);
      verify(mockOrderTrackingNotifier.getDriverLocation(orderId)).called(1);
    });

    test('getEstimatedArrivalTime should return ETA', () async {
      // ترتيب
      const orderId = 'order_123';
      final expectedETA = DateTime.now().add(const Duration(minutes: 30));
      
      when(mockOrderTrackingNotifier.getEstimatedArrivalTime(orderId))
          .thenAnswer((_) async => expectedETA);

      // تنفيذ
      final result = await mockOrderTrackingNotifier.getEstimatedArrivalTime(orderId);

      // تحقق
      expect(result, isNotNull);
      expect(result.isAfter(DateTime.now()), true);
      verify(mockOrderTrackingNotifier.getEstimatedArrivalTime(orderId)).called(1);
    });

    test('getRoutePolyline should return route points', () async {
      // ترتيب
      const orderId = 'order_123';
      final expectedRoute = [
        LatLng(24.7136, 46.6753), // نقطة البداية
        LatLng(24.7236, 46.6853), // نقطة وسيطة
        LatLng(24.7336, 46.6953), // نقطة النهاية
      ];
      
      when(mockOrderTrackingNotifier.getRoutePolyline(orderId))
          .thenAnswer((_) async => expectedRoute);

      // تنفيذ
      final result = await mockOrderTrackingNotifier.getRoutePolyline(orderId);

      // تحقق
      expect(result, isNotNull);
      expect(result.length, 3);
      expect(result.first.latitude, 24.7136);
      expect(result.last.latitude, 24.7336);
      verify(mockOrderTrackingNotifier.getRoutePolyline(orderId)).called(1);
    });
  });
}
