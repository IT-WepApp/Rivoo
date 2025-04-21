import '../domain/entities/rating.dart';

class RatingModel extends Rating {
  const RatingModel({
    required String id,
    required String userId,
    required String productId,
    required double rating,
    String? review,
    required DateTime createdAt,
    String? userDisplayName,
    required bool isVerifiedPurchase,
  }) : super(
          id: id,
          userId: userId,
          productId: productId,
          rating: rating,
          review: review,
          createdAt: createdAt,
          userDisplayName: userDisplayName,
          isVerifiedPurchase: isVerifiedPurchase,
        );

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      productId: json['productId'] as String,
      rating: (json['rating'] as num).toDouble(),
      review: json['review'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userDisplayName: json['userDisplayName'] as String?,
      isVerifiedPurchase: json['isVerifiedPurchase'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'rating': rating,
      'review': review,
      'createdAt': createdAt.toIso8601String(),
      'userDisplayName': userDisplayName,
      'isVerifiedPurchase': isVerifiedPurchase,
    };
  }
}

class RatingSummaryModel extends RatingSummary {
  const RatingSummaryModel({
    required String productId,
    required double averageRating,
    required int totalRatings,
    required Map<int, int> ratingDistribution,
  }) : super(
          productId: productId,
          averageRating: averageRating,
          totalRatings: totalRatings,
          ratingDistribution: ratingDistribution,
        );

  factory RatingSummaryModel.fromJson(Map<String, dynamic> json) {
    final distributionJson = json['ratingDistribution'] as Map<String, dynamic>;
    final distribution = <int, int>{};

    distributionJson.forEach((key, value) {
      distribution[int.parse(key)] = value as int;
    });

    return RatingSummaryModel(
      productId: json['productId'] as String,
      averageRating: (json['averageRating'] as num).toDouble(),
      totalRatings: json['totalRatings'] as int,
      ratingDistribution: distribution,
    );
  }

  Map<String, dynamic> toJson() {
    final distributionJson = <String, dynamic>{};
    ratingDistribution.forEach((key, value) {
      distributionJson[key.toString()] = value;
    });

    return {
      'productId': productId,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'ratingDistribution': distributionJson,
    };
  }
}
