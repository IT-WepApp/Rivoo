import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:riverpod/riverpod.dart';
import 'package:user_app/core/services/secure_storage_service.dart';
import 'package:user_app/features/payment/data/payment_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// خدمة الدفع المسؤولة عن معالجة عمليات الدفع
class PaymentService {
  /// مرجع Firestore للمدفوعات
  final CollectionReference _paymentsCollection;

  /// خدمة التخزين الآمن
  final SecureStorageService _secureStorage;

  /// عنوان الخادم للتعامل مع Stripe
  final String _backendUrl;

  /// إنشاء خدمة الدفع
  PaymentService({
    required FirebaseFirestore firestore,
    required SecureStorageService secureStorage,
    String? backendUrl,
  })  : _paymentsCollection = firestore.collection('payments'),
        _secureStorage = secureStorage,
        _backendUrl = backendUrl ??
            dotenv.env['STRIPE_BACKEND_URL'] ??
            'https://us-central1-rivoosyflutter.cloudfunctions.net/stripePayment';

  /// تهيئة Stripe
  Future<void> initializeStripe() async {
    final publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ??
        await _secureStorage.read(key: 'stripe_publishable_key');

    if (publishableKey != null && publishableKey.isNotEmpty) {
      Stripe.publishableKey = publishableKey;
      await Stripe.instance.applySettings();
    } else {
      throw Exception('Stripe publishable key not found');
    }
  }

  /// إنشاء دفعة جديدة
  Future<PaymentModel> createPayment({
    required String userId,
    required String orderId,
    required double amount,
    required String currency,
    required PaymentMethod method,
  }) async {
    final payment = PaymentModel.create(
      userId: userId,
      orderId: orderId,
      amount: amount,
      currency: currency,
      method: method,
    );

    final docRef = await _paymentsCollection.add(payment.toFirestore());
    return payment.copyWith(id: docRef.id);
  }

  /// الحصول على دفعة بواسطة المعرف
  Future<PaymentModel?> getPaymentById(String paymentId) async {
    final docSnapshot = await _paymentsCollection.doc(paymentId).get();
    if (docSnapshot.exists) {
      return PaymentModel.fromFirestore(docSnapshot);
    }
    return null;
  }

  /// الحصول على دفعات المستخدم
  Future<List<PaymentModel>> getUserPayments(String userId) async {
    final querySnapshot = await _paymentsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => PaymentModel.fromFirestore(doc))
        .toList();
  }

  /// الحصول على دفعات الطلب
  Future<List<PaymentModel>> getOrderPayments(String orderId) async {
    final querySnapshot = await _paymentsCollection
        .where('orderId', isEqualTo: orderId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => PaymentModel.fromFirestore(doc))
        .toList();
  }

  /// تحديث حالة الدفع
  Future<PaymentModel> updatePaymentStatus(
    String paymentId,
    PaymentStatus status, {
    String? errorMessage,
  }) async {
    final payment = await getPaymentById(paymentId);
    if (payment == null) {
      throw Exception('Payment not found');
    }

    final updatedPayment =
        payment.updateStatus(status, errorMessage: errorMessage);
    await _paymentsCollection
        .doc(paymentId)
        .update(updatedPayment.toFirestore());
    return updatedPayment;
  }

  /// معالجة الدفع باستخدام Stripe
  Future<PaymentModel> processStripePayment({
    required PaymentModel payment,
    required String cardNumber,
    required String expMonth,
    required String expYear,
    required String cvc,
  }) async {
    try {
      // تحديث حالة الدفع إلى "قيد المعالجة"
      PaymentModel updatedPayment = await updatePaymentStatus(
        payment.id,
        PaymentStatus.processing,
      );

      // إنشاء بطاقة Stripe
      final cardDetails = CardDetails(
        number: cardNumber,
        expirationMonth: int.parse(expMonth),
        expirationYear: int.parse(expYear),
        cvc: cvc,
      );

      // إنشاء طريقة دفع
      final billingDetails = BillingDetails();
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: billingDetails,
          ),
          options: const PaymentMethodOptionsParams(),
        ),
      );

      // إرسال طلب إلى الخادم لإكمال الدفع
      final response = await http.post(
        Uri.parse('$_backendUrl/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'payment_method_id': paymentMethod.id,
          'amount': (payment.amount * 100).toInt(), // تحويل إلى أصغر وحدة (سنت)
          'currency': payment.currency,
          'payment_id': payment.id,
          'order_id': payment.orderId,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // تحديث معرف المعاملة وحالة الدفع
        final String transactionId = responseData['transaction_id'];
        updatedPayment = updatedPayment.updateTransactionId(transactionId);
        return await updatePaymentStatus(payment.id, PaymentStatus.completed);
      } else {
        // فشل الدفع
        final String errorMessage = responseData['error'] ?? 'Unknown error';
        return await updatePaymentStatus(
          payment.id,
          PaymentStatus.failed,
          errorMessage: errorMessage,
        );
      }
    } catch (e) {
      // فشل الدفع بسبب استثناء
      return await updatePaymentStatus(
        payment.id,
        PaymentStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  /// معالجة الدفع باستخدام PayPal
  Future<PaymentModel> processPayPalPayment({
    required PaymentModel payment,
  }) async {
    // تنفيذ وهمي لـ PayPal
    try {
      // تحديث حالة الدفع إلى "قيد المعالجة"
      final updatedPayment = await updatePaymentStatus(
        payment.id,
        PaymentStatus.processing,
      );

      // محاكاة عملية الدفع
      await Future.delayed(const Duration(seconds: 2));

      // تحديث معرف المعاملة وحالة الدفع
      final mockTransactionId =
          'paypal_${DateTime.now().millisecondsSinceEpoch}';
      final paymentWithTransaction =
          updatedPayment.updateTransactionId(mockTransactionId);
      await _paymentsCollection
          .doc(payment.id)
          .update(paymentWithTransaction.toFirestore());

      return await updatePaymentStatus(payment.id, PaymentStatus.completed);
    } catch (e) {
      // فشل الدفع بسبب استثناء
      return await updatePaymentStatus(
        payment.id,
        PaymentStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  /// معالجة الدفع باستخدام Apple Pay
  Future<PaymentModel> processApplePayPayment({
    required PaymentModel payment,
  }) async {
    try {
      // تحديث حالة الدفع إلى "قيد المعالجة"
      await updatePaymentStatus(payment.id, PaymentStatus.processing);

      // إعداد Apple Pay
      final applePayOptions = ApplePayPresentParams(
        cartItems: [
          ApplePayCartSummaryItem.immediate(
            label: 'Order #${payment.orderId}',
            amount: payment.amount.toString(),
          ),
        ],
        country: 'US',
        currency: payment.currency,
      );

      // عرض واجهة Apple Pay
      final applePayResult =
          await Stripe.instance.presentApplePay(applePayOptions);

      // إرسال طلب إلى الخادم لإكمال الدفع
      final response = await http.post(
        Uri.parse('$_backendUrl/confirm-apple-pay'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'payment_method_id': applePayResult.paymentMethod,
          'amount': (payment.amount * 100).toInt(),
          'currency': payment.currency,
          'payment_id': payment.id,
          'order_id': payment.orderId,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // تحديث معرف المعاملة وحالة الدفع
        final String transactionId = responseData['transaction_id'];
        final updatedPayment = payment.updateTransactionId(transactionId);
        await _paymentsCollection
            .doc(payment.id)
            .update(updatedPayment.toFirestore());
        return await updatePaymentStatus(payment.id, PaymentStatus.completed);
      } else {
        // فشل الدفع
        final String errorMessage = responseData['error'] ?? 'Unknown error';
        return await updatePaymentStatus(
          payment.id,
          PaymentStatus.failed,
          errorMessage: errorMessage,
        );
      }
    } catch (e) {
      // فشل الدفع بسبب استثناء
      return await updatePaymentStatus(
        payment.id,
        PaymentStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  /// معالجة الدفع باستخدام Google Pay
  Future<PaymentModel> processGooglePayPayment({
    required PaymentModel payment,
  }) async {
    try {
      // تحديث حالة الدفع إلى "قيد المعالجة"
      await updatePaymentStatus(payment.id, PaymentStatus.processing);

      // إعداد Google Pay
      final googlePayOptions = GooglePayPresentParams(
        clientSecret: await _createPaymentIntent(payment),
        merchantName: 'RivooSy',
      );

      // عرض واجهة Google Pay
      await Stripe.instance.presentGooglePay(googlePayOptions);

      // تحديث معرف المعاملة وحالة الدفع
      final mockTransactionId =
          'googlepay_${DateTime.now().millisecondsSinceEpoch}';
      final updatedPayment = payment.updateTransactionId(mockTransactionId);
      await _paymentsCollection
          .doc(payment.id)
          .update(updatedPayment.toFirestore());

      return await updatePaymentStatus(payment.id, PaymentStatus.completed);
    } catch (e) {
      // فشل الدفع بسبب استثناء
      return await updatePaymentStatus(
        payment.id,
        PaymentStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  /// معالجة الدفع عند الاستلام
  Future<PaymentModel> processCashOnDeliveryPayment({
    required PaymentModel payment,
  }) async {
    // تحديث حالة الدفع إلى "قيد الانتظار"
    return await updatePaymentStatus(payment.id, PaymentStatus.pending);
  }

  /// إنشاء نية دفع لـ Stripe
  Future<String> _createPaymentIntent(PaymentModel payment) async {
    final response = await http.post(
      Uri.parse('$_backendUrl/create-payment-intent'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'amount': (payment.amount * 100).toInt(),
        'currency': payment.currency,
        'payment_id': payment.id,
        'order_id': payment.orderId,
      }),
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      return responseData['client_secret'];
    } else {
      throw Exception(
          responseData['error'] ?? 'Failed to create payment intent');
    }
  }

  /// إلغاء الدفع
  Future<PaymentModel> cancelPayment(String paymentId) async {
    return await updatePaymentStatus(paymentId, PaymentStatus.cancelled);
  }

  /// رد مبلغ الدفع
  Future<PaymentModel> refundPayment(String paymentId) async {
    final payment = await getPaymentById(paymentId);
    if (payment == null) {
      throw Exception('Payment not found');
    }

    if (payment.status != PaymentStatus.completed) {
      throw Exception('Only completed payments can be refunded');
    }

    // إرسال طلب إلى الخادم لرد المبلغ
    final response = await http.post(
      Uri.parse('$_backendUrl/refund-payment'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'payment_id': payment.id,
        'transaction_id': payment.transactionId,
      }),
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      return await updatePaymentStatus(paymentId, PaymentStatus.refunded);
    } else {
      throw Exception(responseData['error'] ?? 'Failed to refund payment');
    }
  }
}

/// مزود خدمة الدفع
final paymentServiceProvider = Provider<PaymentService>((ref) {
  final firestore = FirebaseFirestore.instance;
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return PaymentService(
    firestore: firestore,
    secureStorage: secureStorage,
  );
});
