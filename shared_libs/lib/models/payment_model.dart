import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment_model.g.dart';

/// نموذج الدفع
/// يستخدم لتمثيل بيانات عمليات الدفع في التطبيق
@JsonSerializable()
class PaymentModel extends Equatable {
  /// معرف عملية الدفع الفريد
  final String id;
  
  /// معرف الطلب المرتبط بعملية الدفع
  final String orderId;
  
  /// معرف المستخدم الذي قام بالدفع
  final String userId;
  
  /// المبلغ المدفوع
  final double amount;
  
  /// العملة المستخدمة
  final String currency;
  
  /// طريقة الدفع المستخدمة
  final PaymentMethodType method;
  
  /// حالة عملية الدفع
  final PaymentStatusType status;
  
  /// معرف المعاملة من بوابة الدفع
  final String? transactionId;
  
  /// معلومات إضافية عن عملية الدفع
  final Map<String, dynamic>? metadata;
  
  /// رسالة الخطأ (في حالة فشل الدفع)
  final String? errorMessage;
  
  /// تاريخ إنشاء عملية الدفع
  final DateTime createdAt;
  
  /// تاريخ آخر تحديث لعملية الدفع
  final DateTime updatedAt;
  
  /// تاريخ اكتمال عملية الدفع (إن وجد)
  final DateTime? completedAt;

  /// منشئ النموذج
  const PaymentModel({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    this.transactionId,
    this.metadata,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  /// إنشاء نسخة جديدة من النموذج مع تحديث بعض الحقول
  PaymentModel copyWith({
    String? id,
    String? orderId,
    String? userId,
    double? amount,
    String? currency,
    PaymentMethodType? method,
    PaymentStatusType? status,
    String? transactionId,
    Map<String, dynamic>? metadata,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      method: method ?? this.method,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      metadata: metadata ?? this.metadata,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// تحويل النموذج إلى Map
  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);

  /// إنشاء نموذج من Map
  factory PaymentModel.fromJson(Map<String, dynamic> json) => _$PaymentModelFromJson(json);

  @override
  List<Object?> get props => [
        id,
        orderId,
        userId,
        amount,
        currency,
        method,
        status,
        transactionId,
        metadata,
        errorMessage,
        createdAt,
        updatedAt,
        completedAt,
      ];
}

/// تعداد طرق الدفع
enum PaymentMethodType {
  cash,           // الدفع عند الاستلام
  creditCard,     // بطاقة ائتمان
  debitCard,      // بطاقة خصم
  wallet,         // محفظة إلكترونية
  bankTransfer,   // تحويل بنكي
  applePay,       // آبل باي
  googlePay,      // جوجل باي
  paypal,         // باي بال
}

/// تعداد حالات الدفع
enum PaymentStatusType {
  pending,        // قيد الانتظار
  processing,     // قيد المعالجة
  completed,      // مكتمل
  failed,         // فشل
  refunded,       // مسترد
  partiallyRefunded, // مسترد جزئياً
  cancelled,      // ملغي
}
