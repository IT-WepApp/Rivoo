import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// مدير تقارير الأعطال
/// يوفر واجهة للتعامل مع خدمة Firebase Crashlytics لتسجيل الأخطاء والاستثناءات
class CrashlyticsManager {
  final FirebaseCrashlytics _crashlytics;

  /// إنشاء نسخة جديدة من مدير تقارير الأعطال
  CrashlyticsManager({FirebaseCrashlytics? crashlytics})
      : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  /// تهيئة خدمة تقارير الأعطال
  Future<void> initialize() async {
    // تمكين جمع تقارير الأعطال في وضع التطوير
    await _crashlytics.setCrashlyticsCollectionEnabled(true);
  }

  /// تسجيل معلومات المستخدم
  ///
  /// [userId] معرف المستخدم
  /// [email] البريد الإلكتروني للمستخدم
  /// [name] اسم المستخدم
  Future<void> setUserIdentifier({
    String? userId,
    String? email,
    String? name,
  }) async {
    if (userId != null) {
      await _crashlytics.setUserIdentifier(userId);
    }

    // تسجيل معلومات إضافية عن المستخدم
    if (email != null) {
      await _crashlytics.setCustomKey('email', email);
    }

    if (name != null) {
      await _crashlytics.setCustomKey('name', name);
    }
  }

  /// تسجيل خطأ
  ///
  /// [error] الخطأ المراد تسجيله
  /// [stackTrace] تتبع المكدس للخطأ
  /// [reason] سبب الخطأ
  Future<void> recordError(
    dynamic error,
    StackTrace stackTrace, {
    String? reason,
  }) async {
    await _crashlytics.recordError(
      error,
      stackTrace,
      reason: reason,
    );
  }

  /// تسجيل رسالة خطأ
  ///
  /// [message] رسالة الخطأ المراد تسجيلها
  Future<void> log(String message) async {
    await _crashlytics.log(message);
  }
}
