import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:user_app/features/payment/application/payment_service.dart';
import 'package:user_app/features/payment/data/payment_model.dart';
import 'package:user_app/core/services/secure_storage_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

@GenerateMocks([
  SecureStorageService,
  http.Client,
  Stripe,
])
void main() {
  late MockSecureStorageService mockSecureStorage;
  late MockClient mockHttpClient;
  late PaymentService paymentService;

  setUp(() {
    mockSecureStorage = MockSecureStorageService();
    mockHttpClient = MockClient();
    paymentService = PaymentService(
      secureStorage: mockSecureStorage,
      httpClient: mockHttpClient,
    );
  });

  group('PaymentService Tests', () {
    test('createPaymentIntent should create payment intent and store securely', () async {
      // ترتيب
      const amount = 1000;
      const currency = 'USD';
      const paymentMethodId = 'pm_card_visa';
      
      final mockResponse = http.Response(
        '{"id": "pi_123456", "client_secret": "secret_123456", "status": "requires_confirmation"}',
        200,
      );
      
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => mockResponse);
      
      when(mockSecureStorage.saveSecureValue(any, any))
          .thenAnswer((_) async => null);

      // تنفيذ
      final result = await paymentService.createPaymentIntent(
        amount: amount,
        currency: currency,
        paymentMethodId: paymentMethodId,
      );

      // تحقق
      expect(result.id, 'pi_123456');
      expect(result.clientSecret, 'secret_123456');
      expect(result.status, 'requires_confirmation');
      
      verify(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).called(1);
      
      // التحقق من تخزين معلومات الدفع بشكل آمن
      verify(mockSecureStorage.saveSecureValue(any, any)).called(greaterThan(0));
    });

    test('confirmPayment should confirm payment and update payment record', () async {
      // ترتيب
      const paymentIntentId = 'pi_123456';
      const clientSecret = 'secret_123456';
      
      final mockResponse = http.Response(
        '{"id": "pi_123456", "status": "succeeded"}',
        200,
      );
      
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => mockResponse);
      
      when(mockSecureStorage.saveSecureValue(any, any))
          .thenAnswer((_) async => null);

      // تنفيذ
      final result = await paymentService.confirmPayment(
        paymentIntentId: paymentIntentId,
        clientSecret: clientSecret,
      );

      // تحقق
      expect(result.status, 'succeeded');
      
      verify(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).called(1);
      
      // التحقق من تحديث سجل الدفع بشكل آمن
      verify(mockSecureStorage.saveSecureValue(any, any)).called(greaterThan(0));
    });

    test('getPaymentMethods should return available payment methods', () async {
      // تنفيذ
      final result = await paymentService.getPaymentMethods();

      // تحقق
      expect(result, isA<List<PaymentMethod>>());
      expect(result.length, greaterThan(0));
      expect(result.any((method) => method.type == PaymentMethodType.card), isTrue);
    });

    test('savePaymentMethod should store payment method securely', () async {
      // ترتيب
      final paymentMethod = PaymentMethod(
        id: 'pm_123456',
        type: PaymentMethodType.card,
        card: PaymentMethodCard(
          last4: '4242',
          brand: 'visa',
          expiryMonth: 12,
          expiryYear: 2025,
        ),
      );
      
      when(mockSecureStorage.saveSecureValue(any, any))
          .thenAnswer((_) async => null);

      // تنفيذ
      await paymentService.savePaymentMethod(paymentMethod);

      // تحقق
      verify(mockSecureStorage.saveSecureValue(any, any)).called(1);
    });

    test('getSavedPaymentMethods should retrieve payment methods from secure storage', () async {
      // ترتيب
      final mockPaymentMethodJson = '{"id":"pm_123456","type":"card","card":{"last4":"4242","brand":"visa","expiryMonth":12,"expiryYear":2025}}';
      
      when(mockSecureStorage.getSecureValue(any))
          .thenAnswer((_) async => mockPaymentMethodJson);

      // تنفيذ
      final result = await paymentService.getSavedPaymentMethods();

      // تحقق
      expect(result, isA<List<PaymentMethod>>());
      expect(result.length, 1);
      expect(result[0].id, 'pm_123456');
      expect(result[0].type, PaymentMethodType.card);
      expect(result[0].card?.last4, '4242');
      
      verify(mockSecureStorage.getSecureValue(any)).called(1);
    });

    test('processPayment should handle the complete payment flow', () async {
      // ترتيب
      const amount = 1000;
      const currency = 'USD';
      const paymentMethodId = 'pm_card_visa';
      
      final createIntentResponse = http.Response(
        '{"id": "pi_123456", "client_secret": "secret_123456", "status": "requires_confirmation"}',
        200,
      );
      
      final confirmPaymentResponse = http.Response(
        '{"id": "pi_123456", "status": "succeeded"}',
        200,
      );
      
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) => Future.value(createIntentResponse))
        .thenAnswer((_) => Future.value(confirmPaymentResponse));
      
      when(mockSecureStorage.saveSecureValue(any, any))
          .thenAnswer((_) async => null);

      // تنفيذ
      final result = await paymentService.processPayment(
        amount: amount,
        currency: currency,
        paymentMethodId: paymentMethodId,
      );

      // تحقق
      expect(result.success, isTrue);
      expect(result.paymentId, 'pi_123456');
      
      verify(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).called(2); // مرة لإنشاء النية ومرة للتأكيد
      
      verify(mockSecureStorage.saveSecureValue(any, any)).called(greaterThan(0));
    });
  });
}
