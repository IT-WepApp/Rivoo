import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// خدمة تسجيل الأخطاء باستخدام Firebase Crashlytics
///
/// تستخدم هذه الخدمة لتسجيل الأخطاء والاستثناءات وإرسالها إلى Firebase Crashlytics
/// لتتبع مشاكل التطبيق وتحليلها

class CrashlyticsService {
  // نسخة واحدة من الخدمة (Singleton)
  static final CrashlyticsService _instance = CrashlyticsService._internal();
  
  // مثيل Firebase Crashlytics
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  
  // منشئ خاص
  CrashlyticsService._internal();
  
  // الحصول على النسخة الوحيدة من الخدمة
  factory CrashlyticsService() {
    return _instance;
  }
  
  /// تهيئة خدمة Crashlytics
  Future<void> initialize() async {
    // تمكين جمع التقارير في وضع التصحيح إذا كان مطلوباً
    await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
    
    // تسجيل الأخطاء غير المعالجة في Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      if (kDebugMode) {
        // طباعة الخطأ في وضع التصحيح
        FlutterError.dumpErrorToConsole(details);
      } else {
        // إرسال الخطأ إلى Crashlytics في وضع الإنتاج
        _crashlytics.recordFlutterError(details);
      }
    };
    
    // تسجيل الأخطاء غير المعالجة في Dart
    PlatformDispatcher.instance.onError = (error, stack) {
      if (kDebugMode) {
        // طباعة الخطأ في وضع التصحيح
        print('Unhandled error: $error');
        print('Stack trace: $stack');
        return true;
      } else {
        // إرسال الخطأ إلى Crashlytics في وضع الإنتاج
        _crashlytics.recordError(error, stack, fatal: true);
        return true;
      }
    };
  }
  
  /// تسجيل خطأ مع معلومات إضافية
  Future<void> recordError(dynamic exception, StackTrace? stack, {
    bool fatal = false,
    String? reason,
    Map<String, dynamic>? information,
  }) async {
    if (kDebugMode) {
      // طباعة الخطأ في وضع التصحيح
      print('Error: $exception');
      print('Reason: $reason');
      print('Information: $information');
      print('Stack trace: $stack');
    } else {
      // إضافة معلومات إضافية إذا كانت متوفرة
      if (information != null) {
        for (final entry in information.entries) {
          await _crashlytics.setCustomKey(entry.key, entry.value.toString());
        }
      }
      
      // إضافة سبب الخطأ إذا كان متوفراً
      if (reason != null) {
        await _crashlytics.setCustomKey('reason', reason);
      }
      
      // تسجيل الخطأ في Crashlytics
      await _crashlytics.recordError(
        exception,
        stack,
        reason: reason,
        fatal: fatal,
      );
    }
  }
  
  /// تسجيل رسالة معلومات
  Future<void> log(String message) async {
    if (kDebugMode) {
      print('Crashlytics log: $message');
    } else {
      await _crashlytics.log(message);
    }
  }
  
  /// تعيين معرف المستخدم لتتبع الأخطاء المرتبطة بمستخدم معين
  Future<void> setUserIdentifier(String userId) async {
    if (!kDebugMode) {
      await _crashlytics.setUserIdentifier(userId);
    }
  }
  
  /// إضافة معلومات مخصصة للمساعدة في تحليل الأخطاء
  Future<void> setCustomKey(String key, dynamic value) async {
    if (!kDebugMode) {
      await _crashlytics.setCustomKey(key, value.toString());
    }
  }
}
