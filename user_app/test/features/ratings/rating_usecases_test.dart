import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:user_app/features/ratings/domain/entities/rating.dart';
import 'package:user_app/features/ratings/domain/repositories/rating_repository.dart';
import 'package:user_app/features/ratings/domain/usecases/rating_usecases.dart';
import 'package:dartz/dartz.dart';
import 'package:user_app/core/architecture/domain/failure.dart';

import 'rating_usecases_test.mocks.dart';

@GenerateMocks([RatingRepository])
void main() {
  late GetRatings getRatings;
  late GetRatingSummary getRatingSummary;
  late AddRating addRating;
  late UpdateRating updateRating;
  late DeleteRating deleteRating;
  late MockRatingRepository mockRepository;

  setUp(() {
    mockRepository = MockRatingRepository();
    getRatings = GetRatings(mockRepository);
    getRatingSummary = GetRatingSummary(mockRepository);
    addRating = AddRating(mockRepository);
    updateRating = UpdateRating(mockRepository);
    deleteRating = DeleteRating(mockRepository);
  });

  group('GetRatings', () {
    final testDate = DateTime(2025, 4, 21);
    final testRatings = [
      Rating(
        id: 'rating-1',
        userId: 'user-1',
        productId: 'product-1',
        rating: 4.5,
        review: 'Great product!',
        createdAt: testDate,
        userDisplayName: 'Test User',
        isVerifiedPurchase: true,
      ),
      Rating(
        id: 'rating-2',
        userId: 'user-2',
        productId: 'product-1',
        rating: 3.0,
        review: 'Good but could be better',
        createdAt: testDate,
        userDisplayName: 'Another User',
        isVerifiedPurchase: false,
      ),
    ];

    test('should get ratings from the repository', () async {
      // Arrange
      when(mockRepository.getRatings('product-1'))
          .thenAnswer((_) async => Right(testRatings));

      // Act
      final result = await getRatings(productId: 'product-1');

      // Assert
      expect(result, equals(Right(testRatings)));
      verify(mockRepository.getRatings('product-1'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      final failure = ServerFailure(message: 'Server error');
      when(mockRepository.getRatings('product-1'))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await getRatings(productId: 'product-1');

      // Assert
      expect(result, equals(Left(failure)));
      verify(mockRepository.getRatings('product-1'));
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('GetRatingSummary', () {
    final testSummary = RatingSummary(
      productId: 'product-1',
      averageRating: 4.2,
      totalRatings: 10,
      ratingDistribution: {1: 1, 2: 1, 3: 1, 4: 2, 5: 5},
    );

    test('should get rating summary from the repository', () async {
      // Arrange
      when(mockRepository.getRatingSummary('product-1'))
          .thenAnswer((_) async => Right(testSummary));

      // Act
      final result = await getRatingSummary(productId: 'product-1');

      // Assert
      expect(result, equals(Right(testSummary)));
      verify(mockRepository.getRatingSummary('product-1'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      final failure = ServerFailure(message: 'Server error');
      when(mockRepository.getRatingSummary('product-1'))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await getRatingSummary(productId: 'product-1');

      // Assert
      expect(result, equals(Left(failure)));
      verify(mockRepository.getRatingSummary('product-1'));
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('AddRating', () {
    final testDate = DateTime(2025, 4, 21);
    final testRating = Rating(
      id: 'rating-1',
      userId: 'user-1',
      productId: 'product-1',
      rating: 4.5,
      review: 'Great product!',
      createdAt: testDate,
      userDisplayName: 'Test User',
      isVerifiedPurchase: true,
    );

    test('should add rating through the repository', () async {
      // Arrange
      when(mockRepository.addRating(testRating))
          .thenAnswer((_) async => Right(testRating));

      // Act
      final result = await addRating(rating: testRating);

      // Assert
      expect(result, equals(Right(testRating)));
      verify(mockRepository.addRating(testRating));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      final failure = ServerFailure(message: 'Server error');
      when(mockRepository.addRating(testRating))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await addRating(rating: testRating);

      // Assert
      expect(result, equals(Left(failure)));
      verify(mockRepository.addRating(testRating));
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('UpdateRating', () {
    final testDate = DateTime(2025, 4, 21);
    final testRating = Rating(
      id: 'rating-1',
      userId: 'user-1',
      productId: 'product-1',
      rating: 4.5,
      review: 'Updated review!',
      createdAt: testDate,
      userDisplayName: 'Test User',
      isVerifiedPurchase: true,
    );

    test('should update rating through the repository', () async {
      // Arrange
      when(mockRepository.updateRating(testRating))
          .thenAnswer((_) async => Right(testRating));

      // Act
      final result = await updateRating(rating: testRating);

      // Assert
      expect(result, equals(Right(testRating)));
      verify(mockRepository.updateRating(testRating));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      final failure = ServerFailure(message: 'Server error');
      when(mockRepository.updateRating(testRating))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await updateRating(rating: testRating);

      // Assert
      expect(result, equals(Left(failure)));
      verify(mockRepository.updateRating(testRating));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NotFoundFailure when rating is not found', () async {
      // Arrange
      final failure = NotFoundFailure(message: 'Rating not found');
      when(mockRepository.updateRating(testRating))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await updateRating(rating: testRating);

      // Assert
      expect(result, equals(Left(failure)));
      verify(mockRepository.updateRating(testRating));
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('DeleteRating', () {
    test('should delete rating through the repository', () async {
      // Arrange
      when(mockRepository.deleteRating('rating-1'))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await deleteRating(ratingId: 'rating-1');

      // Assert
      expect(result, equals(const Right(true)));
      verify(mockRepository.deleteRating('rating-1'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      final failure = ServerFailure(message: 'Server error');
      when(mockRepository.deleteRating('rating-1'))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await deleteRating(ratingId: 'rating-1');

      // Assert
      expect(result, equals(Left(failure)));
      verify(mockRepository.deleteRating('rating-1'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NotFoundFailure when rating is not found', () async {
      // Arrange
      final failure = NotFoundFailure(message: 'Rating not found');
      when(mockRepository.deleteRating('rating-1'))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await deleteRating(ratingId: 'rating-1');

      // Assert
      expect(result, equals(Left(failure)));
      verify(mockRepository.deleteRating('rating-1'));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
