import 'package:dartz/dartz.dart';

import '../../../../core/architecture/domain/failure.dart';
import '../entities/rating.dart';

abstract class RatingRepository {
  /// يجلب تقييمات منتج معين
  Future<Either<Failure, List<Rating>>> getProductRatings(String productId);

  /// يجلب ملخص تقييمات منتج معين
  Future<Either<Failure, RatingSummary>> getProductRatingSummary(String productId);

  /// يضيف تقييم جديد لمنتج
  Future<Either<Failure, Rating>> addRating({
    required String productId,
    required double rating,
    String? review,
  });

  /// يحدث تقييم موجود
  Future<Either<Failure, Rating>> updateRating({
    required String ratingId,
    required double rating,
    String? review,
  });

  /// يحذف تقييم
  Future<Either<Failure, Unit>> deleteRating(String ratingId);

  /// يجلب تقييمات المستخدم الحالي
  Future<Either<Failure, List<Rating>>> getUserRatings();

  /// يتحقق مما إذا كان المستخدم قد قيم منتج معين
  Future<Either<Failure, bool>> hasUserRatedProduct(String productId);

  /// يجلب تقييم المستخدم لمنتج معين
  Future<Either<Failure, Rating?>> getUserRatingForProduct(String productId);
}
