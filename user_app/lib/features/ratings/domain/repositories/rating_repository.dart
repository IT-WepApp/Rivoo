import 'package:user_app/core/architecture/domain/failure.dart';
import 'package:user_app/features/ratings/data/datasources/rating_datasource.dart';
import 'package:dartz/dartz.dart';

/// واجهة مستودع التقييمات
abstract class RatingRepository {
  /// الحصول على تقييمات منتج معين
  Future<Either<Failure, List<Rating>>> getRatings(String productId);

  /// الحصول على ملخص تقييمات منتج معين
  Future<Either<Failure, RatingSummary>> getRatingSummary(String productId);

  /// إضافة تقييم جديد
  Future<Either<Failure, Rating>> addRating(Rating rating);

  /// تحديث تقييم موجود
  Future<Either<Failure, Rating>> updateRating(Rating rating);

  /// حذف تقييم
  Future<Either<Failure, bool>> deleteRating(String ratingId);
}
