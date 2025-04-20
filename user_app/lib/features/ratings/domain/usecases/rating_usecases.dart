import 'package:dartz/dartz.dart';
import '../repositories/rating_repository.dart';
import '../../../../core/architecture/domain/failure.dart';
import '../../../../core/architecture/domain/usecase.dart';
import '../entities/rating.dart';

class GetProductRatingsUseCase implements UseCase<List<Rating>, String> {
  final RatingRepository repository;

  GetProductRatingsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Rating>>> call(String productId) {
    return repository.getProductRatings(productId);
  }
}

class GetProductRatingSummaryUseCase implements UseCase<RatingSummary, String> {
  final RatingRepository repository;

  GetProductRatingSummaryUseCase(this.repository);

  @override
  Future<Either<Failure, RatingSummary>> call(String productId) {
    return repository.getProductRatingSummary(productId);
  }
}

class AddRatingUseCase implements UseCase<Rating, AddRatingParams> {
  final RatingRepository repository;

  AddRatingUseCase(this.repository);

  @override
  Future<Either<Failure, Rating>> call(AddRatingParams params) {
    return repository.addRating(
      productId: params.productId,
      rating: params.rating,
      review: params.review,
    );
  }
}

class AddRatingParams {
  final String productId;
  final double rating;
  final String? review;

  AddRatingParams({
    required this.productId,
    required this.rating,
    this.review,
  });
}

class UpdateRatingUseCase implements UseCase<Rating, UpdateRatingParams> {
  final RatingRepository repository;

  UpdateRatingUseCase(this.repository);

  @override
  Future<Either<Failure, Rating>> call(UpdateRatingParams params) {
    return repository.updateRating(
      ratingId: params.ratingId,
      rating: params.rating,
      review: params.review,
    );
  }
}

class UpdateRatingParams {
  final String ratingId;
  final double rating;
  final String? review;

  UpdateRatingParams({
    required this.ratingId,
    required this.rating,
    this.review,
  });
}

class DeleteRatingUseCase implements UseCase<Unit, String> {
  final RatingRepository repository;

  DeleteRatingUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String ratingId) {
    return repository.deleteRating(ratingId);
  }
}

class GetUserRatingsUseCase implements UseCase<List<Rating>, NoParams> {
  final RatingRepository repository;

  GetUserRatingsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Rating>>> call(NoParams params) {
    return repository.getUserRatings();
  }
}

class HasUserRatedProductUseCase implements UseCase<bool, String> {
  final RatingRepository repository;

  HasUserRatedProductUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String productId) {
    return repository.hasUserRatedProduct(productId);
  }
}

class GetUserRatingForProductUseCase implements UseCase<Rating?, String> {
  final RatingRepository repository;

  GetUserRatingForProductUseCase(this.repository);

  @override
  Future<Either<Failure, Rating?>> call(String productId) {
    return repository.getUserRatingForProduct(productId);
  }
}
