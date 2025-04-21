import 'package:dartz/dartz.dart';
import 'package:seller_panel/core/error/exceptions.dart';
import 'package:seller_panel/core/error/failures.dart';
import 'package:seller_panel/features/promotions/data/datasources/promotion_firebase_datasource.dart';
import 'package:seller_panel/features/promotions/domain/entities/promotion_entity.dart';
import 'package:seller_panel/features/promotions/domain/repositories/promotion_repository.dart';

/// تنفيذ مستودع العروض
class PromotionRepositoryImpl implements PromotionRepository {
  final PromotionFirebaseDataSource dataSource;

  PromotionRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<PromotionEntity>>> getPromotions(
      String sellerId) async {
    try {
      final promotions = await dataSource.getPromotions(sellerId);
      return Right(promotions);
    } on ServerException {
      return const Left(ServerFailure());
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, PromotionEntity>> getPromotionDetails(
      String promotionId) async {
    try {
      final promotion = await dataSource.getPromotionDetails(promotionId);
      return Right(promotion);
    } on ServerException {
      return const Left(ServerFailure());
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, PromotionEntity>> createPromotion(
      PromotionEntity promotion) async {
    try {
      final createdPromotion = await dataSource.createPromotion(promotion);
      return Right(createdPromotion);
    } on ServerException {
      return const Left(ServerFailure());
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, PromotionEntity>> updatePromotion(
      PromotionEntity promotion) async {
    try {
      final updatedPromotion = await dataSource.updatePromotion(promotion);
      return Right(updatedPromotion);
    } on ServerException {
      return const Left(ServerFailure());
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deletePromotion(String promotionId) async {
    try {
      final result = await dataSource.deletePromotion(promotionId);
      return Right(result);
    } on ServerException {
      return const Left(ServerFailure());
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, PromotionEntity>> togglePromotionStatus(
      String promotionId, bool isActive) async {
    try {
      final updatedPromotion =
          await dataSource.togglePromotionStatus(promotionId, isActive);
      return Right(updatedPromotion);
    } on ServerException {
      return const Left(ServerFailure());
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }
}
