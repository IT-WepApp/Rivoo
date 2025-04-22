import 'package:user_app/features/ratings/domain/entities/rating.dart';

/// واجهة مصدر البيانات البعيد للتقييمات
abstract class RatingRemoteDataSource {
  /// الحصول على تقييمات منتج معين
  Future<List<Rating>> getRatings(String productId);

  /// الحصول على ملخص تقييمات منتج معين
  Future<RatingSummary> getRatingSummary(String productId);

  /// إضافة تقييم جديد
  Future<Rating> addRating(Rating rating);

  /// تحديث تقييم موجود
  Future<Rating> updateRating(Rating rating);

  /// حذف تقييم
  Future<bool> deleteRating(String ratingId);
}

/// واجهة مصدر البيانات المحلي للتقييمات
abstract class RatingLocalDataSource {
  /// الحصول على تقييمات منتج معين من التخزين المحلي
  Future<List<Rating>> getCachedRatings(String productId);

  /// تخزين تقييمات منتج معين محلياً
  Future<void> cacheRatings(String productId, List<Rating> ratings);

  /// الحصول على ملخص تقييمات منتج معين من التخزين المحلي
  Future<RatingSummary> getCachedRatingSummary(String productId);

  /// تخزين ملخص تقييمات منتج معين محلياً
  Future<void> cacheRatingSummary(String productId, RatingSummary summary);
}

/// ملخص التقييمات
class RatingSummary {
  /// معرف المنتج
  final String productId;
  
  /// متوسط التقييم
  final double averageRating;
  
  /// إجمالي عدد التقييمات
  final int totalRatings;
  
  /// توزيع التقييمات (عدد التقييمات لكل نجمة)
  final Map<int, int> ratingDistribution;

  /// إنشاء ملخص التقييمات
  const RatingSummary({
    required this.productId,
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
  });
}
