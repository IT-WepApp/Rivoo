import 'package:equatable/equatable.dart';

class Rating extends Equatable {
  final String id;
  final String userId;
  final String productId;
  final double rating;
  final String? review;
  final DateTime createdAt;
  final String? userDisplayName;
  final bool isVerifiedPurchase;

  const Rating({
    required this.id,
    required this.userId,
    required this.productId,
    required this.rating,
    this.review,
    required this.createdAt,
    this.userDisplayName,
    required this.isVerifiedPurchase,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        productId,
        rating,
        review,
        createdAt,
        userDisplayName,
        isVerifiedPurchase,
      ];
}

class RatingSummary extends Equatable {
  final String productId;
  final double averageRating;
  final int totalRatings;
  final Map<int, int> ratingDistribution;

  const RatingSummary({
    required this.productId,
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
  });

  @override
  List<Object?> get props => [
        productId,
        averageRating,
        totalRatings,
        ratingDistribution,
      ];
}
