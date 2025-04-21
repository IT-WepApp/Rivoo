import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:user_app/core/architecture/domain/failure.dart';
import 'package:user_app/features/ratings/domain/entities/rating.dart';
import 'package:user_app/features/ratings/domain/repositories/rating_repository.dart';
import 'package:user_app/features/ratings/domain/usecases/rating_usecases.dart';

@GenerateMocks([RatingRepository])
import 'rating_usecases_test.mocks.dart';

void main() {
  late MockRatingRepository mockRepository;
  late GetProductRatingsUseCase getProductRatingsUseCase;
  late GetProductRatingSummaryUseCase getProductRatingSummaryUseCase;
  late AddRatingUseCase addRatingUseCase;
  late UpdateRatingUseCase updateRatingUseCase;
  late DeleteRatingUseCase deleteRatingUseCase;

  setUp(() {
    mockRepository = MockRatingRepository();
    getProductRatingsUseCase = GetProductRatingsUseCase(mockRepository);
    getProductRatingSummaryUseCase =
        GetProductRatingSummaryUseCase(mockRepository);
    addRatingUseCase = AddRatingUseCase(mockRepository);
    updateRatingUseCase = UpdateRatingUseCase(mockRepository);
    deleteRatingUseCase = DeleteRatingUseCase(mockRepository);
  });

  group('GetProductRatingsUseCase', () {
    const productId = 'product123';
    final ratings = [
      Rating(
        id: 'rating1',
        userId: 'user1',
        productId: productId,
        rating: 4.5,
        createdAt: DateTime.now(),
        isVerifiedPurchase: true,
      ),
      Rating(
        id: 'rating2',
        userId: 'user2',
        productId: productId,
        rating: 3.0,
        review: 'Good product',
        createdAt: DateTime.now(),
        isVerifiedPurchase: false,
      ),
    ];

    test('should get product ratings from repository', () async {
      // Arrange
      when(mockRepository.getProductRatings(productId))
          .thenAnswer((_) async => Right(ratings));

      // Act
      final result = await getProductRatingsUseCase(productId);

      // Assert
      expect(result, Right(ratings));
      verify(mockRepository.getProductRatings(productId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = ServerFailure(message: 'Server error');
      when(mockRepository.getProductRatings(productId))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await getProductRatingsUseCase(productId);

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.getProductRatings(productId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('GetProductRatingSummaryUseCase', () {
    const productId = 'product123';
    const summary = RatingSummary(
      productId: productId,
      averageRating: 4.2,
      totalRatings: 10,
      ratingDistribution: {1: 0, 2: 1, 3: 2, 4: 3, 5: 4},
    );

    test('should get product rating summary from repository', () async {
      // Arrange
      when(mockRepository.getProductRatingSummary(productId))
          .thenAnswer((_) async => const Right(summary));

      // Act
      final result = await getProductRatingSummaryUseCase(productId);

      // Assert
      expect(result, const Right(summary));
      verify(mockRepository.getProductRatingSummary(productId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('AddRatingUseCase', () {
    final params = AddRatingParams(
      productId: 'product123',
      rating: 4.5,
      review: 'Great product',
    );

    final rating = Rating(
      id: 'rating1',
      userId: 'user1',
      productId: params.productId,
      rating: params.rating,
      review: params.review,
      createdAt: DateTime.now(),
      isVerifiedPurchase: true,
    );

    test('should add rating through repository', () async {
      // Arrange
      when(mockRepository.addRating(
        productId: params.productId,
        rating: params.rating,
        review: params.review,
      )).thenAnswer((_) async => Right(rating));

      // Act
      final result = await addRatingUseCase(params);

      // Assert
      expect(result, Right(rating));
      verify(mockRepository.addRating(
        productId: params.productId,
        rating: params.rating,
        review: params.review,
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('UpdateRatingUseCase', () {
    final params = UpdateRatingParams(
      ratingId: 'rating1',
      rating: 3.5,
      review: 'Updated review',
    );

    final rating = Rating(
      id: params.ratingId,
      userId: 'user1',
      productId: 'product123',
      rating: params.rating,
      review: params.review,
      createdAt: DateTime.now(),
      isVerifiedPurchase: true,
    );

    test('should update rating through repository', () async {
      // Arrange
      when(mockRepository.updateRating(
        ratingId: params.ratingId,
        rating: params.rating,
        review: params.review,
      )).thenAnswer((_) async => Right(rating));

      // Act
      final result = await updateRatingUseCase(params);

      // Assert
      expect(result, Right(rating));
      verify(mockRepository.updateRating(
        ratingId: params.ratingId,
        rating: params.rating,
        review: params.review,
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('DeleteRatingUseCase', () {
    const ratingId = 'rating1';

    test('should delete rating through repository', () async {
      // Arrange
      when(mockRepository.deleteRating(ratingId))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await deleteRatingUseCase(ratingId);

      // Assert
      expect(result, const Right(unit));
      verify(mockRepository.deleteRating(ratingId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
