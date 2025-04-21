import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:user_app/core/services/crashlytics_service.dart';

import 'crashlytics_service_test.mocks.dart';

@GenerateMocks([FirebaseCrashlytics])
void main() {
  late MockFirebaseCrashlytics mockCrashlytics;
  late CrashlyticsService crashlyticsService;

  setUp(() {
    mockCrashlytics = MockFirebaseCrashlytics();
    crashlyticsService = CrashlyticsService(
      crashlytics: mockCrashlytics,
    );
  });

  group('CrashlyticsService Tests', () {
    test('initialize يجب أن يقوم بتهيئة Crashlytics بشكل صحيح', () async {
      // محاكاة الاستدعاءات المتوقعة
      when(mockCrashlytics.setCrashlyticsCollectionEnabled(any))
          .thenAnswer((_) async => true);

      // تنفيذ
      await crashlyticsService.initialize();

      // التحقق
      verify(mockCrashlytics.setCrashlyticsCollectionEnabled(!kDebugMode))
          .called(1);

      // التحقق من تعيين معالجي الأخطاء
      expect(FlutterError.onError, isNotNull);
    });

    test('recordError يجب أن يسجل الخطأ في Crashlytics', () async {
      // إعداد
      final exception = Exception('Test error');
      final stack = StackTrace.current;

      // محاكاة الاستدعاء المتوقع
      when(mockCrashlytics.recordError(any, any,
              fatal: anyNamed('fatal'), printDetails: anyNamed('printDetails')))
          .thenAnswer((_) async {});

      // تنفيذ
      await crashlyticsService.recordError(exception, stack, fatal: true);

      // التحقق
      verify(mockCrashlytics.recordError(
        exception,
        stack,
        fatal: true,
        printDetails: true,
      )).called(1);
    });

    test('log يجب أن يسجل رسالة في Crashlytics', () async {
      // إعداد
      const message = 'Test log message';

      // محاكاة الاستدعاء المتوقع
      when(mockCrashlytics.log(any)).thenAnswer((_) async {});

      // تنفيذ
      await crashlyticsService.log(message);

      // التحقق
      verify(mockCrashlytics.log(message)).called(1);
    });

    test('setUserIdentifier يجب أن يعين معرف المستخدم في Crashlytics',
        () async {
      // إعداد
      const userId = 'test-user-123';

      // محاكاة الاستدعاء المتوقع
      when(mockCrashlytics.setUserIdentifier(any)).thenAnswer((_) async {});

      // تنفيذ
      await crashlyticsService.setUserIdentifier(userId);

      // التحقق
      verify(mockCrashlytics.setUserIdentifier(userId)).called(1);
    });

    test('setCustomKey يجب أن يضيف بيانات سياقية في Crashlytics', () async {
      // إعداد
      const key = 'test-key';
      const value = 'test-value';

      // محاكاة الاستدعاء المتوقع
      when(mockCrashlytics.setCustomKey(any, any)).thenAnswer((_) async {});

      // تنفيذ
      await crashlyticsService.setCustomKey(key, value);

      // التحقق
      verify(mockCrashlytics.setCustomKey(key, value)).called(1);
    });

    test('recordErrorToCrashlytics يجب أن يسجل الخطأ مع معلومات إضافية',
        () async {
      // إعداد
      final exception = Exception('Test error');
      final stack = StackTrace.current;
      const reason = 'Test reason';
      final information = {'key1': 'value1', 'key2': 'value2'};

      // محاكاة الاستدعاءات المتوقعة
      when(mockCrashlytics.log(any)).thenAnswer((_) async {});
      when(mockCrashlytics.setCustomKey(any, any)).thenAnswer((_) async {});
      when(mockCrashlytics.recordError(any, any,
              fatal: anyNamed('fatal'), printDetails: anyNamed('printDetails')))
          .thenAnswer((_) async {});

      // تجاوز الدالة العامة باستخدام نسخة محلية للاختبار
      final crashlytics = mockCrashlytics;

      // تنفيذ
      await recordErrorToCrashlytics(
        exception,
        stack,
        fatal: true,
        reason: reason,
        information: information,
      );

      // التحقق
      verify(crashlytics.log(contains(reason))).called(1);
      verify(crashlytics.setCustomKey('key1', 'value1')).called(1);
      verify(crashlytics.setCustomKey('key2', 'value2')).called(1);
      verify(crashlytics.recordError(
        exception,
        stack,
        fatal: true,
        printDetails: true,
      )).called(1);
    });
  });
}
