import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../monitoring/analytics_monitor.dart';
import '../services/analytics_service.dart';

/// مزود للتحليلات يمكن استخدامه في أي مكان في التطبيق
class AnalyticsWrapper extends ConsumerWidget {
  final Widget child;
  final String screenName;
  final Map<String, dynamic>? screenParameters;

  const AnalyticsWrapper({
    Key? key,
    required this.child,
    required this.screenName,
    this.screenParameters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsService = ref.watch(analyticsServiceProvider);
    final performanceMonitor = ref.watch(performanceMonitorProvider);

    // تسجيل مشاهدة الشاشة عند بناء الواجهة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      analyticsService.logScreenView(
        screenName: screenName,
        screenClass: screenName,
      );

      if (screenParameters != null) {
        analyticsService.logCustomEvent(
          name: 'screen_view_with_params',
          parameters: {
            'screen_name': screenName,
            ...screenParameters!,
          },
        );
      }
    });

    // قياس أداء تحميل الشاشة
    performanceMonitor.monitorPageLoad(screenName, () {
      // تم تحميل الشاشة بنجاح
    });

    return child;
  }
}

/// مزود للتحليلات يمكن استخدامه في أي مكان في التطبيق
class AnalyticsProvider {
  final AnalyticsService _analyticsService;
  final PerformanceMonitor _performanceMonitor;

  AnalyticsProvider(this._analyticsService, this._performanceMonitor);

  // تسجيل حدث النقر على زر
  void logButtonClick(String buttonName, {Map<String, dynamic>? parameters}) {
    final params = {
      'button_name': buttonName,
      ...?parameters,
    };
    _analyticsService.logCustomEvent(
      name: 'button_click',
      parameters: params,
    );
  }

  // تسجيل حدث إضافة منتج إلى سلة التسوق
  void logAddToCart({
    required String productId,
    required String productName,
    required double price,
    required int quantity,
    String? currency = 'USD',
  }) {
    final items = [
      AnalyticsEventItem(
        itemId: productId,
        itemName: productName,
        price: price,
        quantity: quantity,
      ),
    ];

    _analyticsService.logAddToCart(
      value: price * quantity,
      currency: currency ?? 'USD',
      items: items,
    );
  }

  // تسجيل حدث إتمام عملية شراء
  void logPurchase({
    required String orderId,
    required double totalValue,
    required List<Map<String, dynamic>> products,
    String? currency = 'USD',
  }) {
    final items = products.map((product) {
      return AnalyticsEventItem(
        itemId: product['id'],
        itemName: product['name'],
        price: product['price'],
        quantity: product['quantity'],
      );
    }).toList();

    _analyticsService.logPurchase(
      value: totalValue,
      currency: currency ?? 'USD',
      transactionId: orderId,
      items: items,
    );
  }

  // تسجيل حدث البحث
  void logSearch(String searchTerm) {
    _analyticsService.logSearch(searchTerm: searchTerm);
  }

  // تسجيل حدث تسجيل الدخول
  void logLogin(String method) {
    _analyticsService.logLogin(loginMethod: method);
  }

  // تسجيل حدث تسجيل مستخدم جديد
  void logSignUp(String method) {
    _analyticsService.logSignUp(signUpMethod: method);
  }

  // قياس أداء عملية معينة
  Future<T> measureOperation<T>({
    required String operationName,
    required Future<T> Function() operation,
    Map<String, String>? attributes,
  }) {
    return _performanceMonitor.monitorOperation(
      operationName: operationName,
      operation: operation,
      attributes: attributes,
    );
  }

  // قياس أداء طلب HTTP
  Future<T> measureHttpRequest<T>({
    required String url,
    required String method,
    required Future<T> Function() request,
    int? responseCode,
    int? requestSize,
    int? responseSize,
    String? contentType,
  }) {
    return _performanceMonitor.monitorHttpRequest(
      url: url,
      method: method,
      request: request,
      responseCode: responseCode,
      requestSize: requestSize,
      responseSize: responseSize,
      contentType: contentType,
    );
  }
}

// مزود لخدمة التحليلات
final analyticsProviderService = Provider<AnalyticsProvider>((ref) {
  final analyticsService = ref.watch(analyticsServiceProvider);
  final performanceMonitor = ref.watch(performanceMonitorProvider);
  return AnalyticsProvider(analyticsService, performanceMonitor);
});
