import 'package:dartz/dartz.dart';
import 'package:seller_panel/core/error/failures.dart';
import 'package:seller_panel/features/promotions/domain/entities/promotion_entity.dart';
import 'package:seller_panel/features/promotions/domain/repositories/promotion_repository.dart';

/// حالة استخدام لتحديث عرض موجود
class UpdatePromotionUseCase {
  final PromotionRepository repository;

  UpdatePromotionUseCase(this.repository);

  /// تنفيذ حالة الاستخدام
  Future<Either<Failure, PromotionEntity>> call(PromotionEntity promotion) {
    return repository.updatePromotion(promotion);
  }
}
