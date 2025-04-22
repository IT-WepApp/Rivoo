import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:user_app/features/ratings/application/ratings_notifier.dart';

import 'ratings_notifier_test.mocks.dart';

@GenerateMocks([RatingsNotifier])
void main() {
  late MockRatingsNotifier mockRatingsNotifier;

  setUp(() {
    mockRatingsNotifier = MockRatingsNotifier();
  });

  group('RatingsNotifier Tests', () {
    test('loadRatings should update state with ratings and summary', () async {
      // ترتيب
      const productId = 'product-1';
      when(mockRatingsNotifier.loadRatings(productId)).thenAnswer((_) async {});

      // تنفيذ
      await mockRatingsNotifier.loadRatings(productId);

      // تحقق
      verify(mockRatingsNotifier.loadRatings(productId)).called(1);
    });

    test('addRating should update state with new rating', () async {
      // ترتيب
      final testDate = DateTime.now();
      final rating = Rating(
        id: 'rating-1',
        userId: 'user-1',
        productId: 'product-1',
        rating: 4.5,
        review: 'منتج رائع!',
        createdAt: testDate,
        userDisplayName: 'أحمد محمد',
        isVerifiedPurchase: true,
      );
      when(mockRatingsNotifier.addRating(rating)).thenAnswer((_) async {});

      // تنفيذ
      await mockRatingsNotifier.addRating(rating);

      // تحقق
      verify(mockRatingsNotifier.addRating(rating)).called(1);
    });

    test('updateRating should update state with modified rating', () async {
      // ترتيب
      final testDate = DateTime.now();
      final rating = Rating(
        id: 'rating-1',
        userId: 'user-1',
        productId: 'product-1',
        rating: 3.5,
        review: 'تم تعديل التقييم',
        createdAt: testDate,
        userDisplayName: 'أحمد محمد',
        isVerifiedPurchase: true,
      );
      when(mockRatingsNotifier.updateRating(rating)).thenAnswer((_) async {});

      // تنفيذ
      await mockRatingsNotifier.updateRating(rating);

      // تحقق
      verify(mockRatingsNotifier.updateRating(rating)).called(1);
    });

    test('deleteRating should remove rating from state', () async {
      // ترتيب
      const ratingId = 'rating-1';
      when(mockRatingsNotifier.deleteRating(ratingId)).thenAnswer((_) async {});

      // تنفيذ
      await mockRatingsNotifier.deleteRating(ratingId);

      // تحقق
      verify(mockRatingsNotifier.deleteRating(ratingId)).called(1);
    });
  });
}
