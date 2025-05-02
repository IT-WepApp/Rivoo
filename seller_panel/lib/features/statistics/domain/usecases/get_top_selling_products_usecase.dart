import 'package:dartz/dartz.dart';
import 'package:shared_libs/core/error/failures.dart';
import 'package:seller_panel/features/statistics/domain/repositories/statistics_repository.dart';

/// حالة استخدام للحصول على المنتجات الأكثر مبيعًا
class GetTopSellingProductsUseCase {
  final StatisticsRepository repository;

  GetTopSellingProductsUseCase(this.repository);

  /// تنفيذ حالة الاستخدام
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    String sellerId, {
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return repository.getTopSellingProducts(
      sellerId,
      limit: limit,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
