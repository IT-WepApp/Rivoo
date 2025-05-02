import 'package:dartz/dartz.dart';
import 'package:shared_libs/core/architecture/domain/failure.dart';
import 'package:shared_libs/core/architecture/domain/usecase.dart';
import 'package:user_app/features/payment/domain/payment_entity.dart';
import 'package:user_app/features/payment/domain/payment_repository.dart';

/// حالة استخدام الحصول على طرق الدفع المتاحة
class GetAvailablePaymentMethodsUseCase
    implements UseCase<List<PaymentMethodEntity>, NoParams> {
  final PaymentRepository _paymentRepository;

  GetAvailablePaymentMethodsUseCase(this._paymentRepository);

  @override
  Future<Either<Failure, List<PaymentMethodEntity>>> call(NoParams params) {
    return _paymentRepository.getAvailablePaymentMethods();
  }
}

/// حالة استخدام الحصول على طرق الدفع المحفوظة
class GetSavedPaymentMethodsUseCase
    implements UseCase<List<PaymentMethodEntity>, NoParams> {
  final PaymentRepository _paymentRepository;

  GetSavedPaymentMethodsUseCase(this._paymentRepository);

  @override
  Future<Either<Failure, List<PaymentMethodEntity>>> call(NoParams params) {
    return _paymentRepository.getSavedPaymentMethods();
  }
}

/// حالة استخدام حفظ طريقة دفع جديدة
class SavePaymentMethodUseCase
    implements UseCase<PaymentMethodEntity, SavePaymentMethodParams> {
  final PaymentRepository _paymentRepository;

  SavePaymentMethodUseCase(this._paymentRepository);

  @override
  Future<Either<Failure, PaymentMethodEntity>> call(
      SavePaymentMethodParams params) {
    return _paymentRepository.savePaymentMethod(params.paymentMethod);
  }
}

/// معلمات حفظ طريقة دفع جديدة
class SavePaymentMethodParams {
  final PaymentMethodEntity paymentMethod;

  SavePaymentMethodParams({
    required this.paymentMethod,
  });
}

/// حالة استخدام حذف طريقة دفع
class DeletePaymentMethodUseCase
    implements UseCase<bool, DeletePaymentMethodParams> {
  final PaymentRepository _paymentRepository;

  DeletePaymentMethodUseCase(this._paymentRepository);

  @override
  Future<Either<Failure, bool>> call(DeletePaymentMethodParams params) {
    return _paymentRepository.deletePaymentMethod(params.paymentMethodId);
  }
}

/// معلمات حذف طريقة دفع
class DeletePaymentMethodParams {
  final String paymentMethodId;

  DeletePaymentMethodParams({
    required this.paymentMethodId,
  });
}

/// حالة استخدام تعيين طريقة دفع افتراضية
class SetDefaultPaymentMethodUseCase
    implements UseCase<bool, SetDefaultPaymentMethodParams> {
  final PaymentRepository _paymentRepository;

  SetDefaultPaymentMethodUseCase(this._paymentRepository);

  @override
  Future<Either<Failure, bool>> call(SetDefaultPaymentMethodParams params) {
    return _paymentRepository.setDefaultPaymentMethod(params.paymentMethodId);
  }
}

/// معلمات تعيين طريقة دفع افتراضية
class SetDefaultPaymentMethodParams {
  final String paymentMethodId;

  SetDefaultPaymentMethodParams({
    required this.paymentMethodId,
  });
}

/// حالة استخدام إنشاء نية دفع
class CreatePaymentIntentUseCase
    implements UseCase<PaymentIntentEntity, CreatePaymentIntentParams> {
  final PaymentRepository _paymentRepository;

  CreatePaymentIntentUseCase(this._paymentRepository);

  @override
  Future<Either<Failure, PaymentIntentEntity>> call(
      CreatePaymentIntentParams params) {
    return _paymentRepository.createPaymentIntent(
      amount: params.amount,
      currency: params.currency,
      paymentMethodId: params.paymentMethodId,
    );
  }
}

/// معلمات إنشاء نية دفع
class CreatePaymentIntentParams {
  final int amount;
  final String currency;
  final String paymentMethodId;

  CreatePaymentIntentParams({
    required this.amount,
    required this.currency,
    required this.paymentMethodId,
  });
}

/// حالة استخدام تأكيد الدفع
class ConfirmPaymentUseCase
    implements UseCase<PaymentResultEntity, ConfirmPaymentParams> {
  final PaymentRepository _paymentRepository;

  ConfirmPaymentUseCase(this._paymentRepository);

  @override
  Future<Either<Failure, PaymentResultEntity>> call(
      ConfirmPaymentParams params) {
    return _paymentRepository.confirmPayment(
      paymentIntentId: params.paymentIntentId,
      clientSecret: params.clientSecret,
    );
  }
}

/// معلمات تأكيد الدفع
class ConfirmPaymentParams {
  final String paymentIntentId;
  final String clientSecret;

  ConfirmPaymentParams({
    required this.paymentIntentId,
    required this.clientSecret,
  });
}

/// حالة استخدام معالجة عملية الدفع بالكامل
class ProcessPaymentUseCase
    implements UseCase<PaymentResultEntity, ProcessPaymentParams> {
  final PaymentRepository _paymentRepository;

  ProcessPaymentUseCase(this._paymentRepository);

  @override
  Future<Either<Failure, PaymentResultEntity>> call(
      ProcessPaymentParams params) {
    return _paymentRepository.processPayment(
      amount: params.amount,
      currency: params.currency,
      paymentMethodId: params.paymentMethodId,
    );
  }
}

/// معلمات معالجة عملية الدفع
class ProcessPaymentParams {
  final int amount;
  final String currency;
  final String paymentMethodId;

  ProcessPaymentParams({
    required this.amount,
    required this.currency,
    required this.paymentMethodId,
  });
}

/// حالة استخدام الحصول على سجل المدفوعات
class GetPaymentHistoryUseCase
    implements UseCase<List<PaymentResultEntity>, NoParams> {
  final PaymentRepository _paymentRepository;

  GetPaymentHistoryUseCase(this._paymentRepository);

  @override
  Future<Either<Failure, List<PaymentResultEntity>>> call(NoParams params) {
    return _paymentRepository.getPaymentHistory();
  }
}
