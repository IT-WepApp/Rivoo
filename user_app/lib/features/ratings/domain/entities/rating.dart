import 'package:flutter/material.dart';
import 'package:user_app/core/architecture/domain/entity.dart';
import 'package:user_app/core/architecture/domain/failure.dart';
import 'package:dartz/dartz.dart';

/// كيان التقييم
class Rating extends Entity {
  final String userId;
  final String productId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Rating({
    required String id,
    required this.userId,
    required this.productId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  }) : super(id: id);

  @override
  List<Object?> get props => [
        id,
        userId,
        productId,
        rating,
        comment,
        createdAt,
      ];
}

/// ملخص التقييمات
class RatingSummary {
  final String productId;
  final double averageRating;
  final int totalRatings;
  final Map<int, int> ratingDistribution;

  RatingSummary({
    required this.productId,
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
  });

  List<Object?> get props => [
        productId,
        averageRating,
        totalRatings,
        ratingDistribution,
      ];
}
