import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:user_app/core/architecture/domain/entity.dart';

part 'payment_model.freezed.dart';
part 'payment_model.g.dart';

/// نموذج بيانات الدفع
/// يحتوي على معلومات عملية الدفع
@freezed
class PaymentModel with _$PaymentModel implements Entity {
  const PaymentModel._();

  /// إنشاء نموذج بيانات الدفع
  const factory PaymentModel({
    /// المعرف الفريد
    required String id,
    
    /// معرف المستخدم
    required String userId,
    
    /// معرف الطلب
    required String orderId,
    
    /// المبلغ
    required double amount,
    
    /// العملة
    required String currency,
    
    /// طريقة الدفع
    required PaymentMethod method,
    
    /// حالة الدفع
    required PaymentStatus status,
    
    /// معرف المعاملة من بوابة الدفع
    String? transactionId,
    
    /// رسالة الخطأ (إن وجدت)
    String? errorMessage,
    
    /// تاريخ الإنشاء
    required DateTime createdAt,
    
    /// تاريخ التحديث
    required DateTime updatedAt,
    
    /// معلومات إضافية
    Map<String, dynamic>? metadata,
  }) = _PaymentModel;

  /// إنشاء نموذج بيانات الدفع من JSON
  factory PaymentModel.fromJson(Map<String, dynamic> json) => _$PaymentModelFromJson(json);

  /// إنشاء نموذج بيانات الدفع من مستند Firestore
  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentModel.fromJson({
      'id': doc.id,
      ...data,
      'createdAt': (data['createdAt'] as Timestamp).toDate(),
      'updatedAt': (data['updatedAt'] as Timestamp).toDate(),
    });
  }

  /// تحويل نموذج بيانات الدفع إلى مستند Firestore
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return {
      ...json,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// إنشاء نموذج بيانات دفع جديد
  factory PaymentModel.create({
    required String userId,
    required String orderId,
    required double amount,
    required String currency,
    required PaymentMethod method,
  }) {
    final now = DateTime.now();
    return PaymentModel(
      id: '',
      userId: userId,
      orderId: orderId,
      amount: amount,
      currency: currency,
      method: method,
      status: PaymentStatus.pending,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// نسخ نموذج بيانات الدفع مع تحديث الحالة
  PaymentModel updateStatus(PaymentStatus newStatus, {String? errorMessage}) {
    return copyWith(
      status: newStatus,
      errorMessage: errorMessage,
      updatedAt: DateTime.now(),
    );
  }

  /// نسخ نموذج بيانات الدفع مع تحديث معرف المعاملة
  PaymentModel updateTransactionId(String transactionId) {
    return copyWith(
      transactionId: transactionId,
      updatedAt: DateTime.now(),
    );
  }
}

/// طرق الدفع المدعومة
enum PaymentMethod {
  /// بطاقة ائتمان
  creditCard,
  
  /// PayPal
  paypal,
  
  /// Apple Pay
  applePay,
  
  /// Google Pay
  googlePay,
  
  /// الدفع عند الاستلام
  cashOnDelivery,
}

/// حالات الدفع
enum PaymentStatus {
  /// قيد الانتظار
  pending,
  
  /// تمت المعالجة
  processing,
  
  /// تم الدفع بنجاح
  completed,
  
  /// فشل الدفع
  failed,
  
  /// تم الإلغاء
  cancelled,
  
  /// تم رد المبلغ
  refunded,
}

/// امتدادات لتحويل طرق الدفع إلى نص وبالعكس
extension PaymentMethodExtension on PaymentMethod {
  /// تحويل طريقة الدفع إلى نص
  String toShortString() {
    return toString().split('.').last;
  }

  /// الحصول على اسم طريقة الدفع
  String getName() {
    switch (this) {
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.applePay:
        return 'Apple Pay';
      case PaymentMethod.googlePay:
        return 'Google Pay';
      case PaymentMethod.cashOnDelivery:
        return 'Cash on Delivery';
    }
  }

  /// الحصول على رمز طريقة الدفع
  String getIcon() {
    switch (this) {
      case PaymentMethod.creditCard:
        return 'assets/icons/credit_card.png';
      case PaymentMethod.paypal:
        return 'assets/icons/paypal.png';
      case PaymentMethod.applePay:
        return 'assets/icons/apple_pay.png';
      case PaymentMethod.googlePay:
        return 'assets/icons/google_pay.png';
      case PaymentMethod.cashOnDelivery:
        return 'assets/icons/cash.png';
    }
  }
}

/// امتدادات لتحويل حالات الدفع إلى نص وبالعكس
extension PaymentStatusExtension on PaymentStatus {
  /// تحويل حالة الدفع إلى نص
  String toShortString() {
    return toString().split('.').last;
  }

  /// الحصول على اسم حالة الدفع
  String getName() {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  /// الحصول على لون حالة الدفع
  int getColor() {
    switch (this) {
      case PaymentStatus.pending:
        return 0xFFFFC107; // أصفر
      case PaymentStatus.processing:
        return 0xFF2196F3; // أزرق
      case PaymentStatus.completed:
        return 0xFF4CAF50; // أخضر
      case PaymentStatus.failed:
        return 0xFFF44336; // أحمر
      case PaymentStatus.cancelled:
        return 0xFF9E9E9E; // رمادي
      case PaymentStatus.refunded:
        return 0xFF9C27B0; // أرجواني
    }
  }
}
