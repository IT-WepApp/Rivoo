import 'package:dartz/dartz.dart';
import 'package:shared_libs/core/error/failures.dart';
import 'package:shared_libs/models/promotion.dart';
import 'package:seller_panel/features/promotions/domain/repositories/promotion_repository.dart';

/// حالة استخدام للحصول على قائمة العروض للبائع
class GetPromotionsUseCase {
  final PromotionRepository repository;

  GetPromotionsUseCase(this.repository);

  /// تنفيذ حالة الاستخدام
  Future<Either<Failure, List<PromotionEntity>>> call(String sellerId) {
    return repository.getPromotions(sellerId);
  }
}
