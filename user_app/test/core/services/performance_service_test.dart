import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_performance/firebase_performance.dart';

import 'package:user_app/core/services/analytics_service.dart';

@GenerateMocks([FirebasePerformance, Trace, HttpMetric])
import 'performance_service_test.mocks.dart';

void main() {
  late MockFirebasePerformance mockPerformance;
  late MockTrace mockTrace;
  late MockHttpMetric mockHttpMetric;
  late PerformanceService performanceService;

  setUp(() {
    mockPerformance = MockFirebasePerformance();
    mockTrace = MockTrace();
    mockHttpMetric = MockHttpMetric();
    performanceService = PerformanceService(performance: mockPerformance);
  });

  group('PerformanceService', () {
    test('startTrace should create and start a new trace', () async {
      // Arrange
      when(mockPerformance.newTrace('test_trace')).thenReturn(mockTrace);
      when(mockTrace.start()).thenAnswer((_) async => null);

      // Act
      await performanceService.startTrace('test_trace');

      // Assert
      verify(mockPerformance.newTrace('test_trace')).called(1);
      verify(mockTrace.start()).called(1);
    });

    test('setTraceAttribute should set attribute on active trace', () async {
      // Arrange
      when(mockPerformance.newTrace('test_trace')).thenReturn(mockTrace);
      when(mockTrace.start()).thenAnswer((_) async => null);
      when(mockTrace.putAttribute('key', 'value')).thenReturn(null);

      // Act
      await performanceService.startTrace('test_trace');
      performanceService.setTraceAttribute('test_trace', 'key', 'value');

      // Assert
      verify(mockTrace.putAttribute('key', 'value')).called(1);
    });

    test('incrementTraceMetric should increment metric on active trace',
        () async {
      // Arrange
      when(mockPerformance.newTrace('test_trace')).thenReturn(mockTrace);
      when(mockTrace.start()).thenAnswer((_) async => null);
      when(mockTrace.incrementMetric('metric', 5)).thenReturn(null);

      // Act
      await performanceService.startTrace('test_trace');
      performanceService.incrementTraceMetric('test_trace', 'metric', 5);

      // Assert
      verify(mockTrace.incrementMetric('metric', 5)).called(1);
    });

    test('stopTrace should stop active trace', () async {
      // Arrange
      when(mockPerformance.newTrace('test_trace')).thenReturn(mockTrace);
      when(mockTrace.start()).thenAnswer((_) async => null);
      when(mockTrace.stop()).thenAnswer((_) async => null);

      // Act
      await performanceService.startTrace('test_trace');
      await performanceService.stopTrace('test_trace');

      // Assert
      verify(mockTrace.stop()).called(1);
    });

    test('startHttpMetric should create and start a new HTTP metric', () async {
      // Arrange
      when(mockPerformance.newHttpMetric('https://example.com', HttpMethod.Get))
          .thenReturn(mockHttpMetric);
      when(mockHttpMetric.start()).thenAnswer((_) async => null);

      // Act
      await performanceService.startHttpMetric(
        'https://example.com',
        'GET',
      );

      // Assert
      verify(mockPerformance.newHttpMetric(
              'https://example.com', HttpMethod.Get))
          .called(1);
      verify(mockHttpMetric.start()).called(1);
    });

    test('stopHttpMetric should set attributes and stop active HTTP metric',
        () async {
      // Arrange
      when(mockPerformance.newHttpMetric('https://example.com', HttpMethod.Get))
          .thenReturn(mockHttpMetric);
      when(mockHttpMetric.start()).thenAnswer((_) async => null);
      when(mockHttpMetric.stop()).thenAnswer((_) async => null);

      // Act
      await performanceService.startHttpMetric(
        'https://example.com',
        'GET',
      );
      await performanceService.stopHttpMetric(
        'https://example.com',
        'GET',
        responseCode: 200,
        requestPayloadSize: 100,
        responsePayloadSize: 500,
        contentType: 'application/json',
      );

      // Assert
      verify(mockHttpMetric.httpResponseCode = 200).called(1);
      verify(mockHttpMetric.requestPayloadSize = 100).called(1);
      verify(mockHttpMetric.responsePayloadSize = 500).called(1);
      verify(mockHttpMetric.putAttribute('content_type', 'application/json'))
          .called(1);
      verify(mockHttpMetric.stop()).called(1);
    });
  });
}
