import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// خدمة التحليلات المسؤولة عن تتبع سلوك المستخدم وأداء التطبيق
/// تستخدم Firebase Analytics لجمع وتحليل بيانات استخدام التطبيق
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  late FirebaseAnalytics _analytics;
  
  /// تهيئة خدمة التحليلات
  Future<void> init() async {
    _analytics = FirebaseAnalytics.instance;
    await _analytics.setAnalyticsCollectionEnabled(true);
  }

  /// تسجيل حدث تسجيل الدخول
  Future<void> logLogin({String? loginMethod}) async {
    await _analytics.logLogin(loginMethod: loginMethod ?? 'email');
  }

  /// تسجيل حدث تسجيل مستخدم جديد
  Future<void> logSignUp({String? signUpMethod}) async {
    await _analytics.logSignUp(signUpMethod: signUpMethod ?? 'email');
  }

  /// تسجيل حدث بدء جلسة
  Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  /// تسجيل حدث شراء
  Future<void> logPurchase({
    required double value,
    required String currency,
    List<AnalyticsEventItem>? items,
  }) async {
    await _analytics.logPurchase(
      currency: currency,
      value: value,
      items: items,
    );
  }

  /// تسجيل حدث إضافة إلى السلة
  Future<void> logAddToCart({
    required double value,
    required String currency,
    required List<AnalyticsEventItem> items,
  }) async {
    await _analytics.logAddToCart(
      currency: currency,
      value: value,
      items: items,
    );
  }

  /// تسجيل حدث بدء عملية الدفع
  Future<void> logBeginCheckout({
    required double value,
    required String currency,
    required List<AnalyticsEventItem> items,
  }) async {
    await _analytics.logBeginCheckout(
      currency: currency,
      value: value,
      items: items,
    );
  }

  /// تسجيل حدث مشاهدة منتج
  Future<void> logViewItem({
    required double value,
    required String currency,
    required List<AnalyticsEventItem> items,
  }) async {
    await _analytics.logViewItem(
      currency: currency,
      value: value,
      items: items,
    );
  }

  /// تسجيل حدث مشاهدة قائمة منتجات
  Future<void> logViewItemList({
    required List<AnalyticsEventItem> items,
    required String itemListId,
    required String itemListName,
  }) async {
    await _analytics.logViewItemList(
      items: items,
      itemListId: itemListId,
      itemListName: itemListName,
    );
  }

  /// تسجيل حدث بحث
  Future<void> logSearch({required String searchTerm}) async {
    await _analytics.logSearch(searchTerm: searchTerm);
  }

  /// تسجيل حدث مشاركة
  Future<void> logShare({
    required String contentType,
    required String itemId,
    required String method,
  }) async {
    await _analytics.logShare(
      contentType: contentType,
      itemId: itemId,
      method: method,
    );
  }

  /// تسجيل حدث مخصص
  Future<void> logCustomEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في تسجيل حدث مخصص: $e');
      }
    }
  }

  /// تعيين معرف المستخدم
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  /// تعيين خصائص المستخدم
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  /// إعادة تعيين بيانات المستخدم
  Future<void> resetUser() async {
    await _analytics.setUserId(id: null);
  }
}
