import 'package:flutter/material.dart';
import 'package:user_app/features/ratings/domain/entities/rating.dart';
import 'package:user_app/core/architecture/domain/failure.dart';

/// نموذج التقييم
class RatingModel extends Rating {
  RatingModel({
    required String id,
    required String userId,
    required String productId,
    required double rating,
    required String comment,
    required DateTime createdAt,
  }) : super(
          id: id,
          userId: userId,
          productId: productId,
          rating: rating,
          comment: comment,
          createdAt: createdAt,
        );

  /// إنشاء نموذج من JSON
  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'],
      userId: json['userId'],
      productId: json['productId'],
      rating: json['rating'].toDouble(),
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  /// تحويل النموذج إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// نموذج ملخص التقييمات
class RatingSummaryModel extends RatingSummary {
  RatingSummaryModel({
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

  /// إنشاء نموذج من JSON
  factory RatingSummaryModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> distributionJson = json['ratingDistribution'];
    final Map<int, int> distribution = {};
    
    distributionJson.forEach((key, value) {
      distribution[int.parse(key)] = value;
    });
    
    return RatingSummaryModel(
      productId: json['productId'],
      averageRating: json['averageRating'].toDouble(),
      totalRatings: json['totalRatings'],
      ratingDistribution: distribution,
    );
  }

  /// تحويل النموذج إلى JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> distributionJson = {};
    
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
