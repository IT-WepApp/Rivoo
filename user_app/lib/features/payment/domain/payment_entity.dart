import 'package:user_app/core/architecture/domain/entity.dart';

/// كيان طريقة الدفع
/// يمثل طريقة دفع في طبقة المجال
class PaymentMethodEntity extends Entity {
  final PaymentMethodType type;
  final PaymentMethodCardEntity? card;
  final bool isDefault;

  const PaymentMethodEntity({
    required String id,
    required this.type,
    this.card,
    this.isDefault = false,
  }) : super(id: id);

  @override
  List<Object?> get props => [id, type, card, isDefault];

  /// نسخ الكيان مع تحديث بعض الحقول
  PaymentMethodEntity copyWith({
    String? id,
    PaymentMethodType? type,
    PaymentMethodCardEntity? card,
    bool? isDefault,
  }) {
    return PaymentMethodEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      card: card ?? this.card,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

/// كيان بطاقة الدفع
/// يمثل تفاصيل بطاقة الدفع في طبقة المجال
class PaymentMethodCardEntity {
  final String last4;
  final String brand;
  final int expiryMonth;
  final int expiryYear;

  const PaymentMethodCardEntity({
    required this.last4,
    required this.brand,
    required this.expiryMonth,
    required this.expiryYear,
  });

  List<Object?> get props => [last4, brand, expiryMonth, expiryYear];

  /// نسخ الكيان مع تحديث بعض الحقول
  PaymentMethodCardEntity copyWith({
    String? last4,
    String? brand,
    int? expiryMonth,
    int? expiryYear,
  }) {
    return PaymentMethodCardEntity(
      last4: last4 ?? this.last4,
      brand: brand ?? this.brand,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
    );
  }
}

/// كيان نية الدفع
/// يمثل نية دفع في طبقة المجال
class PaymentIntentEntity extends Entity {
  final String clientSecret;
  final String status;
  final int amount;
  final String currency;
  final DateTime createdAt;

  const PaymentIntentEntity({
    required String id,
    required this.clientSecret,
    required this.status,
    required this.amount,
    required this.currency,
    required this.createdAt,
  }) : super(id: id);

  @override
  List<Object?> get props =>
      [id, clientSecret, status, amount, currency, createdAt];

  /// نسخ الكيان مع تحديث بعض الحقول
  PaymentIntentEntity copyWith({
    String? id,
    String? clientSecret,
    String? status,
    int? amount,
    String? currency,
    DateTime? createdAt,
  }) {
    return PaymentIntentEntity(
      id: id ?? this.id,
      clientSecret: clientSecret ?? this.clientSecret,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// كيان نتيجة الدفع
/// يمثل نتيجة عملية دفع في طبقة المجال
class PaymentResultEntity extends Entity {
  final bool success;
  final String status;
  final String? errorMessage;
  final DateTime timestamp;

  const PaymentResultEntity({
    required String id,
    required this.success,
    required this.status,
    this.errorMessage,
    required this.timestamp,
  }) : super(id: id);

  @override
  List<Object?> get props => [id, success, status, errorMessage, timestamp];

  /// نسخ الكيان مع تحديث بعض الحقول
  PaymentResultEntity copyWith({
    String? id,
    bool? success,
    String? status,
    String? errorMessage,
    DateTime? timestamp,
  }) {
    return PaymentResultEntity(
      id: id ?? this.id,
      success: success ?? this.success,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// أنواع طرق الدفع
enum PaymentMethodType {
  card,
  paypal,
  applePay,
  googlePay,
  bankTransfer,
}
