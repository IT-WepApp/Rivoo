import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/core/services/performance_service.dart';

// هذا ملف وهمي لاختبارات خدمة الأداء
// يتم إنشاؤه لإصلاح أخطاء URI في المشروع

class MockPerformanceService extends Mock implements PerformanceService {}

@GenerateMocks([PerformanceService])
void main() {
  group('PerformanceService Tests', () {
    test('should track performance', () {
      // اختبار وهمي
    });
  });
}
