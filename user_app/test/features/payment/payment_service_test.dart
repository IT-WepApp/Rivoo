import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:user_app/features/payment/application/payment_service.dart';
import 'package:user_app/features/payment/data/payment_model.dart';

@GenerateMocks([PaymentService])
void main() {
  late MockPaymentService mockPaymentService;

  setUp(() {
    mockPaymentService = MockPaymentService();
  });

  group('PaymentService Tests', () {
    test('processPayment should return success for valid payment', () async {
      // ترتيب
      final paymentInfo = PaymentInfo(
        amount: 100.0,
        currency: 'USD',
        paymentMethod: PaymentMethod.stripe,
        cardNumber: '4242424242424242',
        expiryMonth: 12,
        expiryYear: 2025,
        cvc: '123',
        email: 'test@example.com',
      );

      final expectedResult = PaymentResult(
        success: true,
        transactionId: 'tx_123456',
        message: 'تمت عملية الدفع بنجاح',
      );

      when(mockPaymentService.processPayment(paymentInfo))
          .thenAnswer((_) async => expectedResult);

      // تنفيذ
      final result = await mockPaymentService.processPayment(paymentInfo);

      // تحقق
      expect(result.success, true);
      expect(result.transactionId, isNotEmpty);
      expect(result.message, contains('بنجاح'));
    });

    test('processPayment should return failure for invalid payment', () async {
      // ترتيب
      final paymentInfo = PaymentInfo(
        amount: 100.0,
        currency: 'USD',
        paymentMethod: PaymentMethod.stripe,
        cardNumber: '4000000000000002', // بطاقة مرفوضة
        expiryMonth: 12,
        expiryYear: 2025,
        cvc: '123',
        email: 'test@example.com',
      );

      final expectedResult = PaymentResult(
        success: false,
        transactionId: '',
        message: 'تم رفض البطاقة',
      );

      when(mockPaymentService.processPayment(paymentInfo))
          .thenAnswer((_) async => expectedResult);

      // تنفيذ
      final result = await mockPaymentService.processPayment(paymentInfo);

      // تحقق
      expect(result.success, false);
      expect(result.message, isNotEmpty);
    });

    test('validateCardNumber should return true for valid card number', () {
      // ترتيب
      when(mockPaymentService.validateCardNumber('4242424242424242'))
          .thenReturn(true);

      // تنفيذ
      final result = mockPaymentService.validateCardNumber('4242424242424242');

      // تحقق
      expect(result, true);
    });

    test('validateCardNumber should return false for invalid card number', () {
      // ترتيب
      when(mockPaymentService.validateCardNumber('1234'))
          .thenReturn(false);

      // تنفيذ
      final result = mockPaymentService.validateCardNumber('1234');

      // تحقق
      expect(result, false);
    });
  });
}
