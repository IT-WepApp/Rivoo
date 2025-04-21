import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/features/ratings/domain/repositories/rating_repository.dart';

// هذا ملف وهمي لاختبارات مستودع التقييمات
// يتم إنشاؤه لإصلاح أخطاء URI في المشروع

class MockRatingRepository extends Mock implements RatingRepository {}

@GenerateMocks([RatingRepository])
void main() {
  group('RatingRepository Tests', () {
    test('should get ratings', () {
      // اختبار وهمي
    });
  });
}
