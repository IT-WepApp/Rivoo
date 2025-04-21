import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/features/ratings/data/models/rating_model.dart';

void main() {
  group('RatingModel', () {
    final testDate = DateTime(2025, 4, 21);
    
    test('should create a valid RatingModel instance', () {
      // Arrange
      const id = 'test-id';
      const userId = 'user-123';
      const productId = 'product-456';
      const rating = 4.5;
      const review = 'Great product!';
      const userDisplayName = 'Test User';
      const isVerifiedPurchase = true;
      
      // Act
      final ratingModel = RatingModel(
        id: id,
        userId: userId,
        productId: productId,
        rating: rating,
        review: review,
        createdAt: testDate,
        userDisplayName: userDisplayName,
        isVerifiedPurchase: isVerifiedPurchase,
      );
      
      // Assert
      expect(ratingModel.id, equals(id));
      expect(ratingModel.userId, equals(userId));
      expect(ratingModel.productId, equals(productId));
      expect(ratingModel.rating, equals(rating));
      expect(ratingModel.review, equals(review));
      expect(ratingModel.createdAt, equals(testDate));
      expect(ratingModel.userDisplayName, equals(userDisplayName));
      expect(ratingModel.isVerifiedPurchase, equals(isVerifiedPurchase));
    });
    
    test('should create a RatingModel from JSON', () {
      // Arrange
      final json = {
        'id': 'test-id',
        'userId': 'user-123',
        'productId': 'product-456',
        'rating': 4.5,
        'review': 'Great product!',
        'createdAt': '2025-04-21T12:00:00.000Z',
        'userDisplayName': 'Test User',
        'isVerifiedPurchase': true,
      };
      
      // Act
      final ratingModel = RatingModel.fromJson(json);
      
      // Assert
      expect(ratingModel.id, equals(json['id']));
      expect(ratingModel.userId, equals(json['userId']));
      expect(ratingModel.productId, equals(json['productId']));
      expect(ratingModel.rating, equals(json['rating']));
      expect(ratingModel.review, equals(json['review']));
      expect(ratingModel.createdAt, equals(DateTime.parse(json['createdAt'] as String)));
      expect(ratingModel.userDisplayName, equals(json['userDisplayName']));
      expect(ratingModel.isVerifiedPurchase, equals(json['isVerifiedPurchase']));
    });
    
    test('should convert RatingModel to JSON', () {
      // Arrange
      final ratingModel = RatingModel(
        id: 'test-id',
        userId: 'user-123',
        productId: 'product-456',
        rating: 4.5,
        review: 'Great product!',
        createdAt: testDate,
        userDisplayName: 'Test User',
        isVerifiedPurchase: true,
      );
      
      // Act
      final json = ratingModel.toJson();
      
      // Assert
      expect(json['id'], equals(ratingModel.id));
      expect(json['userId'], equals(ratingModel.userId));
      expect(json['productId'], equals(ratingModel.productId));
      expect(json['rating'], equals(ratingModel.rating));
      expect(json['review'], equals(ratingModel.review));
      expect(json['createdAt'], equals(ratingModel.createdAt.toIso8601String()));
      expect(json['userDisplayName'], equals(ratingModel.userDisplayName));
      expect(json['isVerifiedPurchase'], equals(ratingModel.isVerifiedPurchase));
    });
  });
  
  group('RatingSummaryModel', () {
    test('should create a valid RatingSummaryModel instance', () {
      // Arrange
      const productId = 'product-456';
      const averageRating = 4.2;
      const totalRatings = 10;
      final ratingDistribution = {1: 1, 2: 1, 3: 1, 4: 2, 5: 5};
      
      // Act
      final ratingSummaryModel = RatingSummaryModel(
        productId: productId,
        averageRating: averageRating,
        totalRatings: totalRatings,
        ratingDistribution: ratingDistribution,
      );
      
      // Assert
      expect(ratingSummaryModel.productId, equals(productId));
      expect(ratingSummaryModel.averageRating, equals(averageRating));
      expect(ratingSummaryModel.totalRatings, equals(totalRatings));
      expect(ratingSummaryModel.ratingDistribution, equals(ratingDistribution));
    });
    
    test('should create a RatingSummaryModel from JSON', () {
      // Arrange
      final json = {
        'productId': 'product-456',
        'averageRating': 4.2,
        'totalRatings': 10,
        'ratingDistribution': {
          '1': 1,
          '2': 1,
          '3': 1,
          '4': 2,
          '5': 5,
        },
      };
      
      // Act
      final ratingSummaryModel = RatingSummaryModel.fromJson(json);
      
      // Assert
      expect(ratingSummaryModel.productId, equals(json['productId']));
      expect(ratingSummaryModel.averageRating, equals(json['averageRating']));
      expect(ratingSummaryModel.totalRatings, equals(json['totalRatings']));
      expect(ratingSummaryModel.ratingDistribution, equals({1: 1, 2: 1, 3: 1, 4: 2, 5: 5}));
    });
    
    test('should convert RatingSummaryModel to JSON', () {
      // Arrange
      final ratingSummaryModel = RatingSummaryModel(
        productId: 'product-456',
        averageRating: 4.2,
        totalRatings: 10,
        ratingDistribution: {1: 1, 2: 1, 3: 1, 4: 2, 5: 5},
      );
      
      // Act
      final json = ratingSummaryModel.toJson();
      
      // Assert
      expect(json['productId'], equals(ratingSummaryModel.productId));
      expect(json['averageRating'], equals(ratingSummaryModel.averageRating));
      expect(json['totalRatings'], equals(ratingSummaryModel.totalRatings));
      expect(json['ratingDistribution'], equals({'1': 1, '2': 1, '3': 1, '4': 2, '5': 5}));
    });
  });
}
