import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import '../services/analytics_service.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(analytics: FirebaseAnalytics.instance);
});

final performanceServiceProvider = Provider<PerformanceService>((ref) {
  return PerformanceService(performance: FirebasePerformance.instance);
});

class AnalyticsObserver extends NavigatorObserver {
  final AnalyticsService _analyticsService;

  AnalyticsObserver(this._analyticsService);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _sendScreenView(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _sendScreenView(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _sendScreenView(previousRoute);
    }
  }

  void _sendScreenView(Route<dynamic> route) {
    final screenName = _getScreenName(route);
    if (screenName != null) {
      _analyticsService.logScreenView(
        screenName: screenName,
        screenClass: route.settings.name,
      );
    }
  }

  String? _getScreenName(Route<dynamic> route) {
    if (route.settings.name != null) {
      return route.settings.name;
    }

    // محاولة استخراج اسم الشاشة من نوع الصفحة
    final routeStr = route.toString();
    if (routeStr.contains('MaterialPageRoute') ||
        routeStr.contains('CupertinoPageRoute')) {
      final regex = RegExp(r'[A-Za-z]+Screen');
      final match = regex.firstMatch(routeStr);
      if (match != null) {
        return match.group(0);
      }
    }

    return null;
  }
}

// مزود لمراقب التحليلات
final analyticsObserverProvider = Provider<AnalyticsObserver>((ref) {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return AnalyticsObserver(analyticsService);
});

// مزود لقياس أداء التطبيق
class PerformanceMonitor {
  final PerformanceService _performanceService;

  PerformanceMonitor(this._performanceService);

  // قياس أداء تحميل الصفحة
  void monitorPageLoad(String pageName, VoidCallback onComplete) {
    final traceName = 'page_load_$pageName';
    _performanceService.startTrace(traceName);

    // استدعاء onComplete عند اكتمال تحميل الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performanceService.stopTrace(traceName);
      onComplete();
    });
  }

  // قياس أداء عملية معينة
  Future<T> monitorOperation<T>({
    required String operationName,
    required Future<T> Function() operation,
    Map<String, String>? attributes,
  }) async {
    final traceName = 'operation_$operationName';
    await _performanceService.startTrace(traceName);

    if (attributes != null) {
      attributes.forEach((key, value) {
        _performanceService.setTraceAttribute(traceName, key, value);
      });
    }

    try {
      final result = await operation();
      await _performanceService.stopTrace(traceName);
      return result;
    } catch (e) {
      _performanceService.setTraceAttribute(traceName, 'error', e.toString());
      await _performanceService.stopTrace(traceName);
      rethrow;
    }
  }

  // قياس أداء طلب HTTP
  Future<T> monitorHttpRequest<T>({
    required String url,
    required String method,
    required Future<T> Function() request,
    int? responseCode,
    int? requestSize,
    int? responseSize,
    String? contentType,
  }) async {
    await _performanceService.startHttpMetric(url, method);

    try {
      final result = await request();

      await _performanceService.stopHttpMetric(
        url,
        method,
        responseCode: responseCode,
        requestPayloadSize: requestSize,
        responsePayloadSize: responseSize,
        contentType: contentType,
      );

      return result;
    } catch (e) {
      await _performanceService.stopHttpMetric(
        url,
        method,
        responseCode: 500, // افتراضي للخطأ
      );
      rethrow;
    }
  }
}

// مزود لمراقب الأداء
final performanceMonitorProvider = Provider<PerformanceMonitor>((ref) {
  final performanceService = ref.watch(performanceServiceProvider);
  return PerformanceMonitor(performanceService);
});
