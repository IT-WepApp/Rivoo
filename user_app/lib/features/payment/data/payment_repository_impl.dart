import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:user_app/core/architecture/domain/failure.dart';
import 'package:user_app/features/payment/domain/payment_entity.dart';
import 'package:user_app/features/payment/domain/payment_repository.dart';
import 'package:user_app/core/services/secure_storage_service.dart';
import 'package:user_app/core/constants/app_constants.dart';

/// تنفيذ مستودع الدفع
/// يقوم بتنفيذ واجهة PaymentRepository باستخدام Stripe وSecureStorageService
class PaymentRepositoryImpl implements PaymentRepository {
  final http.Client _httpClient;
  final SecureStorageService _secureStorage;
  final String _apiKey;
  final String _apiUrl;
  
  PaymentRepositoryImpl({
    required http.Client httpClient,
    required SecureStorageService secureStorage,
    required String apiKey,
    String apiUrl = 'https://api.stripe.com/v1',
  }) : _httpClient = httpClient,
       _secureStorage = secureStorage,
       _apiKey = apiKey,
       _apiUrl = apiUrl;
  
  @override
  Future<Either<Failure, List<PaymentMethodEntity>>> getAvailablePaymentMethods() async {
    try {
      // قائمة طرق الدفع المتاحة في التطبيق
      final availableMethods = [
        PaymentMethodEntity(
          id: 'card',
          type: PaymentMethodType.card,
          isDefault: true,
        ),
        PaymentMethodEntity(
          id: 'paypal',
          type: PaymentMethodType.paypal,
        ),
        if (await _isApplePayAvailable())
          PaymentMethodEntity(
            id: 'apple_pay',
            type: PaymentMethodType.applePay,
          ),
        if (await _isGooglePayAvailable())
          PaymentMethodEntity(
            id: 'google_pay',
            type: PaymentMethodType.googlePay,
          ),
      ];
      
      return Right(availableMethods);
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'فشل الحصول على طرق الدفع المتاحة: $e',
        stackTrace: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, List<PaymentMethodEntity>>> getSavedPaymentMethods() async {
    try {
      // محاولة الحصول على طرق الدفع المحفوظة من التخزين الآمن
      final savedMethodsJson = await _secureStorage.getSecureValue(AppConstants.savedPaymentMethodsKey);
      if (savedMethodsJson == null) {
        return const Right([]);
      }
      
      final List<dynamic> savedMethodsList = jsonDecode(savedMethodsJson);
      final savedMethods = savedMethodsList.map((json) => _paymentMethodFromJson(json)).toList();
      
      return Right(savedMethods);
    } catch (e) {
      return Left(CacheFailure(
        message: 'فشل الحصول على طرق الدفع المحفوظة: $e',
        stackTrace: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, PaymentMethodEntity>> savePaymentMethod(PaymentMethodEntity paymentMethod) async {
    try {
      // الحصول على طرق الدفع المحفوظة
      final savedMethodsResult = await getSavedPaymentMethods();
      
      return savedMethodsResult.fold(
        (failure) => Left(failure),
        (savedMethods) async {
          // التحقق من وجود طريقة الدفع
          final existingIndex = savedMethods.indexWhere((method) => method.id == paymentMethod.id);
          
          if (existingIndex != -1) {
            // تحديث طريقة الدفع الموجودة
            savedMethods[existingIndex] = paymentMethod;
          } else {
            // إضافة طريقة الدفع الجديدة
            savedMethods.add(paymentMethod);
          }
          
          // تحويل طرق الدفع إلى JSON
          final savedMethodsJson = jsonEncode(
            savedMethods.map((method) => _paymentMethodToJson(method)).toList(),
          );
          
          // حفظ طرق الدفع في التخزين الآمن
          await _secureStorage.saveSecureValue(
            AppConstants.savedPaymentMethodsKey,
            savedMethodsJson,
          );
          
          return Right(paymentMethod);
        },
      );
    } catch (e) {
      return Left(CacheFailure(
        message: 'فشل حفظ طريقة الدفع: $e',
        stackTrace: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, bool>> deletePaymentMethod(String paymentMethodId) async {
    try {
      // الحصول على طرق الدفع المحفوظة
      final savedMethodsResult = await getSavedPaymentMethods();
      
      return savedMethodsResult.fold(
        (failure) => Left(failure),
        (savedMethods) async {
          // حذف طريقة الدفع
          final newMethods = savedMethods.where((method) => method.id != paymentMethodId).toList();
          
          // تحويل طرق الدفع إلى JSON
          final savedMethodsJson = jsonEncode(
            newMethods.map((method) => _paymentMethodToJson(method)).toList(),
          );
          
          // حفظ طرق الدفع في التخزين الآمن
          await _secureStorage.saveSecureValue(
            AppConstants.savedPaymentMethodsKey,
            savedMethodsJson,
          );
          
          return const Right(true);
        },
      );
    } catch (e) {
      return Left(CacheFailure(
        message: 'فشل حذف طريقة الدفع: $e',
        stackTrace: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, bool>> setDefaultPaymentMethod(String paymentMethodId) async {
    try {
      // الحصول على طرق الدفع المحفوظة
      final savedMethodsResult = await getSavedPaymentMethods();
      
      return savedMethodsResult.fold(
        (failure) => Left(failure),
        (savedMethods) async {
          // التحقق من وجود طريقة الدفع
          final methodIndex = savedMethods.indexWhere((method) => method.id == paymentMethodId);
          
          if (methodIndex == -1) {
            return Left(ValidationFailure(
              message: 'طريقة الدفع غير موجودة',
            ));
          }
          
          // تحديث طرق الدفع
          final updatedMethods = savedMethods.map((method) {
            return method.copyWith(
              isDefault: method.id == paymentMethodId,
            );
          }).toList();
          
          // تحويل طرق الدفع إلى JSON
          final savedMethodsJson = jsonEncode(
            updatedMethods.map((method) => _paymentMethodToJson(method)).toList(),
          );
          
          // حفظ طرق الدفع في التخزين الآمن
          await _secureStorage.saveSecureValue(
            AppConstants.savedPaymentMethodsKey,
            savedMethodsJson,
          );
          
          return const Right(true);
        },
      );
    } catch (e) {
      return Left(CacheFailure(
        message: 'فشل تعيين طريقة الدفع الافتراضية: $e',
        stackTrace: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, PaymentIntentEntity>> createPaymentIntent({
    required int amount,
    required String currency,
    required String paymentMethodId,
  }) async {
    try {
      // إنشاء نية الدفع باستخدام Stripe API
      final response = await _httpClient.post(
        Uri.parse('$_apiUrl/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount.toString(),
          'currency': currency,
          'payment_method': paymentMethodId,
          'confirm': 'false',
        },
      );
      
      if (response.statusCode != 200) {
        return Left(ServerFailure(
          message: 'فشل إنشاء نية الدفع: ${response.body}',
          code: response.statusCode.toString(),
        ));
      }
      
      final responseData = jsonDecode(response.body);
      
      final paymentIntent = PaymentIntentEntity(
        id: responseData['id'],
        clientSecret: responseData['client_secret'],
        status: responseData['status'],
        amount: responseData['amount'],
        currency: responseData['currency'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(responseData['created'] * 1000),
      );
      
      // حفظ نية الدفع في التخزين الآمن
      await _savePaymentIntent(paymentIntent);
      
      return Right(paymentIntent);
    } catch (e) {
      return Left(ServerFailure(
        message: 'فشل إنشاء نية الدفع: $e',
        stackTrace: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, PaymentResultEntity>> confirmPayment({
    required String paymentIntentId,
    required String clientSecret,
  }) async {
    try {
      // تأكيد الدفع باستخدام Stripe API
      final response = await _httpClient.post(
        Uri.parse('$_apiUrl/payment_intents/$paymentIntentId/confirm'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
      
      if (response.statusCode != 200) {
        return Left(ServerFailure(
          message: 'فشل تأكيد الدفع: ${response.body}',
          code: response.statusCode.toString(),
        ));
      }
      
      final responseData = jsonDecode(response.body);
      
      final paymentResult = PaymentResultEntity(
        id: paymentIntentId,
        success: responseData['status'] == 'succeeded',
        status: responseData['status'],
        timestamp: DateTime.now(),
      );
      
      // حفظ نتيجة الدفع في التخزين الآمن
      await _savePaymentResult(paymentResult);
      
      return Right(paymentResult);
    } catch (e) {
      return Left(ServerFailure(
        message: 'فشل تأكيد الدفع: $e',
        stackTrace: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, PaymentResultEntity>> processPayment({
    required int amount,
    required String currency,
    required String paymentMethodId,
  }) async {
    try {
      // إنشاء نية الدفع
      final createIntentResult = await createPaymentIntent(
        amount: amount,
        currency: currency,
        paymentMethodId: paymentMethodId,
      );
      
      return createIntentResult.fold(
        (failure) => Left(failure),
        (paymentIntent) async {
          // تأكيد الدفع
          final confirmResult = await confirmPayment(
            paymentIntentId: paymentIntent.id,
            clientSecret: paymentIntent.clientSecret,
          );
          
          return confirmResult;
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'فشل معالجة الدفع: $e',
        stackTrace: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, List<PaymentResultEntity>>> getPaymentHistory() async {
    try {
      // محاولة الحصول على سجل المدفوعات من التخزين الآمن
      final paymentHistoryJson = await _secureStorage.getSecureValue(AppConstants.paymentHistoryKey);
      if (paymentHistoryJson == null) {
        return const Right([]);
      }
      
      final List<dynamic> paymentHistoryList = jsonDecode(paymentHistoryJson);
      final paymentHistory = paymentHistoryList.map((json) => _paymentResultFromJson(json)).toList();
      
      return Right(paymentHistory);
    } catch (e) {
      return Left(CacheFailure(
        message: 'فشل الحصول على سجل المدفوعات: $e',
        stackTrace: e,
      ));
    }
  }
  
  // طرق مساعدة خاصة
  
  /// التحقق من توفر Apple Pay
  Future<bool> _isApplePayAvailable() async {
    try {
      return await Stripe.instance.isApplePaySupported();
    } catch (e) {
      return false;
    }
  }
  
  /// التحقق من توفر Google Pay
  Future<bool> _isGooglePayAvailable() async {
    try {
      return await Stripe.instance.isGooglePaySupported(
        IsGooglePaySupportedParams(),
      );
    } catch (e) {
      return false;
    }
  }
  
  /// حفظ نية الدفع في التخزين الآمن
  Future<void> _savePaymentIntent(PaymentIntentEntity paymentIntent) async {
    try {
      // الحصول على نوايا الدفع المحفوظة
      final paymentIntentsJson = await _secureStorage.getSecureValue(AppConstants.paymentIntentsKey);
      List<Map<String, dynamic>> paymentIntents = [];
      
      if (paymentIntentsJson != null) {
        final List<dynamic> paymentIntentsList = jsonDecode(paymentIntentsJson);
        paymentIntents = paymentIntentsList.cast<Map<String, dynamic>>();
      }
      
      // إضافة نية الدفع الجديدة
      paymentIntents.add(_paymentIntentToJson(paymentIntent));
      
      // حفظ نوايا الدفع في التخزين الآمن
      await _secureStorage.saveSecureValue(
        AppConstants.paymentIntentsKey,
        jsonEncode(paymentIntents),
      );
    } catch (e) {
      print('Error saving payment intent: $e');
    }
  }
  
  /// حفظ نتيجة الدفع في التخزين الآمن
  Future<void> _savePaymentResult(PaymentResultEntity paymentResult) async {
    try {
      // الحصول على سجل المدفوعات
      final paymentHistoryJson = await _secureStorage.getSecureValue(AppConstants.paymentHistoryKey);
      List<Map<String, dynamic>> paymentHistory = [];
      
      if (paymentHistoryJson != null) {
        final List<dynamic> paymentHistoryList = jsonDecode(paymentHistoryJson);
        paymentHistory = paymentHistoryList.cast<Map<String, dynamic>>();
      }
      
      // إضافة نتيجة الدفع الجديدة
      paymentHistory.add(_paymentResultToJson(paymentResult));
      
      // حفظ سجل المدفوعات في التخزين الآمن
      await _secureStorage.saveSecureValue(
        AppConstants.paymentHistoryKey,
        jsonEncode(paymentHistory),
      );
    } catch (e) {
      print('Error saving payment result: $e');
    }
  }
  
  /// تحويل كيان طريقة الدفع إلى JSON
  Map<String, dynamic> _paymentMethodToJson(PaymentMethodEntity paymentMethod) {
    return {
      'id': paymentMethod.id,
      'type': paymentMethod.type.toString().split('.').last,
      'isDefault': paymentMethod.isDefault,
      'card': paymentMethod.card != null ? {
        'last4': paymentMethod.card!.last4,
        'brand': paymentMethod.card!.brand,
        'expiryMonth': paymentMethod.card!.expiryMonth,
        'expiryYear': paymentMethod.card!.expiryYear,
      } : null,
    };
  }
  
  /// تحويل JSON إلى كيان طريقة الدفع
  PaymentMethodEntity _paymentMethodFromJson(Map<String, dynamic> json) {
    return PaymentMethodEntity(
      id: json['id'],
      type: _paymentMethodTypeFromString(json['type']),
      isDefault: json['isDefault'] ?? false,
      card: json['card'] != null ? PaymentMethodCardEntity(
        last4: json['card']['last4'],
        brand: json['card']['brand'],
        expiryMonth: json['card']['expiryMonth'],
        expiryYear: json['card']['expiryYear'],
      ) : null,
    );
  }
  
  /// تحويل كيان نية الدفع إلى JSON
  Map<String, dynamic> _paymentIntentToJson(PaymentIntentEntity paymentIntent) {
    return {
      'id': paymentIntent.id,
      'clientSecret': paymentIntent.clientSecret,
      'status': paymentIntent.status,
      'amount': paymentIntent.amount,
      'currency': paymentIntent.currency,
      'createdAt': paymentIntent.createdAt.toIso8601String(),
    };
  }
  
  /// تحويل JSON إلى كيان نية الدفع
  PaymentIntentEntity _paymentIntentFromJson(Map<String, dynamic> json) {
    return PaymentIntentEntity(
      id: json['id'],
      clientSecret: json['clientSecret'],
      status: json['status'],
      amount: json['amount'],
      currency: json['currency'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
  
  /// تحويل كيان نتيجة الدفع إلى JSON
  Map<String, dynamic> _paymentResultToJson(PaymentResultEntity paymentResult) {
    return {
      'id': paymentResult.id,
      'success': paymentResult.success,
      'status': paymentResult.status,
      'errorMessage': paymentResult.errorMessage,
      'timestamp': paymentResult.timestamp.toIso8601String(),
    };
  }
  
  /// تحويل JSON إلى كيان نتيجة الدفع
  PaymentResultEntity _paymentResultFromJson(Map<String, dynamic> json) {
    return PaymentResultEntity(
      id: json['id'],
      success: json['success'],
      status: json['status'],
      errorMessage: json['errorMessage'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
  
  /// تحويل سلسلة إلى نوع طريقة الدفع
  PaymentMethodType _paymentMethodTypeFromString(String typeString) {
    switch (typeString) {
      case 'card':
        return PaymentMethodType.card;
      case 'paypal':
        return PaymentMethodType.paypal;
      case 'applePay':
        return PaymentMethodType.applePay;
      case 'googlePay':
        return PaymentMethodType.googlePay;
      case 'bankTransfer':
        return PaymentMethodType.bankTransfer;
      default:
        return PaymentMethodType.card;
    }
  }
}
