import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  // تسجيل حدث مشاهدة شاشة
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  // تسجيل حدث تسجيل الدخول
  Future<void> logLogin({String? loginMethod}) async {
    await _analytics.logLogin(loginMethod: loginMethod);
  }

  // تسجيل حدث تسجيل مستخدم جديد
  Future<void> logSignUp({String? signUpMethod}) async {
    await _analytics.logSignUp(signUpMethod: signUpMethod);
  }

  // تسجيل حدث بدء عملية شراء
  Future<void> logBeginCheckout({
    double? value,
    String? currency,
    List<AnalyticsEventItem>? items,
  }) async {
    await _analytics.logBeginCheckout(
      value: value,
      currency: currency,
      items: items,
    );
  }

  // تسجيل حدث إتمام عملية شراء
  Future<void> logPurchase({
    required double value,
    required String currency,
    String? transactionId,
    List<AnalyticsEventItem>? items,
  }) async {
    await _analytics.logPurchase(
      value: value,
      currency: currency,
      transactionId: transactionId,
      items: items,
    );
  }

  // تسجيل حدث إضافة منتج إلى سلة التسوق
  Future<void> logAddToCart({
    required double value,
    required String currency,
    required List<AnalyticsEventItem> items,
  }) async {
    await _analytics.logAddToCart(
      value: value,
      currency: currency,
      items: items,
    );
  }

  // تسجيل حدث إزالة منتج من سلة التسوق
  Future<void> logRemoveFromCart({
    required double value,
    required String currency,
    required List<AnalyticsEventItem> items,
  }) async {
    await _analytics.logRemoveFromCart(
      value: value,
      currency: currency,
      items: items,
    );
  }

  // تسجيل حدث عرض منتج
  Future<void> logViewItem({
    required double value,
    required String currency,
    required List<AnalyticsEventItem> items,
  }) async {
    await _analytics.logViewItem(
      value: value,
      currency: currency,
      items: items,
    );
  }

  // تسجيل حدث البحث
  Future<void> logSearch({required String searchTerm}) async {
    await _analytics.logSearch(searchTerm: searchTerm);
  }

  // تسجيل حدث مشاركة محتوى
  Future<void> logShare({
    required String contentType,
    required String itemId,
    String? method,
  }) async {
    await _analytics.logShare(
      contentType: contentType,
      itemId: itemId,
      method: method,
    );
  }

  // تسجيل حدث مخصص
  Future<void> logCustomEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  // تعيين خصائص المستخدم
  Future<void> setUserProperties({
    String? userId,
    String? userRole,
    String? userLanguage,
    String? userTheme,
  }) async {
    if (userId != null) {
      await _analytics.setUserId(id: userId);
    }

    if (userRole != null) {
      await _analytics.setUserProperty(name: 'user_role', value: userRole);
    }

    if (userLanguage != null) {
      await _analytics.setUserProperty(
          name: 'user_language', value: userLanguage);
    }

    if (userTheme != null) {
      await _analytics.setUserProperty(name: 'user_theme', value: userTheme);
    }
  }
}

class PerformanceService {
  final FirebasePerformance _performance;
  final Map<String, Trace> _activeTraces = {};
  final Map<String, HttpMetric> _activeHttpMetrics = {};

  PerformanceService({FirebasePerformance? performance})
      : _performance = performance ?? FirebasePerformance.instance;

  // بدء قياس أداء عملية معينة
  Future<void> startTrace(String traceName) async {
    if (_activeTraces.containsKey(traceName)) {
      debugPrint('Trace $traceName is already running');
      return;
    }

    final trace = _performance.newTrace(traceName);
    await trace.start();
    _activeTraces[traceName] = trace;
  }

  // إضافة قيمة متغير إلى قياس الأداء
  void setTraceAttribute(String traceName, String attributeName, String value) {
    final trace = _activeTraces[traceName];
    if (trace == null) {
      debugPrint('Trace $traceName is not running');
      return;
    }

    trace.putAttribute(attributeName, value);
  }

  // إضافة قيمة عددية إلى قياس الأداء
  void incrementTraceMetric(
      String traceName, String metricName, int incrementBy) {
    final trace = _activeTraces[traceName];
    if (trace == null) {
      debugPrint('Trace $traceName is not running');
      return;
    }

    trace.incrementMetric(metricName, incrementBy);
  }

  // إنهاء قياس أداء عملية معينة
  Future<void> stopTrace(String traceName) async {
    final trace = _activeTraces[traceName];
    if (trace == null) {
      debugPrint('Trace $traceName is not running');
      return;
    }

    await trace.stop();
    _activeTraces.remove(traceName);
  }

  // بدء قياس أداء طلب HTTP
  Future<void> startHttpMetric(
    String url,
    String httpMethod, {
    String? metricName,
  }) async {
    final name = metricName ?? '${httpMethod}_${url.hashCode}';

    if (_activeHttpMetrics.containsKey(name)) {
      debugPrint('HTTP Metric $name is already running');
      return;
    }

    final metric = _performance.newHttpMetric(url, _getHttpMethod(httpMethod));
    await metric.start();
    _activeHttpMetrics[name] = metric;
  }

  // إنهاء قياس أداء طلب HTTP
  Future<void> stopHttpMetric(
    String url,
    String httpMethod, {
    String? metricName,
    int? responseCode,
    int? requestPayloadSize,
    int? responsePayloadSize,
    String? contentType,
  }) async {
    final name = metricName ?? '${httpMethod}_${url.hashCode}';

    final metric = _activeHttpMetrics[name];
    if (metric == null) {
      debugPrint('HTTP Metric $name is not running');
      return;
    }

    if (responseCode != null) {
      metric.httpResponseCode = responseCode;
    }

    if (requestPayloadSize != null) {
      metric.requestPayloadSize = requestPayloadSize;
    }

    if (responsePayloadSize != null) {
      metric.responsePayloadSize = responsePayloadSize;
    }

    if (contentType != null) {
      metric.putAttribute('content_type', contentType);
    }

    await metric.stop();
    _activeHttpMetrics.remove(name);
  }

  // تحويل نص طريقة HTTP إلى نوع HttpMethod
  HttpMethod _getHttpMethod(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return HttpMethod.Get;
      case 'POST':
        return HttpMethod.Post;
      case 'PUT':
        return HttpMethod.Put;
      case 'DELETE':
        return HttpMethod.Delete;
      case 'PATCH':
        return HttpMethod.Patch;
      case 'OPTIONS':
        return HttpMethod.Options;
      case 'HEAD':
        return HttpMethod.Head;
      case 'TRACE':
        return HttpMethod.Trace;
      case 'CONNECT':
        return HttpMethod.Connect;
      default:
        return HttpMethod.Get;
    }
  }
}
