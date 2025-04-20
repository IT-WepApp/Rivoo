import 'package:dartz/dartz.dart';
import '../../../../core/architecture/domain/failure.dart';
import '../entities/rating.dart';

abstract class RatingRepository {
  /// الحصول على تقييمات منتج معين
  Future<Either<Failure, List<Rating>>> getProductRatings(String productId);
  
  /// الحصول على ملخص تقييمات منتج معين
  Future<Either<Failure, RatingSummary>> getProductRatingSummary(String productId);
  
  /// إضافة تقييم جديد لمنتج
  Future<Either<Failure, Rating>> addRating({
    required String productId,
    required double rating,
    String? review,
  });
  
  /// تحديث تقييم موجود
  Future<Either<Failure, Rating>> updateRating({
    required String ratingId,
    required double rating,
    String? review,
  });
  
  /// حذف تقييم
  Future<Either<Failure, Unit>> deleteRating(String ratingId);
  
  /// الحصول على تقييمات المستخدم الحالي
  Future<Either<Failure, List<Rating>>> getUserRatings();
  
  /// التحقق مما إذا كان المستخدم قد قام بتقييم منتج معين
  Future<Either<Failure, bool>> hasUserRatedProduct(String productId);
  
  /// الحصول على تقييم المستخدم لمنتج معين
  Future<Either<Failure, Rating?>> getUserRatingForProduct(String productId);
}
