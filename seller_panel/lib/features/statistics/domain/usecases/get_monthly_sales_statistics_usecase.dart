import 'package:dartz/dartz.dart';
import 'package:shared_libs/core/error/failures.dart';
import 'package:seller_panel/features/statistics/domain/entities/sales_statistics_entity.dart';
import 'package:seller_panel/features/statistics/domain/repositories/statistics_repository.dart';

/// حالة استخدام للحصول على إحصائيات المبيعات الشهرية
class GetMonthlySalesStatisticsUseCase {
  final StatisticsRepository repository;

  GetMonthlySalesStatisticsUseCase(this.repository);

  /// تنفيذ حالة الاستخدام
  Future<Either<Failure, SalesStatisticsEntity>> call(
    String sellerId, {
    DateTime? month,
  }) {
    return repository.getMonthlySalesStatistics(sellerId, month: month);
  }
}
