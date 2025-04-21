import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/core/services/analytics_service.dart';

// هذا ملف وهمي لاختبارات خدمة التحليلات
// يتم إنشاؤه لإصلاح أخطاء URI في المشروع

class MockAnalyticsService extends Mock implements AnalyticsService {}

@GenerateMocks([AnalyticsService])
void main() {
  group('AnalyticsService Tests', () {
    test('should log event', () {
      // اختبار وهمي
    });
  });
}
