import 'package:dartz/dartz.dart';
import 'package:seller_panel/core/error/failures.dart';
import 'package:seller_panel/features/statistics/domain/entities/sales_statistics_entity.dart';

/// واجهة مستودع الإحصائيات التي تحدد العمليات المتاحة على الإحصائيات
abstract class StatisticsRepository {
  /// الحصول على إحصائيات المبيعات اليومية
  Future<Either<Failure, SalesStatisticsEntity>> getDailySalesStatistics(
    String sellerId, {
    DateTime? date,
  });

  /// الحصول على إحصائيات المبيعات الأسبوعية
  Future<Either<Failure, SalesStatisticsEntity>> getWeeklySalesStatistics(
    String sellerId, {
    DateTime? startDate,
  });

  /// الحصول على إحصائيات المبيعات الشهرية
  Future<Either<Failure, SalesStatisticsEntity>> getMonthlySalesStatistics(
    String sellerId, {
    DateTime? month,
  });

  /// الحصول على إحصائيات المبيعات السنوية
  Future<Either<Failure, SalesStatisticsEntity>> getYearlySalesStatistics(
    String sellerId, {
    int? year,
  });

  /// الحصول على المنتجات الأكثر مبيعًا
  Future<Either<Failure, List<Map<String, dynamic>>>> getTopSellingProducts(
    String sellerId, {
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// الحصول على الفئات الأكثر مبيعًا
  Future<Either<Failure, List<Map<String, dynamic>>>> getTopSellingCategories(
    String sellerId, {
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  });
}
