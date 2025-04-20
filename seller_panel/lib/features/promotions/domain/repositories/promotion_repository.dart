import 'package:dartz/dartz.dart';
import 'package:seller_panel/core/error/failures.dart';
import 'package:seller_panel/features/promotions/domain/entities/promotion_entity.dart';

/// واجهة مستودع العروض التي تحدد العمليات المتاحة على العروض
abstract class PromotionRepository {
  /// الحصول على قائمة العروض للبائع
  Future<Either<Failure, List<PromotionEntity>>> getPromotions(String sellerId);

  /// الحصول على تفاصيل عرض محدد
  Future<Either<Failure, PromotionEntity>> getPromotionDetails(String promotionId);

  /// إنشاء عرض جديد
  Future<Either<Failure, PromotionEntity>> createPromotion(PromotionEntity promotion);

  /// تحديث عرض موجود
  Future<Either<Failure, PromotionEntity>> updatePromotion(PromotionEntity promotion);

  /// حذف عرض
  Future<Either<Failure, bool>> deletePromotion(String promotionId);

  /// تفعيل أو تعطيل عرض
  Future<Either<Failure, PromotionEntity>> togglePromotionStatus(String promotionId, bool isActive);
}
