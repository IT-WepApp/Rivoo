import 'package:dartz/dartz.dart';
import 'package:shared_libs/core/error/failures.dart';
import 'package:seller_panel/features/statistics/domain/entities/sales_statistics_entity.dart';
import 'package:seller_panel/features/statistics/domain/repositories/statistics_repository.dart';

/// حالة استخدام للحصول على إحصائيات المبيعات اليومية
class GetDailySalesStatisticsUseCase {
  final StatisticsRepository repository;

  GetDailySalesStatisticsUseCase(this.repository);

  /// تنفيذ حالة الاستخدام
  Future<Either<Failure, SalesStatisticsEntity>> call(
    String sellerId, {
    DateTime? date,
  }) {
    return repository.getDailySalesStatistics(sellerId, date: date);
  }
}
