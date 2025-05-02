import 'package:shared_libs/core/architecture/domain/entity.dart';

/// أنواع طرق الدفع
enum PaymentMethodType {
  /// بطاقة ائتمان
  creditCard,
  
  /// باي بال
  paypal,
  
  /// آبل باي
  applePay,
  
  /// جوجل باي
  googlePay,
  
  /// الدفع عند الاستلام
  cashOnDelivery,
}

/// كيان طريقة الدفع
class PaymentMethod extends Entity {
  /// نوع طريقة الدفع
  final PaymentMethodType type;
  
  /// هل هي الطريقة الافتراضية
  final bool isDefault;
  
  /// العلامة التجارية للبطاقة (فيزا، ماستركارد، إلخ)
  final String? cardBrand;
  
  /// آخر 4 أرقام من البطاقة
  final String? last4;
  
  /// شهر انتهاء البطاقة
  final int? expMonth;
  
  /// سنة انتهاء البطاقة
  final int? expYear;
  
  /// البريد الإلكتروني (لباي بال)
  final String? email;

  /// إنشاء كيان طريقة الدفع
  const PaymentMethod({
    required String id,
    required this.type,
    this.isDefault = false,
    this.cardBrand,
    this.last4,
    this.expMonth,
    this.expYear,
    this.email,
  }) : super(id: id);

  /// نسخة جديدة من الكيان مع تحديث بعض الحقول
  PaymentMethod copyWith({
    String? id,
    PaymentMethodType? type,
    bool? isDefault,
    String? cardBrand,
    String? last4,
    int? expMonth,
    int? expYear,
    String? email,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      cardBrand: cardBrand ?? this.cardBrand,
      last4: last4 ?? this.last4,
      expMonth: expMonth ?? this.expMonth,
      expYear: expYear ?? this.expYear,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        isDefault,
        cardBrand,
        last4,
        expMonth,
        expYear,
        email,
      ];
}
