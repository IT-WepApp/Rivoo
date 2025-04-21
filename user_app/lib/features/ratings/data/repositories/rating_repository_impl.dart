import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/architecture/domain/failure.dart';
import '../domain/entities/rating.dart';
import '../domain/repositories/rating_repository.dart';
import '../models/rating_model.dart';

class RatingRepositoryImpl implements RatingRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Uuid _uuid;

  RatingRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    Uuid? uuid,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _uuid = uuid ?? const Uuid();

  @override
  Future<Either<Failure, List<Rating>>> getProductRatings(
      String productId) async {
    try {
      final ratingsSnapshot = await _firestore
          .collection('ratings')
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .get();

      final ratings = ratingsSnapshot.docs.map((doc) {
        final data = doc.data();
        return RatingModel.fromJson(data);
      }).toList();

      return Right(ratings);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RatingSummary>> getProductRatingSummary(
      String productId) async {
    try {
      final summaryDoc =
          await _firestore.collection('rating_summaries').doc(productId).get();

      if (!summaryDoc.exists) {
        // إذا لم يكن هناك ملخص، قم بإنشاء ملخص فارغ
        final emptySummary = RatingSummaryModel(
          productId: productId,
          averageRating: 0.0,
          totalRatings: 0,
          ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        );
        return Right(emptySummary);
      }

      final summaryData = summaryDoc.data()!;
      final summary = RatingSummaryModel.fromJson(summaryData);
      return Right(summary);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Rating>> addRating({
    required String productId,
    required double rating,
    String? review,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return const Left(AuthFailure(message: 'المستخدم غير مسجل الدخول'));
      }

      // التحقق مما إذا كان المستخدم قد قام بتقييم المنتج من قبل
      final existingRatingResult = await getUserRatingForProduct(productId);
      final hasExistingRating = existingRatingResult.fold(
        (failure) => false,
        (existingRating) => existingRating != null,
      );

      if (hasExistingRating) {
        return const Left(
            ValidationFailure(message: 'لقد قمت بتقييم هذا المنتج من قبل'));
      }

      // التحقق مما إذا كان المستخدم قد اشترى المنتج
      final isVerifiedPurchase =
          await _checkIfUserPurchasedProduct(userId, productId);

      // الحصول على اسم المستخدم
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final String? userDisplayName =
          userDoc.exists ? (userDoc.data()?['displayName'] as String?) : null;

      final ratingId = _uuid.v4();
      final now = DateTime.now();

      final newRating = RatingModel(
        id: ratingId,
        userId: userId,
        productId: productId,
        rating: rating,
        review: review,
        createdAt: now,
        userDisplayName: userDisplayName,
        isVerifiedPurchase: isVerifiedPurchase,
      );

      await _firestore
          .collection('ratings')
          .doc(ratingId)
          .set(newRating.toJson());

      // تحديث ملخص التقييمات
      await _updateRatingSummary(productId, rating, true);

      return Right(newRating);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Rating>> updateRating({
    required String ratingId,
    required double rating,
    String? review,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return const Left(AuthFailure(message: 'المستخدم غير مسجل الدخول'));
      }

      final ratingDoc =
          await _firestore.collection('ratings').doc(ratingId).get();

      if (!ratingDoc.exists) {
        return Left(NotFoundFailure(message: 'التقييم غير موجود'));
      }

      final ratingData = ratingDoc.data()!;
      if (ratingData['userId'] != userId) {
        return const Left(
            AuthFailure(message: 'ليس لديك صلاحية لتحديث هذا التقييم'));
      }

      final oldRating = RatingModel.fromJson(ratingData);
      final productId = oldRating.productId;

      // تحديث ملخص التقييمات (إزالة التقييم القديم وإضافة التقييم الجديد)
      await _updateRatingSummary(productId, oldRating.rating, false);
      await _updateRatingSummary(productId, rating, true);

      final updatedRating = RatingModel(
        id: ratingId,
        userId: userId,
        productId: productId,
        rating: rating,
        review: review,
        createdAt: oldRating.createdAt,
        userDisplayName: oldRating.userDisplayName,
        isVerifiedPurchase: oldRating.isVerifiedPurchase,
      );

      await _firestore.collection('ratings').doc(ratingId).update({
        'rating': rating,
        'review': review,
      });

      return Right(updatedRating);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteRating(String ratingId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return const Left(AuthFailure(message: 'المستخدم غير مسجل الدخول'));
      }

      final ratingDoc =
          await _firestore.collection('ratings').doc(ratingId).get();

      if (!ratingDoc.exists) {
        return Left(NotFoundFailure(message: 'التقييم غير موجود'));
      }

      final ratingData = ratingDoc.data()!;
      if (ratingData['userId'] != userId) {
        return const Left(
            AuthFailure(message: 'ليس لديك صلاحية لحذف هذا التقييم'));
      }

      final oldRating = RatingModel.fromJson(ratingData);
      final productId = oldRating.productId;

      // تحديث ملخص التقييمات (إزالة التقييم)
      await _updateRatingSummary(productId, oldRating.rating, false);

      await _firestore.collection('ratings').doc(ratingId).delete();

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Rating>>> getUserRatings() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return const Left(AuthFailure(message: 'المستخدم غير مسجل الدخول'));
      }

      final ratingsSnapshot = await _firestore
          .collection('ratings')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final ratings = ratingsSnapshot.docs.map((doc) {
        final data = doc.data();
        return RatingModel.fromJson(data);
      }).toList();

      return Right(ratings);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasUserRatedProduct(String productId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return const Left(AuthFailure(message: 'المستخدم غير مسجل الدخول'));
      }

      final ratingsSnapshot = await _firestore
          .collection('ratings')
          .where('userId', isEqualTo: userId)
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();

      return Right(ratingsSnapshot.docs.isNotEmpty);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Rating?>> getUserRatingForProduct(
      String productId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return const Left(AuthFailure(message: 'المستخدم غير مسجل الدخول'));
      }

      final ratingsSnapshot = await _firestore
          .collection('ratings')
          .where('userId', isEqualTo: userId)
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();

      if (ratingsSnapshot.docs.isEmpty) {
        return const Right(null);
      }

      final ratingData = ratingsSnapshot.docs.first.data();
      final rating = RatingModel.fromJson(ratingData);

      return Right(rating);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // Helper methods
  Future<bool> _checkIfUserPurchasedProduct(
      String userId, String productId) async {
    try {
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: ['delivered', 'shipped']).get();

      for (final orderDoc in ordersSnapshot.docs) {
        final orderData = orderDoc.data();
        final items = orderData['items'] as List<dynamic>;
        for (final item in items) {
          if (item['productId'] == productId) {
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _updateRatingSummary(
      String productId, double rating, bool isAdding) async {
    final summaryRef = _firestore.collection('rating_summaries').doc(productId);
    final summaryDoc = await summaryRef.get();

    if (!summaryDoc.exists && !isAdding) {
      // لا يوجد ملخص وليس هناك إضافة، لا شيء للتحديث
      return;
    }

    if (!summaryDoc.exists) {
      // إنشاء ملخص جديد
      final newSummary = RatingSummaryModel(
        productId: productId,
        averageRating: rating,
        totalRatings: 1,
        ratingDistribution: {
          1: rating == 1 ? 1 : 0,
          2: rating == 2 ? 1 : 0,
          3: rating == 3 ? 1 : 0,
          4: rating == 4 ? 1 : 0,
          5: rating == 5 ? 1 : 0,
        },
      );
      await summaryRef.set(newSummary.toJson());
      return;
    }

    // تحديث ملخص موجود
    await _firestore.runTransaction((transaction) async {
      final freshSummaryDoc = await transaction.get(summaryRef);
      final summaryData = freshSummaryDoc.data()!;
      final summary = RatingSummaryModel.fromJson(summaryData);

      final ratingInt = rating.round();
      final distribution = Map<int, int>.from(summary.ratingDistribution);

      if (isAdding) {
        distribution[ratingInt] = (distribution[ratingInt] ?? 0) + 1;
        final newTotalRatings = summary.totalRatings + 1;
        final newTotalScore =
            summary.averageRating * summary.totalRatings + rating;
        final newAverageRating = newTotalScore / newTotalRatings;

        transaction.update(summaryRef, {
          'averageRating': newAverageRating,
          'totalRatings': newTotalRatings,
          'ratingDistribution':
              distribution.map((key, value) => MapEntry(key.toString(), value)),
        });
      } else {
        distribution[ratingInt] = (distribution[ratingInt] ?? 1) - 1;
        final newTotalRatings = summary.totalRatings - 1;

        if (newTotalRatings <= 0) {
          // إذا لم يعد هناك تقييمات، قم بإعادة تعيين الملخص
          transaction.update(summaryRef, {
            'averageRating': 0.0,
            'totalRatings': 0,
            'ratingDistribution': {
              '1': 0,
              '2': 0,
              '3': 0,
              '4': 0,
              '5': 0,
            },
          });
        } else {
          final newTotalScore =
              summary.averageRating * summary.totalRatings - rating;
          final newAverageRating = newTotalScore / newTotalRatings;

          transaction.update(summaryRef, {
            'averageRating': newAverageRating,
            'totalRatings': newTotalRatings,
            'ratingDistribution': distribution
                .map((key, value) => MapEntry(key.toString(), value)),
          });
        }
      }
    });
  }
}
