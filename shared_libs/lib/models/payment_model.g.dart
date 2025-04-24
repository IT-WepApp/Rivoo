// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentModel _$PaymentModelFromJson(Map<String, dynamic> json) => PaymentModel(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      method: $enumDecode(_$PaymentMethodTypeEnumMap, json['method']),
      status: $enumDecode(_$PaymentStatusTypeEnumMap, json['status']),
      transactionId: json['transactionId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      errorMessage: json['errorMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$PaymentModelToJson(PaymentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'userId': instance.userId,
      'amount': instance.amount,
      'currency': instance.currency,
      'method': _$PaymentMethodTypeEnumMap[instance.method]!,
      'status': _$PaymentStatusTypeEnumMap[instance.status]!,
      'transactionId': instance.transactionId,
      'metadata': instance.metadata,
      'errorMessage': instance.errorMessage,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };

const _$PaymentMethodTypeEnumMap = {
  PaymentMethodType.cash: 'cash',
  PaymentMethodType.creditCard: 'creditCard',
  PaymentMethodType.debitCard: 'debitCard',
  PaymentMethodType.wallet: 'wallet',
  PaymentMethodType.bankTransfer: 'bankTransfer',
  PaymentMethodType.applePay: 'applePay',
  PaymentMethodType.googlePay: 'googlePay',
  PaymentMethodType.paypal: 'paypal',
};

const _$PaymentStatusTypeEnumMap = {
  PaymentStatusType.pending: 'pending',
  PaymentStatusType.processing: 'processing',
  PaymentStatusType.completed: 'completed',
  PaymentStatusType.failed: 'failed',
  PaymentStatusType.refunded: 'refunded',
  PaymentStatusType.partiallyRefunded: 'partiallyRefunded',
  PaymentStatusType.cancelled: 'cancelled',
};
