import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// مدير تقارير الأعطال باستخدام Firebase Crashlytics
class CrashlyticsManager {
  final FirebaseCrashlytics _crashlytics;

  CrashlyticsManager({FirebaseCrashlytics? crashlytics})
      : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  /// تهيئة مدير تقارير الأعطال
  Future<void> initialize() async {
    // تعطيل Crashlytics في وضع التصحيح
    await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

    // تسجيل الأخطاء غير المعالجة في Flutter
    FlutterError.onError = _crashlytics.recordFlutterError;
  }

  /// تسجيل معلومات المستخدم
  Future<void> setUserIdentifier({String? userId}) async {
    await _crashlytics.setUserIdentifier(userId ?? '');
  }

  /// تسجيل خطأ مع رسالة
  Future<void> recordError(dynamic error, StackTrace stackTrace,
      {String? reason}) async {
    await _crashlytics.recordError(
      error,
      stackTrace,
      reason: reason,
    );
  }

  /// تسجيل رسالة سجل
  Future<void> log(String message) async {
    await _crashlytics.log(message);
  }

  /// تعيين مفتاح قيمة إضافي
  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }
}
