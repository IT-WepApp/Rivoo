import 'package:dartz/dartz.dart';
import 'package:user_app/core/architecture/domain/failure.dart';
import 'package:user_app/features/payment/domain/payment_entity.dart';

/// واجهة مستودع الدفع
/// تحدد العمليات المتعلقة بالدفع وإدارة طرق الدفع
abstract class PaymentRepository {
  /// الحصول على طرق الدفع المتاحة
  Future<Either<Failure, List<PaymentMethodEntity>>>
      getAvailablePaymentMethods();

  /// الحصول على طرق الدفع المحفوظة للمستخدم
  Future<Either<Failure, List<PaymentMethodEntity>>> getSavedPaymentMethods();

  /// حفظ طريقة دفع جديدة
  Future<Either<Failure, PaymentMethodEntity>> savePaymentMethod(
      PaymentMethodEntity paymentMethod);

  /// حذف طريقة دفع
  Future<Either<Failure, bool>> deletePaymentMethod(String paymentMethodId);

  /// تعيين طريقة دفع افتراضية
  Future<Either<Failure, bool>> setDefaultPaymentMethod(String paymentMethodId);

  /// إنشاء نية دفع
  Future<Either<Failure, PaymentIntentEntity>> createPaymentIntent({
    required int amount,
    required String currency,
    required String paymentMethodId,
  });

  /// تأكيد الدفع
  Future<Either<Failure, PaymentResultEntity>> confirmPayment({
    required String paymentIntentId,
    required String clientSecret,
  });

  /// معالجة عملية الدفع بالكامل
  Future<Either<Failure, PaymentResultEntity>> processPayment({
    required int amount,
    required String currency,
    required String paymentMethodId,
  });

  /// الحصول على سجل المدفوعات
  Future<Either<Failure, List<PaymentResultEntity>>> getPaymentHistory();
}
