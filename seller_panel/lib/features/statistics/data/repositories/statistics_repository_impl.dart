import 'package:dartz/dartz.dart';
import 'package:seller_panel/core/error/exceptions.dart';
import 'package:seller_panel/core/error/failures.dart';
import 'package:seller_panel/features/statistics/data/datasources/statistics_firebase_datasource.dart';
import 'package:seller_panel/features/statistics/domain/entities/sales_statistics_entity.dart';
import 'package:seller_panel/features/statistics/domain/repositories/statistics_repository.dart';

/// تنفيذ مستودع الإحصائيات
class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsFirebaseDataSource dataSource;

  StatisticsRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, SalesStatisticsEntity>> getDailySalesStatistics(
    String sellerId, {
    DateTime? date,
  }) async {
    try {
      final statistics =
          await dataSource.getDailySalesStatistics(sellerId, date: date);
      return Right(statistics);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, SalesStatisticsEntity>> getWeeklySalesStatistics(
    String sellerId, {
    DateTime? startDate,
  }) async {
    try {
      final statistics = await dataSource.getWeeklySalesStatistics(sellerId,
          startDate: startDate);
      return Right(statistics);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, SalesStatisticsEntity>> getMonthlySalesStatistics(
    String sellerId, {
    DateTime? month,
  }) async {
    try {
      final statistics =
          await dataSource.getMonthlySalesStatistics(sellerId, month: month);
      return Right(statistics);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, SalesStatisticsEntity>> getYearlySalesStatistics(
    String sellerId, {
    int? year,
  }) async {
    try {
      final statistics =
          await dataSource.getYearlySalesStatistics(sellerId, year: year);
      return Right(statistics);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTopSellingProducts(
    String sellerId, {
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final products = await dataSource.getTopSellingProducts(
        sellerId,
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(products);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTopSellingCategories(
    String sellerId, {
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final categories = await dataSource.getTopSellingCategories(
        sellerId,
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(categories);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
}
