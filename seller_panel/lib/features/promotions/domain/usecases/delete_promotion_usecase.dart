import 'package:dartz/dartz.dart';
import 'package:seller_panel/core/error/failures.dart';
import 'package:seller_panel/features/promotions/domain/repositories/promotion_repository.dart';

/// حالة استخدام لحذف عرض
class DeletePromotionUseCase {
  final PromotionRepository repository;

  DeletePromotionUseCase(this.repository);

  /// تنفيذ حالة الاستخدام
  Future<Either<Failure, bool>> call(String promotionId) {
    return repository.deletePromotion(promotionId);
  }
}
