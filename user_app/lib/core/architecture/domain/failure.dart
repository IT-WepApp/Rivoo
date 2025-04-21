import 'package:flutter/material.dart';
import 'package:user_app/core/architecture/domain/failure.dart';
import 'package:user_app/features/ratings/domain/entities/rating.dart';
import 'package:dartz/dartz.dart';

/// واجهة مستودع التقييمات
abstract class RatingRepository {
  /// الحصول على تقييمات منتج معين
  Future<Either<Failure, List<Rating>>> getRatingsForProduct(String productId);

  /// الحصول على تقييم محدد
  Future<Either<Failure, Rating>> getRating(String ratingId);

  /// إضافة تقييم جديد
  Future<Either<Failure, Rating>> addRating({
    required String userId,
    required String productId,
    required String userName,
    required double rating,
    required String comment,
  });

  /// تحديث تقييم موجود
  Future<Either<Failure, Rating>> updateRating({
    required String ratingId,
    required double rating,
    required String comment,
  });

  /// حذف تقييم
  Future<Either<Failure, Unit>> deleteRating(String ratingId);

  /// الحصول على متوسط التقييم لمنتج معين
  Future<Either<Failure, double>> getAverageRating(String productId);
}
