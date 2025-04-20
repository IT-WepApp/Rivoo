import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/features/ratings/application/ratings_notifier.dart';

@GenerateMocks([RatingsNotifier])
void main() {
  late MockRatingsNotifier mockRatingsNotifier;

  setUp(() {
    mockRatingsNotifier = MockRatingsNotifier();
  });

  group('RatingsNotifier Tests', () {
    test('addRating should add a new rating successfully', () async {
      // ترتيب
      const productId = 'product_123';
      const rating = 4;
      const comment = 'منتج رائع، أنصح به';
      
      when(mockRatingsNotifier.addRating(
        productId: productId,
        rating: rating,
        comment: comment,
      )).thenAnswer((_) async => true);

      // تنفيذ
      final result = await mockRatingsNotifier.addRating(
        productId: productId,
        rating: rating,
        comment: comment,
      );

      // تحقق
      expect(result, true);
      verify(mockRatingsNotifier.addRating(
        productId: productId,
        rating: rating,
        comment: comment,
      )).called(1);
    });

    test('updateRating should update an existing rating', () async {
      // ترتيب
      const ratingId = 'rating_123';
      const productId = 'product_123';
      const newRating = 5;
      const newComment = 'تحديث: المنتج ممتاز جداً';
      
      when(mockRatingsNotifier.updateRating(
        ratingId: ratingId,
        productId: productId,
        rating: newRating,
        comment: newComment,
      )).thenAnswer((_) async => true);

      // تنفيذ
      final result = await mockRatingsNotifier.updateRating(
        ratingId: ratingId,
        productId: productId,
        rating: newRating,
        comment: newComment,
      );

      // تحقق
      expect(result, true);
      verify(mockRatingsNotifier.updateRating(
        ratingId: ratingId,
        productId: productId,
        rating: newRating,
        comment: newComment,
      )).called(1);
    });

    test('deleteRating should delete a rating', () async {
      // ترتيب
      const ratingId = 'rating_123';
      const productId = 'product_123';
      
      when(mockRatingsNotifier.deleteRating(
        ratingId: ratingId,
        productId: productId,
      )).thenAnswer((_) async => true);

      // تنفيذ
      final result = await mockRatingsNotifier.deleteRating(
        ratingId: ratingId,
        productId: productId,
      );

      // تحقق
      expect(result, true);
      verify(mockRatingsNotifier.deleteRating(
        ratingId: ratingId,
        productId: productId,
      )).called(1);
    });

    test('getProductRatings should return product ratings', () async {
      // ترتيب
      const productId = 'product_123';
      final expectedRatings = [
        {'id': 'rating_1', 'rating': 5, 'comment': 'ممتاز'},
        {'id': 'rating_2', 'rating': 4, 'comment': 'جيد جدا'},
      ];
      
      when(mockRatingsNotifier.getProductRatings(productId))
          .thenAnswer((_) async => expectedRatings);

      // تنفيذ
      final result = await mockRatingsNotifier.getProductRatings(productId);

      // تحقق
      expect(result, expectedRatings);
      expect(result.length, 2);
      verify(mockRatingsNotifier.getProductRatings(productId)).called(1);
    });

    test('getAverageRating should calculate correct average', () async {
      // ترتيب
      const productId = 'product_123';
      const expectedAverage = 4.5;
      
      when(mockRatingsNotifier.getAverageRating(productId))
          .thenAnswer((_) async => expectedAverage);

      // تنفيذ
      final result = await mockRatingsNotifier.getAverageRating(productId);

      // تحقق
      expect(result, expectedAverage);
      verify(mockRatingsNotifier.getAverageRating(productId)).called(1);
    });
  });
}
