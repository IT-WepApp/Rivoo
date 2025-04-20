class PaymentModel {
  final String id;
  final double amount;
  final String currency;
  final String status;
  final DateTime createdAt;
  final String? paymentMethodId;
  final String? customerId;
  final String? orderId;

  PaymentModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.paymentMethodId,
    this.customerId,
    this.orderId,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      paymentMethodId: json['payment_method_id'],
      customerId: json['customer_id'],
      orderId: json['order_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'currency': currency,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'payment_method_id': paymentMethodId,
      'customer_id': customerId,
      'order_id': orderId,
    };
  }
}

class PaymentMethod {
  final String id;
  final String type;
  final String? last4;
  final String? brand;
  final int? expiryMonth;
  final int? expiryYear;

  PaymentMethod({
    required this.id,
    required this.type,
    this.last4,
    this.brand,
    this.expiryMonth,
    this.expiryYear,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      type: json['type'],
      last4: json['last4'],
      brand: json['brand'],
      expiryMonth: json['expiry_month'],
      expiryYear: json['expiry_year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'last4': last4,
      'brand': brand,
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
    };
  }
}
