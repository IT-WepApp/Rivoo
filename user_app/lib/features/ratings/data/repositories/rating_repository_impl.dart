import 'package:user_app/core/architecture/domain/failure.dart';
import 'package:user_app/features/ratings/data/datasources/rating_datasource.dart';
import 'package:user_app/features/ratings/domain/entities/rating.dart';
import 'package:user_app/features/ratings/domain/repositories/rating_repository.dart';
import 'package:dartz/dartz.dart';

/// تنفيذ مستودع التقييمات
class RatingRepositoryImpl implements RatingRepository {
  /// مصدر البيانات البعيد
  final RatingRemoteDataSource remoteDataSource;
  
  /// مصدر البيانات المحلي
  final RatingLocalDataSource localDataSource;

  /// إنشاء تنفيذ مستودع التقييمات
  RatingRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Rating>>> getRatings(String productId) async {
    try {
      final ratings = await remoteDataSource.getRatings(productId);
      return Right(ratings);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RatingSummary>> getRatingSummary(String productId) async {
    try {
      final summary = await remoteDataSource.getRatingSummary(productId);
      return Right(summary);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Rating>> addRating(Rating rating) async {
    try {
      final addedRating = await remoteDataSource.addRating(rating);
      return Right(addedRating);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Rating>> updateRating(Rating rating) async {
    try {
      final updatedRating = await remoteDataSource.updateRating(rating);
      return Right(updatedRating);
    } catch (e) {
      if (e.toString().contains('not found')) {
        return Left(NotFoundFailure(message: e.toString()));
      }
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteRating(String ratingId) async {
    try {
      final result = await remoteDataSource.deleteRating(ratingId);
      return Right(result);
    } catch (e) {
      if (e.toString().contains('not found')) {
        return Left(NotFoundFailure(message: e.toString()));
      }
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
