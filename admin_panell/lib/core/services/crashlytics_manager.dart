import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// مدير Crashlytics للتعامل مع تسجيل الأخطاء والاستثناءات
class CrashlyticsManager {
  final FirebaseCrashlytics _crashlytics;

  CrashlyticsManager({FirebaseCrashlytics? crashlytics})
      : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  /// تهيئة Crashlytics وإعداد التقاط الاستثناءات غير المعالجة
  Future<void> initialize() async {
    // تمكين جمع التقارير في وضع التطوير إذا كان مطلوباً
    await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

    // تسجيل الاستثناءات غير المعالجة في Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      _crashlytics.recordFlutterError(details);
    };

    // تسجيل الاستثناءات غير المعالجة في Dart
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// تسجيل استثناء يدوياً
  Future<void> recordError(dynamic exception, StackTrace? stack,
      {bool fatal = false}) async {
    await _crashlytics.recordError(exception, stack, fatal: fatal);
  }

  /// تسجيل رسالة خطأ بسيطة
  Future<void> log(String message) async {
    await _crashlytics.log(message);
  }

  /// تعيين معرف المستخدم لتسهيل تتبع الأخطاء
  Future<void> setUserIdentifier(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
  }

  /// إضافة بيانات مخصصة للمساعدة في تشخيص المشكلات
  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }
}

// مزود للوصول إلى مدير Crashlytics من أي مكان في التطبيق
final crashlyticsManagerProvider = CrashlyticsManager();
