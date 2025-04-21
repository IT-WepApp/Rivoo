import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/architecture/presentation/base_view_model.dart';
import '../domain/entities/rating.dart';
import '../domain/usecases/rating_usecases.dart';
import '../domain/repositories/rating_repository.dart';
import '../data/repositories/rating_repository_impl.dart';

class RatingViewModel extends BaseViewModel {
  final GetProductRatingsUseCase _getProductRatingsUseCase;
  final GetProductRatingSummaryUseCase _getProductRatingSummaryUseCase;
  final AddRatingUseCase _addRatingUseCase;
  final UpdateRatingUseCase _updateRatingUseCase;
  final DeleteRatingUseCase _deleteRatingUseCase;
  final GetUserRatingsUseCase _getUserRatingsUseCase;
  final HasUserRatedProductUseCase _hasUserRatedProductUseCase;
  final GetUserRatingForProductUseCase _getUserRatingForProductUseCase;

  RatingViewModel({
    required GetProductRatingsUseCase getProductRatingsUseCase,
    required GetProductRatingSummaryUseCase getProductRatingSummaryUseCase,
    required AddRatingUseCase addRatingUseCase,
    required UpdateRatingUseCase updateRatingUseCase,
    required DeleteRatingUseCase deleteRatingUseCase,
    required GetUserRatingsUseCase getUserRatingsUseCase,
    required HasUserRatedProductUseCase hasUserRatedProductUseCase,
    required GetUserRatingForProductUseCase getUserRatingForProductUseCase,
  })  : _getProductRatingsUseCase = getProductRatingsUseCase,
        _getProductRatingSummaryUseCase = getProductRatingSummaryUseCase,
        _addRatingUseCase = addRatingUseCase,
        _updateRatingUseCase = updateRatingUseCase,
        _deleteRatingUseCase = deleteRatingUseCase,
        _getUserRatingsUseCase = getUserRatingsUseCase,
        _hasUserRatedProductUseCase = hasUserRatedProductUseCase,
        _getUserRatingForProductUseCase = getUserRatingForProductUseCase,
        super();

  List<Rating> _productRatings = [];
  List<Rating> get productRatings => _productRatings;

  RatingSummary? _ratingSummary;
  RatingSummary? get ratingSummary => _ratingSummary;

  List<Rating> _userRatings = [];
  List<Rating> get userRatings => _userRatings;

  Rating? _userRatingForProduct;
  Rating? get userRatingForProduct => _userRatingForProduct;

  bool _hasUserRated = false;
  bool get hasUserRated => _hasUserRated;

  Future<void> getProductRatings(String productId) async {
    setLoading(true);
    final result = await _getProductRatingsUseCase(productId);
    result.fold(
      (failure) => setError(failure.message),
      (ratings) {
        _productRatings = ratings;
        setLoading(false);
      },
    );
  }

  Future<void> getProductRatingSummary(String productId) async {
    setLoading(true);
    final result = await _getProductRatingSummaryUseCase(productId);
    result.fold(
      (failure) => setError(failure.message),
      (summary) {
        _ratingSummary = summary;
        setLoading(false);
      },
    );
  }

  Future<void> addRating({
    required String productId,
    required double rating,
    String? review,
  }) async {
    setLoading(true);
    final params = AddRatingParams(
      productId: productId,
      rating: rating,
      review: review,
    );
    final result = await _addRatingUseCase(params);
    result.fold(
      (failure) => setError(failure.message),
      (newRating) {
        _userRatingForProduct = newRating;
        _hasUserRated = true;
        getProductRatings(productId);
        getProductRatingSummary(productId);
      },
    );
  }

  Future<void> updateRating({
    required String ratingId,
    required double rating,
    String? review,
  }) async {
    setLoading(true);
    final params = UpdateRatingParams(
      ratingId: ratingId,
      rating: rating,
      review: review,
    );
    final result = await _updateRatingUseCase(params);
    result.fold(
      (failure) => setError(failure.message),
      (updatedRating) {
        _userRatingForProduct = updatedRating;

        // تحديث القوائم المحلية
        if (_userRatingForProduct != null) {
          final productId = _userRatingForProduct!.productId;
          getProductRatings(productId);
          getProductRatingSummary(productId);
          getUserRatings();
        }
      },
    );
  }

  Future<void> deleteRating(String ratingId) async {
    setLoading(true);
    final productId = _userRatingForProduct?.productId;
    final result = await _deleteRatingUseCase(ratingId);
    result.fold(
      (failure) => setError(failure.message),
      (_) {
        _userRatingForProduct = null;
        _hasUserRated = false;

        // تحديث القوائم المحلية
        if (productId != null) {
          getProductRatings(productId);
          getProductRatingSummary(productId);
          getUserRatings();
        }
      },
    );
  }

  Future<void> getUserRatings() async {
    setLoading(true);
    final result = await _getUserRatingsUseCase(NoParams());
    result.fold(
      (failure) => setError(failure.message),
      (ratings) {
        _userRatings = ratings;
        setLoading(false);
      },
    );
  }

  Future<void> checkIfUserRatedProduct(String productId) async {
    setLoading(true);
    final result = await _hasUserRatedProductUseCase(productId);
    result.fold(
      (failure) => setError(failure.message),
      (hasRated) {
        _hasUserRated = hasRated;
        setLoading(false);
      },
    );
  }

  Future<void> getUserRatingForProduct(String productId) async {
    setLoading(true);
    final result = await _getUserRatingForProductUseCase(productId);
    result.fold(
      (failure) => setError(failure.message),
      (rating) {
        _userRatingForProduct = rating;
        _hasUserRated = rating != null;
        setLoading(false);
      },
    );
  }

  Future<void> loadProductRatingData(String productId) async {
    setLoading(true);
    await Future.wait([
      getProductRatings(productId),
      getProductRatingSummary(productId),
      getUserRatingForProduct(productId),
    ]);
    setLoading(false);
  }
}

// Providers
final ratingRepositoryProvider = Provider<RatingRepository>((ref) {
  return RatingRepositoryImpl(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    uuid: const Uuid(),
  );
});

final getProductRatingsUseCaseProvider =
    Provider<GetProductRatingsUseCase>((ref) {
  return GetProductRatingsUseCase(ref.watch(ratingRepositoryProvider));
});

final getProductRatingSummaryUseCaseProvider =
    Provider<GetProductRatingSummaryUseCase>((ref) {
  return GetProductRatingSummaryUseCase(ref.watch(ratingRepositoryProvider));
});

final addRatingUseCaseProvider = Provider<AddRatingUseCase>((ref) {
  return AddRatingUseCase(ref.watch(ratingRepositoryProvider));
});

final updateRatingUseCaseProvider = Provider<UpdateRatingUseCase>((ref) {
  return UpdateRatingUseCase(ref.watch(ratingRepositoryProvider));
});

final deleteRatingUseCaseProvider = Provider<DeleteRatingUseCase>((ref) {
  return DeleteRatingUseCase(ref.watch(ratingRepositoryProvider));
});

final getUserRatingsUseCaseProvider = Provider<GetUserRatingsUseCase>((ref) {
  return GetUserRatingsUseCase(ref.watch(ratingRepositoryProvider));
});

final hasUserRatedProductUseCaseProvider =
    Provider<HasUserRatedProductUseCase>((ref) {
  return HasUserRatedProductUseCase(ref.watch(ratingRepositoryProvider));
});

final getUserRatingForProductUseCaseProvider =
    Provider<GetUserRatingForProductUseCase>((ref) {
  return GetUserRatingForProductUseCase(ref.watch(ratingRepositoryProvider));
});

final ratingViewModelProvider = ChangeNotifierProvider<RatingViewModel>((ref) {
  return RatingViewModel(
    getProductRatingsUseCase: ref.watch(getProductRatingsUseCaseProvider),
    getProductRatingSummaryUseCase:
        ref.watch(getProductRatingSummaryUseCaseProvider),
    addRatingUseCase: ref.watch(addRatingUseCaseProvider),
    updateRatingUseCase: ref.watch(updateRatingUseCaseProvider),
    deleteRatingUseCase: ref.watch(deleteRatingUseCaseProvider),
    getUserRatingsUseCase: ref.watch(getUserRatingsUseCaseProvider),
    hasUserRatedProductUseCase: ref.watch(hasUserRatedProductUseCaseProvider),
    getUserRatingForProductUseCase:
        ref.watch(getUserRatingForProductUseCaseProvider),
  );
});
