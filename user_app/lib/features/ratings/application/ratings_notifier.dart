import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/features/auth/application/auth_notifier.dart';

class RatingModel {
  final String id;
  final String userId;
  final String targetId; // معرف المنتج أو المندوب
  final String targetType; // نوع الهدف (منتج أو مندوب)
  final double rating; // التقييم من 1 إلى 5
  final String? comment; // تعليق اختياري
  final DateTime createdAt;

  RatingModel({
    required this.id,
    required this.userId,
    required this.targetId,
    required this.targetType,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'targetId': targetId,
      'targetType': targetType,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }

  factory RatingModel.fromMap(String id, Map<String, dynamic> map) {
    return RatingModel(
      id: id,
      userId: map['userId'] ?? '',
      targetId: map['targetId'] ?? '',
      targetType: map['targetType'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}

class RatingsNotifier extends StateNotifier<AsyncValue<List<RatingModel>>> {
  final String? userId;
  final FirebaseFirestore _firestore;

  RatingsNotifier(this.userId, this._firestore) : super(const AsyncLoading()) {
    if (userId != null) {
      loadUserRatings();
    } else {
      state = const AsyncData([]);
    }
  }

  Future<void> loadUserRatings() async {
    if (userId == null) {
      state = const AsyncData([]);
      return;
    }

    state = const AsyncLoading();

    try {
      final snapshot = await _firestore
          .collection('ratings')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final ratings = snapshot.docs
          .map((doc) => RatingModel.fromMap(doc.id, doc.data()))
          .toList();

      state = AsyncData(ratings);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  Future<void> addRating({
    required String targetId,
    required String targetType,
    required double rating,
    String? comment,
  }) async {
    if (userId == null) return;

    try {
      // التحقق مما إذا كان المستخدم قد قام بتقييم هذا الهدف من قبل
      final existingRatingQuery = await _firestore
          .collection('ratings')
          .where('userId', isEqualTo: userId)
          .where('targetId', isEqualTo: targetId)
          .where('targetType', isEqualTo: targetType)
          .limit(1)
          .get();

      final ratingData = RatingModel(
        id: '', // سيتم تعيينه من Firestore
        userId: userId!,
        targetId: targetId,
        targetType: targetType,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      ).toMap();

      if (existingRatingQuery.docs.isNotEmpty) {
        // تحديث التقييم الموجود
        final existingRatingDoc = existingRatingQuery.docs.first;
        await _firestore
            .collection('ratings')
            .doc(existingRatingDoc.id)
            .update(ratingData);
      } else {
        // إضافة تقييم جديد
        await _firestore.collection('ratings').add(ratingData);
      }

      // تحديث متوسط التقييم للهدف
      await _updateAverageRating(targetId, targetType);

      // إعادة تحميل تقييمات المستخدم
      loadUserRatings();
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  Future<void> _updateAverageRating(String targetId, String targetType) async {
    try {
      // الحصول على جميع التقييمات للهدف
      final ratingsSnapshot = await _firestore
          .collection('ratings')
          .where('targetId', isEqualTo: targetId)
          .where('targetType', isEqualTo: targetType)
          .get();

      if (ratingsSnapshot.docs.isEmpty) return;

      // حساب متوسط التقييم
      double totalRating = 0;
      for (final doc in ratingsSnapshot.docs) {
        totalRating += (doc.data()['rating'] ?? 0.0).toDouble();
      }
      final averageRating = totalRating / ratingsSnapshot.docs.length;
      final ratingsCount = ratingsSnapshot.docs.length;

      // تحديث متوسط التقييم في المجموعة المناسبة
      final collectionName = targetType == 'product' ? 'products' : 'delivery_persons';
      await _firestore.collection(collectionName).doc(targetId).update({
        'averageRating': averageRating,
        'ratingsCount': ratingsCount,
      });
    } catch (e) {
      print('خطأ في تحديث متوسط التقييم: $e');
    }
  }

  Future<void> deleteRating(String ratingId) async {
    if (userId == null) return;

    try {
      // الحصول على معلومات التقييم قبل حذفه
      final ratingDoc = await _firestore.collection('ratings').doc(ratingId).get();
      if (!ratingDoc.exists) return;

      final ratingData = ratingDoc.data();
      if (ratingData == null) return;

      final targetId = ratingData['targetId'] as String?;
      final targetType = ratingData['targetType'] as String?;

      if (targetId == null || targetType == null) return;

      // حذف التقييم
      await _firestore.collection('ratings').doc(ratingId).delete();

      // تحديث متوسط التقييم للهدف
      await _updateAverageRating(targetId, targetType);

      // إعادة تحميل تقييمات المستخدم
      loadUserRatings();
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }
}

// مزود لتقييمات المستخدم
final userRatingsProvider = StateNotifierProvider<RatingsNotifier, AsyncValue<List<RatingModel>>>((ref) {
  final userId = ref.watch(userIdProvider);
  final firestore = FirebaseFirestore.instance;
  return RatingsNotifier(userId, firestore);
});

// مزود لمتوسط تقييم منتج معين
final productRatingProvider = FutureProvider.family<double, String>((ref, productId) async {
  final firestore = FirebaseFirestore.instance;
  final productDoc = await firestore.collection('products').doc(productId).get();
  
  if (!productDoc.exists) return 0.0;
  
  final data = productDoc.data();
  if (data == null) return 0.0;
  
  return (data['averageRating'] ?? 0.0).toDouble();
});

// مزود لمتوسط تقييم مندوب معين
final deliveryPersonRatingProvider = FutureProvider.family<double, String>((ref, deliveryPersonId) async {
  final firestore = FirebaseFirestore.instance;
  final deliveryPersonDoc = await firestore.collection('delivery_persons').doc(deliveryPersonId).get();
  
  if (!deliveryPersonDoc.exists) return 0.0;
  
  final data = deliveryPersonDoc.data();
  if (data == null) return 0.0;
  
  return (data['averageRating'] ?? 0.0).toDouble();
});
