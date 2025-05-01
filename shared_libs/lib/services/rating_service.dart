import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/rating_entity.dart'; // Updated import
import '../utils/logger.dart'; // Assuming logger exists
import 'package:dartz/dartz.dart'; // For Either type
import '../core/failure.dart'; // Assuming a Failure class exists or needs creation

// --- Provider --- (Define where appropriate)

/// مزود خدمة التقييمات الموحدة
final ratingServiceProvider = Provider<RatingService>((ref) {
  return RatingService(
    firestore: FirebaseFirestore.instance,
  );
});

// --- Service Implementation ---

/// خدمة التقييمات والمراجعات الموحدة
class RatingService {
  final FirebaseFirestore _firestore;
  final AppLogger _logger = AppLogger(); // Assuming AppLogger exists

  RatingService({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  /// مجموعة التقييمات في Firestore
  CollectionReference get _ratingsCollection => _firestore.collection('ratings');

  /// إضافة تقييم جديد
  Future<Either<Failure, RatingEntity>> addRating(RatingEntity rating) async {
    try {
      // استخدام ID الكيان أو السماح لـ Firestore بتوليد واحد
      final docRef = _ratingsCollection.doc(rating.id);
      await docRef.set({
        'productId': rating.productId,
        'userId': rating.userId,
        'userName': rating.userName,
        'userImage': rating.userImage,
        'rating': rating.rating,
        'comment': rating.comment,
        'images': rating.images,
        'isApproved': rating.isApproved,
        'isVerifiedPurchase': rating.isVerifiedPurchase,
        'createdAt': Timestamp.fromDate(rating.createdAt),
        'updatedAt': Timestamp.fromDate(rating.updatedAt),
      });
      // قراءة البيانات مرة أخرى للتأكد من نجاح العملية والحصول على أي بيانات مولدة من السيرفر
      final snapshot = await docRef.get();
      final addedRating = _mapDocumentToRatingEntity(snapshot);
      _logger.info('Rating ${addedRating.id} added successfully for product ${rating.productId}');
      return Right(addedRating);
    } catch (e) {
      _logger.error('Failed to add rating for product ${rating.productId}', e, StackTrace.current);
      return Left(ServerFailure(message: 'فشل إضافة التقييم: $e'));
    }
  }

  /// الحصول على تقييمات منتج معين
  Future<Either<Failure, List<RatingEntity>>> getRatings(String productId) async {
    try {
      final querySnapshot = await _ratingsCollection
          .where('productId', isEqualTo: productId)
          .where('isApproved', isEqualTo: true) // عرض التقييمات المعتمدة فقط عادةً
          .orderBy('createdAt', descending: true)
          .get();

      final ratings = querySnapshot.docs.map((doc) {
        return _mapDocumentToRatingEntity(doc);
      }).toList();
      _logger.fine('Fetched ${ratings.length} ratings for product $productId');
      return Right(ratings);
    } catch (e) {
      _logger.error('Failed to fetch ratings for product $productId', e, StackTrace.current);
      return Left(ServerFailure(message: 'فشل الحصول على التقييمات: $e'));
    }
  }

  /// الحصول على ملخص التقييمات لمنتج معين
  Future<Either<Failure, RatingSummary>> getRatingSummary(String productId) async {
    try {
      final querySnapshot = await _ratingsCollection
          .where('productId', isEqualTo: productId)
          .where('isApproved', isEqualTo: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return Right(RatingSummary(
          productId: productId,
          averageRating: 0.0,
          totalRatings: 0,
          ratingCounts: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        ));
      }

      double totalRating = 0;
      final counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final ratingValue = (data['rating'] as num?)?.toDouble() ?? 0.0;
        totalRating += ratingValue;
        final ratingInt = ratingValue.round().clamp(1, 5);
        counts[ratingInt] = (counts[ratingInt] ?? 0) + 1;
      }

      final average = totalRating / querySnapshot.docs.length;
      final summary = RatingSummary(
        productId: productId,
        averageRating: average,
        totalRatings: querySnapshot.docs.length,
        ratingCounts: counts,
      );
      _logger.fine('Calculated rating summary for product $productId');
      return Right(summary);
    } catch (e) {
      _logger.error('Failed to calculate rating summary for product $productId', e, StackTrace.current);
      return Left(ServerFailure(message: 'فشل حساب ملخص التقييمات: $e'));
    }
  }

  /// تحديث تقييم موجود (إذا كان المستخدم هو المالك)
  Future<Either<Failure, RatingEntity>> updateRating(RatingEntity rating) async {
    try {
      final docRef = _ratingsCollection.doc(rating.id);
      // يمكنك إضافة تحقق هنا للتأكد من أن المستخدم الحالي هو مالك التقييم
      // final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      // if (currentUserId != rating.userId) { ... }

      await docRef.update({
        'rating': rating.rating,
        'comment': rating.comment,
        'images': rating.images,
        'updatedAt': FieldValue.serverTimestamp(), // تحديث وقت التعديل
        // لا تقم بتحديث isApproved هنا عادةً، هذا للمشرف
      });
      final snapshot = await docRef.get();
      final updatedRating = _mapDocumentToRatingEntity(snapshot);
      _logger.info('Rating ${rating.id} updated successfully.');
      return Right(updatedRating);
    } catch (e) {
      _logger.error('Failed to update rating ${rating.id}', e, StackTrace.current);
       if (e is FirebaseException && e.code == 'not-found') {
         return Left(NotFoundFailure(message: 'التقييم غير موجود.'));
       }
      return Left(ServerFailure(message: 'فشل تحديث التقييم: $e'));
    }
  }

  /// حذف تقييم (إذا كان المستخدم هو المالك أو مشرف)
  Future<Either<Failure, bool>> deleteRating(String ratingId, String userId) async {
    try {
      final docRef = _ratingsCollection.doc(ratingId);
      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        _logger.warning('Attempted to delete non-existent rating $ratingId');
        return Left(NotFoundFailure(message: 'التقييم غير موجود.'));
      }

      final data = snapshot.data() as Map<String, dynamic>;
      // التحقق من الملكية (أو إذا كان المستخدم مشرفًا)
      // final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      // final isAdmin = ... // تحقق من دور المستخدم
      if (data['userId'] != userId /* && !isAdmin */) {
         _logger.warning('User $userId attempted to delete rating $ratingId owned by ${data['userId']}');
         return Left(PermissionFailure(message: 'ليس لديك الصلاحية لحذف هذا التقييم.'));
      }

      await docRef.delete();
      _logger.info('Rating $ratingId deleted successfully by user $userId.');
      return const Right(true);
    } catch (e) {
      _logger.error('Failed to delete rating $ratingId', e, StackTrace.current);
      return Left(ServerFailure(message: 'فشل حذف التقييم: $e'));
    }
  }

  // --- Helper Method ---

  /// تحويل وثيقة Firestore إلى RatingEntity
  RatingEntity _mapDocumentToRatingEntity(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>; // Cast for safety
    return RatingEntity(
      id: doc.id,
      productId: data['productId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userImage: data['userImage'] as String?,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      comment: data['comment'] as String?,
      images: data['images'] != null ? List<String>.from(data['images']) : null,
      isApproved: data['isApproved'] ?? false,
      isVerifiedPurchase: data['isVerifiedPurchase'] ?? false,
      createdAt: (data['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp? ?? Timestamp.now()).toDate(),
    );
  }
}

// --- Failure Classes (Define in core/failure.dart or similar) ---
// Example:
// abstract class Failure extends Equatable {
//   final String message;
//   const Failure({required this.message});
//   @override List<Object> get props => [message];
// }
// class ServerFailure extends Failure { const ServerFailure({required String message}) : super(message: message); }
// class NotFoundFailure extends Failure { const NotFoundFailure({required String message}) : super(message: message); }
// class PermissionFailure extends Failure { const PermissionFailure({required String message}) : super(message: message); }

