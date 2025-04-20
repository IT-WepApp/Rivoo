import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/features/payment/data/payment_model.dart';

// مزود لخدمة الدفع
final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});

// مزود لحالة الدفع
final paymentStateProvider = StateNotifierProvider<PaymentStateNotifier, PaymentState>((ref) {
  final paymentService = ref.watch(paymentServiceProvider);
  return PaymentStateNotifier(paymentService);
});

// حالة الدفع
class PaymentState {
  final bool isLoading;
  final String? error;
  final PaymentModel? paymentModel;
  final List<PaymentMethod> paymentMethods;

  PaymentState({
    this.isLoading = false,
    this.error,
    this.paymentModel,
    this.paymentMethods = const [],
  });

  PaymentState copyWith({
    bool? isLoading,
    String? error,
    PaymentModel? paymentModel,
    List<PaymentMethod>? paymentMethods,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      paymentModel: paymentModel ?? this.paymentModel,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }
}

// مدير حالة الدفع
class PaymentStateNotifier extends StateNotifier<PaymentState> {
  final PaymentService _paymentService;

  PaymentStateNotifier(this._paymentService) : super(PaymentState());

  Future<void> createPaymentIntent(double amount, String currency) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _paymentService.createPaymentIntent(amount, currency);
      state = state.copyWith(
        isLoading: false,
        paymentModel: result,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> processPayment(double amount, String currency) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _paymentService.processPayment(amount, currency);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// خدمة الدفع
class PaymentService {
  // مفتاح Stripe (يجب استبداله بمفتاح حقيقي في الإنتاج)
  static const String _apiKey = 'pk_test_51NxXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
  static const String _apiUrl = 'https://api.stripe.com/v1/payment_intents';

  // تهيئة Stripe
  Future<void> initStripe() async {
    Stripe.publishableKey = _apiKey;
    await Stripe.instance.applySettings();
  }

  // إنشاء نية دفع
  Future<PaymentModel> createPaymentIntent(double amount, String currency) async {
    try {
      // في بيئة الإنتاج، يجب أن يتم هذا على الخادم الخلفي
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': (amount * 100).toInt().toString(), // تحويل إلى أصغر وحدة (سنت)
          'currency': currency,
          'payment_method_types[]': 'card',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return PaymentModel(
          id: json['id'],
          amount: json['amount'] / 100, // تحويل من سنت إلى دولار
          currency: json['currency'],
          status: json['status'],
          createdAt: DateTime.fromMillisecondsSinceEpoch(json['created'] * 1000),
        );
      } else {
        throw Exception('فشل في إنشاء نية الدفع: ${response.body}');
      }
    } catch (e) {
      throw Exception('خطأ في إنشاء نية الدفع: $e');
    }
  }

  // معالجة الدفع
  Future<void> processPayment(double amount, String currency) async {
    try {
      // إنشاء نية الدفع
      final paymentIntent = await createPaymentIntent(amount, currency);

      // تهيئة بيانات الدفع
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      // تأكيد الدفع
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: paymentIntent.id,
        data: PaymentMethodParams.cardFromMethodId(
          paymentMethodData: PaymentMethodDataCardFromMethod(
            paymentMethodId: paymentMethod.id,
          ),
        ),
      );
    } catch (e) {
      throw Exception('فشل في معالجة الدفع: $e');
    }
  }

  // معالجة الدفع باستخدام واجهة Stripe الجاهزة
  Future<void> processPaymentWithUI(double amount, String currency) async {
    try {
      // إنشاء نية الدفع
      final paymentIntent = await createPaymentIntent(amount, currency);

      // عرض واجهة الدفع
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent.id,
          merchantDisplayName: 'RivooSy',
          style: ThemeMode.system,
        ),
      );

      // عرض صفحة الدفع
      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      throw Exception('فشل في معالجة الدفع: $e');
    }
  }

  // استخدام هيكل وهمي للدفع (في حالة عدم توفر Stripe)
  Future<PaymentModel> mockPayment(double amount, String currency) async {
    // محاكاة تأخير الشبكة
    await Future.delayed(const Duration(seconds: 2));

    // إنشاء معرف فريد
    final id = 'mock_payment_${DateTime.now().millisecondsSinceEpoch}';

    // إنشاء نموذج دفع وهمي
    return PaymentModel(
      id: id,
      amount: amount,
      currency: currency,
      status: 'succeeded',
      createdAt: DateTime.now(),
    );
  }
}
