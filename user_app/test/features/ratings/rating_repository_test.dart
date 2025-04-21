import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:user_app/core/architecture/domain/failure.dart';
import 'package:user_app/features/ratings/data/repositories/rating_repository_impl.dart';
import 'package:user_app/features/ratings/domain/entities/rating.dart';
import 'package:user_app/features/ratings/domain/repositories/rating_repository.dart';
import 'package:dartz/dartz.dart';

import 'rating_repository_test.mocks.dart';

// إنشاء الـ mock classes
@GenerateMocks([RatingRemoteDataSource, RatingLocalDataSource])
void main() {
  late RatingRepositoryImpl repository;
  late MockRatingRemoteDataSource mockRemoteDataSource;
  late MockRatingLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockRatingRemoteDataSource();
    mockLocalDataSource = MockRatingLocalDataSource();
    repository = RatingRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('getRatings', () {
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

    test('should return ratings when remote data source is successful', () async {
      // Arrange
      when(mockRemoteDataSource.getRatings('product-1'))
          .thenAnswer((_) async => testRatings);

      // Act
      final result = await repository.getRatings('product-1');

      // Assert
      expect(result, equals(Right(testRatings)));
      verify(mockRemoteDataSource.getRatings('product-1'));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyZeroInteractions(mockLocalDataSource);
    });

    test('should return ServerFailure when remote data source throws an exception', () async {
      // Arrange
      when(mockRemoteDataSource.getRatings('product-1'))
          .thenThrow(Exception('Server error'));

      // Act
      final result = await repository.getRatings('product-1');

      // Assert
      expect(result, equals(Left(ServerFailure(message: 'Server error'))));
      verify(mockRemoteDataSource.getRatings('product-1'));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyZeroInteractions(mockLocalDataSource);
    });
  });

  group('getRatingSummary', () {
    final testSummary = RatingSummary(
      productId: 'product-1',
      averageRating: 4.2,
      totalRatings: 10,
      ratingDistribution: {1: 1, 2: 1, 3: 1, 4: 2, 5: 5},
    );

    test('should return rating summary when remote data source is successful', () async {
      // Arrange
      when(mockRemoteDataSource.getRatingSummary('product-1'))
          .thenAnswer((_) async => testSummary);

      // Act
      final result = await repository.getRatingSummary('product-1');

      // Assert
      expect(result, equals(Right(testSummary)));
      verify(mockRemoteDataSource.getRatingSummary('product-1'));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyZeroInteractions(mockLocalDataSource);
    });

    test('should return ServerFailure when remote data source throws an exception', () async {
      // Arrange
      when(mockRemoteDataSource.getRatingSummary('product-1'))
          .thenThrow(Exception('Server error'));

      // Act
      final result = await repository.getRatingSummary('product-1');

      // Assert
      expect(result, equals(Left(ServerFailure(message: 'Server error'))));
      verify(mockRemoteDataSource.getRatingSummary('product-1'));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyZeroInteractions(mockLocalDataSource);
    });
  });

  group('addRating', () {
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

    test('should add rating when remote data source is successful', () async {
      // Arrange
      when(mockRemoteDataSource.addRating(testRating))
          .thenAnswer((_) async => testRating);

      // Act
      final result = await repository.addRating(testRating);

      // Assert
      expect(result, equals(Right(testRating)));
      verify(mockRemoteDataSource.addRating(testRating));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyZeroInteractions(mockLocalDataSource);
    });

    test('should return ServerFailure when remote data source throws an exception', () async {
      // Arrange
      when(mockRemoteDataSource.addRating(testRating))
          .thenThrow(Exception('Server error'));

      // Act
      final result = await repository.addRating(testRating);

      // Assert
      expect(result, equals(Left(ServerFailure(message: 'Server error'))));
      verify(mockRemoteDataSource.addRating(testRating));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyZeroInteractions(mockLocalDataSource);
    });
  });

  group('updateRating', () {
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

    test('should update rating when remote data source is successful', () async {
      // Arrange
      when(mockRemoteDataSource.updateRating(testRating))
          .thenAnswer((_) async => testRating);

      // Act
      final result = await repository.updateRating(testRating);

      // Assert
      expect(result, equals(Right(testRating)));
      verify(mockRemoteDataSource.updateRating(testRating));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyZeroInteractions(mockLocalDataSource);
    });

    test('should return ServerFailure when remote data source throws an exception', () async {
      // Arrange
      when(mockRemoteDataSource.updateRating(testRating))
          .thenThrow(Exception('Server error'));

      // Act
      final result = await repository.updateRating(testRating);

      // Assert
      expect(result, equals(Left(ServerFailure(message: 'Server error'))));
      verify(mockRemoteDataSource.updateRating(testRating));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyZeroInteractions(mockLocalDataSource);
    });

    test('should return NotFoundFailure when rating is not found', () async {
      // Arrange
      when(mockRemoteDataSource.updateRating(testRating))
          .thenThrow(Exception('Rating not found'));

      // Act
      final result = await repository.updateRating(testRating);

      // Assert
      expect(result, equals(Left(NotFoundFailure(message: 'Rating not found'))));
      verify(mockRemoteDataSource.updateRating(testRating));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyZeroInteractions(mockLocalDataSource);
    });
  });

  group('deleteRating', () {
    test('should delete rating when remote data source is successful', () async {
      // Arrange
      when(mockRemoteDataSource.deleteRating('rating-1'))
          .thenAnswer((_) async => true);

      // Act
      final result = await repository.deleteRating('rating-1');

      // Assert
      expect(result, equals(const Right(true)));
      verify(mockRemoteDataSource.deleteRating('rating-1'));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyZeroInteractions(mockLocalDataSource);
    });

    test('should return ServerFailure when remote data source throws an exception', () async {
      // Arrange
      when(mockRemoteDataSource.deleteRating('rating-1'))
          .thenThrow(Exception('Server error'));

      // Act
      final result = await repository.deleteRating('rating-1');

      // Assert
      expect(result, equals(Left(ServerFailure(message: 'Server error'))));
      verify(mockRemoteDataSource.deleteRating('rating-1'));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyZeroInteractions(mockLocalDataSource);
    });

    test('should return NotFoundFailure when rating is not found', () async {
      // Arrange
      when(mockRemoteDataSource.deleteRating('rating-1'))
          .thenThrow(Exception('Rating not found'));

      // Act
      final result = await repository.deleteRating('rating-1');

      // Assert
      expect(result, equals(Left(NotFoundFailure(message: 'Rating not found'))));
      verify(mockRemoteDataSource.deleteRating('rating-1'));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyZeroInteractions(mockLocalDataSource);
    });
  });
}
