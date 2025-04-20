import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'crashlytics_service.g.dart';

/// خدمة تكامل Crashlytics لتتبع الأخطاء وتحليلها
class CrashlyticsService {
  final FirebaseCrashlytics _crashlytics;
  
  CrashlyticsService({required FirebaseCrashlytics crashlytics}) 
    : _crashlytics = crashlytics;
  
  /// تهيئة خدمة Crashlytics
  Future<void> initialize() async {
    // تعطيل Crashlytics في وضع التصحيح
    await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
    
    // تسجيل الأخطاء غير المعالجة في Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      _crashlytics.recordFlutterError(details);
    };
    
    // تسجيل الأخطاء غير المعالجة في Dart
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
    
    debugPrint('تم تهيئة Crashlytics بنجاح');
  }
  
  /// تسجيل خطأ في Crashlytics
  Future<void> recordError(dynamic exception, StackTrace? stack, {bool fatal = false}) async {
    await _crashlytics.recordError(
      exception,
      stack,
      fatal: fatal,
      printDetails: true,
    );
  }
  
  /// تسجيل رسالة خطأ مخصصة
  Future<void> log(String message) async {
    await _crashlytics.log(message);
  }
  
  /// تعيين معرف المستخدم لتحسين تحليل الأخطاء
  Future<void> setUserIdentifier(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
  }
  
  /// إضافة بيانات سياقية للمساعدة في تشخيص الأخطاء
  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }
  
  /// اختبار تقرير الأعطال (للتحقق من التكامل)
  Future<void> testCrash() async {
    await _crashlytics.crash();
  }
}

/// مزود خدمة Crashlytics
@riverpod
CrashlyticsService crashlyticsService(CrashlyticsServiceRef ref) {
  return CrashlyticsService(
    crashlytics: FirebaseCrashlytics.instance,
  );
}

/// مزود لتهيئة Crashlytics
@riverpod
Future<void> initializeCrashlytics(InitializeCrashlyticsRef ref) async {
  final crashlyticsService = ref.read(crashlyticsServiceProvider);
  await crashlyticsService.initialize();
}

/// دالة مساعدة لتسجيل الأخطاء في Crashlytics
Future<void> recordErrorToCrashlytics(
  dynamic exception,
  StackTrace? stack, {
  bool fatal = false,
  String? reason,
  Map<String, dynamic>? information,
}) async {
  final crashlytics = FirebaseCrashlytics.instance;
  
  // تسجيل سبب الخطأ إذا كان متوفرًا
  if (reason != null) {
    await crashlytics.log('سبب الخطأ: $reason');
  }
  
  // تسجيل معلومات إضافية إذا كانت متوفرة
  if (information != null) {
    for (final entry in information.entries) {
      await crashlytics.setCustomKey(entry.key, entry.value.toString());
    }
  }
  
  // تسجيل الخطأ
  await crashlytics.recordError(
    exception,
    stack,
    fatal: fatal,
    printDetails: true,
  );
}
