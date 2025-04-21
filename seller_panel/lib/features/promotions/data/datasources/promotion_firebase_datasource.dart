import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seller_panel/features/promotions/domain/entities/promotion_entity.dart';

/// مصدر بيانات Firebase للعروض
abstract class PromotionFirebaseDataSource {
  /// الحصول على قائمة العروض للبائع
  Future<List<PromotionEntity>> getPromotions(String sellerId);

  /// الحصول على تفاصيل عرض محدد
  Future<PromotionEntity> getPromotionDetails(String promotionId);

  /// إنشاء عرض جديد
  Future<PromotionEntity> createPromotion(PromotionEntity promotion);

  /// تحديث عرض موجود
  Future<PromotionEntity> updatePromotion(PromotionEntity promotion);

  /// حذف عرض
  Future<bool> deletePromotion(String promotionId);

  /// تفعيل أو تعطيل عرض
  Future<PromotionEntity> togglePromotionStatus(
      String promotionId, bool isActive);
}

/// تنفيذ مصدر بيانات Firebase للعروض
class PromotionFirebaseDataSourceImpl implements PromotionFirebaseDataSource {
  final FirebaseFirestore _firestore;

  PromotionFirebaseDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<PromotionEntity>> getPromotions(String sellerId) async {
    final querySnapshot = await _firestore
        .collection('promotions')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('startDate', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => _convertToPromotionEntity(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<PromotionEntity> getPromotionDetails(String promotionId) async {
    final docSnapshot =
        await _firestore.collection('promotions').doc(promotionId).get();

    if (!docSnapshot.exists) {
      throw Exception('العرض غير موجود');
    }

    return _convertToPromotionEntity(docSnapshot.id, docSnapshot.data()!);
  }

  @override
  Future<PromotionEntity> createPromotion(PromotionEntity promotion) async {
    final promotionData = _convertToMap(promotion);

    // حذف الـ ID لأنه سيتم إنشاؤه تلقائيًا
    promotionData.remove('id');

    // إضافة طوابع زمنية للإنشاء والتحديث
    promotionData['createdAt'] = FieldValue.serverTimestamp();
    promotionData['updatedAt'] = FieldValue.serverTimestamp();

    final docRef = await _firestore.collection('promotions').add(promotionData);

    return getPromotionDetails(docRef.id);
  }

  @override
  Future<PromotionEntity> updatePromotion(PromotionEntity promotion) async {
    final promotionData = _convertToMap(promotion);

    // إضافة طابع زمني للتحديث
    promotionData['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore
        .collection('promotions')
        .doc(promotion.id)
        .update(promotionData);

    return getPromotionDetails(promotion.id);
  }

  @override
  Future<bool> deletePromotion(String promotionId) async {
    await _firestore.collection('promotions').doc(promotionId).delete();
    return true;
  }

  @override
  Future<PromotionEntity> togglePromotionStatus(
      String promotionId, bool isActive) async {
    await _firestore.collection('promotions').doc(promotionId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return getPromotionDetails(promotionId);
  }

  /// تحويل بيانات Firestore إلى كيان العرض
  PromotionEntity _convertToPromotionEntity(
      String id, Map<String, dynamic> data) {
    List<String> applicableProductIds = [];

    if (data.containsKey('applicableProductIds') &&
        data['applicableProductIds'] is List) {
      applicableProductIds = List<String>.from(data['applicableProductIds']);
    }

    return PromotionEntity(
      id: id,
      sellerId: data['sellerId'],
      title: data['title'],
      description: data['description'],
      type: data['type'],
      value: (data['value'] as num).toDouble(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      applicableProductIds: applicableProductIds,
      isActive: data['isActive'] ?? false,
      usageLimit: data['usageLimit'] != null
          ? (data['usageLimit'] as num).toInt()
          : null,
      usageCount: data['usageCount'] != null
          ? (data['usageCount'] as num).toInt()
          : null,
      code: data['code'],
      minimumOrderAmount: data['minimumOrderAmount'] != null
          ? (data['minimumOrderAmount'] as num).toDouble()
          : null,
    );
  }

  /// تحويل كيان العرض إلى Map لتخزينه في Firestore
  Map<String, dynamic> _convertToMap(PromotionEntity promotion) {
    return {
      'id': promotion.id,
      'sellerId': promotion.sellerId,
      'title': promotion.title,
      'description': promotion.description,
      'type': promotion.type,
      'value': promotion.value,
      'startDate': Timestamp.fromDate(promotion.startDate),
      'endDate': Timestamp.fromDate(promotion.endDate),
      'applicableProductIds': promotion.applicableProductIds,
      'isActive': promotion.isActive,
      'usageLimit': promotion.usageLimit,
      'usageCount': promotion.usageCount,
      'code': promotion.code,
      'minimumOrderAmount': promotion.minimumOrderAmount,
    };
  }
}
