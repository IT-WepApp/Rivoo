import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:user_app/core/monitoring/analytics_monitor.dart';
import 'package:user_app/core/services/analytics_service.dart';

@GenerateMocks([AnalyticsService, PerformanceService])
import 'analytics_monitor_test.mocks.dart';

void main() {
  late MockAnalyticsService mockAnalyticsService;
  late MockPerformanceService mockPerformanceService;
  late AnalyticsObserver analyticsObserver;
  late PerformanceMonitor performanceMonitor;

  setUp(() {
    mockAnalyticsService = MockAnalyticsService();
    mockPerformanceService = MockPerformanceService();
    analyticsObserver = AnalyticsObserver(mockAnalyticsService);
    performanceMonitor = PerformanceMonitor(mockPerformanceService);
  });

  group('AnalyticsObserver', () {
    test('didPush should log screen view', () {
      // Arrange
      final route = MockRoute();
      when(route.settings).thenReturn(const RouteSettings(name: 'test_screen'));

      // Act
      analyticsObserver.didPush(route, null);

      // Assert
      verify(mockAnalyticsService.logScreenView(
        screenName: 'test_screen',
        screenClass: 'test_screen',
      )).called(1);
    });

    test('didReplace should log screen view for new route', () {
      // Arrange
      final newRoute = MockRoute();
      when(newRoute.settings)
          .thenReturn(const RouteSettings(name: 'new_screen'));

      // Act
      analyticsObserver.didReplace(newRoute: newRoute, oldRoute: null);

      // Assert
      verify(mockAnalyticsService.logScreenView(
        screenName: 'new_screen',
        screenClass: 'new_screen',
      )).called(1);
    });

    test('didPop should log screen view for previous route', () {
      // Arrange
      final route = MockRoute();
      final previousRoute = MockRoute();
      when(previousRoute.settings)
          .thenReturn(const RouteSettings(name: 'previous_screen'));

      // Act
      analyticsObserver.didPop(route, previousRoute);

      // Assert
      verify(mockAnalyticsService.logScreenView(
        screenName: 'previous_screen',
        screenClass: 'previous_screen',
      )).called(1);
    });
  });

  group('PerformanceMonitor', () {
    test('monitorOperation should start and stop trace', () async {
      // Arrange
      when(mockPerformanceService.startTrace('operation_test_operation'))
          .thenAnswer((_) async {});
      when(mockPerformanceService.stopTrace('operation_test_operation'))
          .thenAnswer((_) async {});

      // Act
      final result = await performanceMonitor.monitorOperation(
        operationName: 'test_operation',
        operation: () async => 'result',
      );

      // Assert
      expect(result, 'result');
      verify(mockPerformanceService.startTrace('operation_test_operation'))
          .called(1);
      verify(mockPerformanceService.stopTrace('operation_test_operation'))
          .called(1);
    });

    test('monitorOperation should set attributes if provided', () async {
      // Arrange
      when(mockPerformanceService.startTrace('operation_test_operation'))
          .thenAnswer((_) async {});
      when(mockPerformanceService.stopTrace('operation_test_operation'))
          .thenAnswer((_) async {});

      // Act
      await performanceMonitor.monitorOperation(
        operationName: 'test_operation',
        operation: () async => 'result',
        attributes: {'key': 'value'},
      );

      // Assert
      verify(mockPerformanceService.setTraceAttribute(
              'operation_test_operation', 'key', 'value'))
          .called(1);
    });

    test('monitorOperation should handle errors and rethrow', () async {
      // Arrange
      when(mockPerformanceService.startTrace('operation_test_operation'))
          .thenAnswer((_) async {});
      when(mockPerformanceService.stopTrace('operation_test_operation'))
          .thenAnswer((_) async {});

      // Act & Assert
      expect(
        () => performanceMonitor.monitorOperation(
          operationName: 'test_operation',
          operation: () async => throw Exception('Test error'),
        ),
        throwsException,
      );

      verify(mockPerformanceService.setTraceAttribute(
              'operation_test_operation', 'error', 'Exception: Test error'))
          .called(1);
      verify(mockPerformanceService.stopTrace('operation_test_operation'))
          .called(1);
    });

    test('monitorHttpRequest should start and stop HTTP metric', () async {
      // Arrange
      when(mockPerformanceService.startHttpMetric('https://example.com', 'GET'))
          .thenAnswer((_) async {});
      when(mockPerformanceService.stopHttpMetric(
        'https://example.com',
        'GET',
        responseCode: 200,
        requestPayloadSize: 100,
        responsePayloadSize: 500,
        contentType: 'application/json',
      )).thenAnswer((_) async {});

      // Act
      final result = await performanceMonitor.monitorHttpRequest(
        url: 'https://example.com',
        method: 'GET',
        request: () async => 'response',
        responseCode: 200,
        requestSize: 100,
        responseSize: 500,
        contentType: 'application/json',
      );

      // Assert
      expect(result, 'response');
      verify(mockPerformanceService.startHttpMetric(
              'https://example.com', 'GET'))
          .called(1);
      verify(mockPerformanceService.stopHttpMetric(
        'https://example.com',
        'GET',
        responseCode: 200,
        requestPayloadSize: 100,
        responsePayloadSize: 500,
        contentType: 'application/json',
      )).called(1);
    });
  });
}

class MockRoute extends Mock implements Route {
  @override
  RouteSettings get settings => super.noSuchMethod(
        Invocation.getter(#settings),
        returnValue: const RouteSettings(),
      ) as RouteSettings;
}
