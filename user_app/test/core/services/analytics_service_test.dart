import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';

import 'package:user_app/core/services/analytics_service.dart';

@GenerateMocks([FirebaseAnalytics, FirebasePerformance, Trace, HttpMetric])
import 'analytics_service_test.mocks.dart';

void main() {
  late MockFirebaseAnalytics mockAnalytics;
  late AnalyticsService analyticsService;

  setUp(() {
    mockAnalytics = MockFirebaseAnalytics();
    analyticsService = AnalyticsService(analytics: mockAnalytics);
  });

  group('AnalyticsService', () {
    test('logScreenView should call FirebaseAnalytics.logScreenView', () async {
      // Arrange
      when(mockAnalytics.logScreenView(
        screenName: 'test_screen',
        screenClass: 'TestScreen',
      )).thenAnswer((_) async => null);

      // Act
      await analyticsService.logScreenView(
        screenName: 'test_screen',
        screenClass: 'TestScreen',
      );

      // Assert
      verify(mockAnalytics.logScreenView(
        screenName: 'test_screen',
        screenClass: 'TestScreen',
      )).called(1);
    });

    test('logLogin should call FirebaseAnalytics.logLogin', () async {
      // Arrange
      when(mockAnalytics.logLogin(
        loginMethod: 'email',
      )).thenAnswer((_) async => null);

      // Act
      await analyticsService.logLogin(loginMethod: 'email');

      // Assert
      verify(mockAnalytics.logLogin(
        loginMethod: 'email',
      )).called(1);
    });

    test('logSignUp should call FirebaseAnalytics.logSignUp', () async {
      // Arrange
      when(mockAnalytics.logSignUp(
        signUpMethod: 'email',
      )).thenAnswer((_) async => null);

      // Act
      await analyticsService.logSignUp(signUpMethod: 'email');

      // Assert
      verify(mockAnalytics.logSignUp(
        signUpMethod: 'email',
      )).called(1);
    });

    test('logPurchase should call FirebaseAnalytics.logPurchase', () async {
      // Arrange
      final items = [
        AnalyticsEventItem(
          itemId: 'product1',
          itemName: 'Product 1',
          price: 10.0,
          quantity: 2,
        ),
      ];

      when(mockAnalytics.logPurchase(
        value: 20.0,
        currency: 'USD',
        transactionId: 'order123',
        items: items,
      )).thenAnswer((_) async => null);

      // Act
      await analyticsService.logPurchase(
        value: 20.0,
        currency: 'USD',
        transactionId: 'order123',
        items: items,
      );

      // Assert
      verify(mockAnalytics.logPurchase(
        value: 20.0,
        currency: 'USD',
        transactionId: 'order123',
        items: items,
      )).called(1);
    });

    test('logCustomEvent should call FirebaseAnalytics.logEvent', () async {
      // Arrange
      final parameters = {'param1': 'value1', 'param2': 'value2'};

      when(mockAnalytics.logEvent(
        name: 'custom_event',
        parameters: parameters,
      )).thenAnswer((_) async => null);

      // Act
      await analyticsService.logCustomEvent(
        name: 'custom_event',
        parameters: parameters,
      );

      // Assert
      verify(mockAnalytics.logEvent(
        name: 'custom_event',
        parameters: parameters,
      )).called(1);
    });

    test(
        'setUserProperties should call FirebaseAnalytics.setUserId and setUserProperty',
        () async {
      // Arrange
      when(mockAnalytics.setUserId(id: 'user123'))
          .thenAnswer((_) async => null);
      when(mockAnalytics.setUserProperty(name: 'user_role', value: 'admin'))
          .thenAnswer((_) async => null);
      when(mockAnalytics.setUserProperty(name: 'user_language', value: 'ar'))
          .thenAnswer((_) async => null);
      when(mockAnalytics.setUserProperty(name: 'user_theme', value: 'dark'))
          .thenAnswer((_) async => null);

      // Act
      await analyticsService.setUserProperties(
        userId: 'user123',
        userRole: 'admin',
        userLanguage: 'ar',
        userTheme: 'dark',
      );

      // Assert
      verify(mockAnalytics.setUserId(id: 'user123')).called(1);
      verify(mockAnalytics.setUserProperty(name: 'user_role', value: 'admin'))
          .called(1);
      verify(mockAnalytics.setUserProperty(name: 'user_language', value: 'ar'))
          .called(1);
      verify(mockAnalytics.setUserProperty(name: 'user_theme', value: 'dark'))
          .called(1);
    });
  });
}
