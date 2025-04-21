import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// خدمة مراقبة الجلسة
/// تستخدم لمراقبة نشاط المستخدم وإنهاء الجلسة عند عدم النشاط لفترة طويلة
class SessionMonitorService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // مفاتيح التخزين
  static const String _lastActivityKey = 'last_activity';
  static const String _sessionExpiryKey = 'session_expiry';
  static const String _inactivityTimeoutKey = 'inactivity_timeout';

  // القيم الافتراضية
  static const int _defaultSessionExpiryDays = 30; // مدة صلاحية الجلسة بالأيام
  static const int _defaultInactivityTimeoutMinutes =
      30; // مدة عدم النشاط بالدقائق

  /// تحديث وقت آخر نشاط
  /// يتم استدعاء هذه الدالة عند كل تفاعل للمستخدم مع التطبيق
  Future<void> updateLastActivity() async {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    await _secureStorage.write(key: _lastActivityKey, value: now);
  }

  /// التحقق من صلاحية الجلسة
  /// يتم استدعاء هذه الدالة عند بدء التطبيق وعند الانتقال بين الصفحات
  Future<bool> isSessionValid() async {
    try {
      // التحقق من وقت آخر نشاط
      final lastActivityString =
          await _secureStorage.read(key: _lastActivityKey);
      if (lastActivityString == null) return false;

      final lastActivity =
          DateTime.fromMillisecondsSinceEpoch(int.parse(lastActivityString));
      final now = DateTime.now();

      // التحقق من مدة عدم النشاط
      final inactivityTimeout = await getInactivityTimeout();
      final inactivityDuration = now.difference(lastActivity);

      if (inactivityDuration.inMinutes > inactivityTimeout) {
        // إذا تجاوزت مدة عدم النشاط الحد المسموح به، نقوم بإنهاء الجلسة
        return false;
      }

      // التحقق من تاريخ انتهاء صلاحية الجلسة
      final expiryString = await _secureStorage.read(key: _sessionExpiryKey);
      if (expiryString == null) {
        // إذا لم يكن هناك تاريخ انتهاء صلاحية، نقوم بإنشاء واحد جديد
        await setSessionExpiry();
        return true;
      }

      final expiryDate =
          DateTime.fromMillisecondsSinceEpoch(int.parse(expiryString));

      // إذا تجاوز الوقت الحالي تاريخ انتهاء الصلاحية، نقوم بإنهاء الجلسة
      return now.isBefore(expiryDate);
    } catch (e) {
      return false;
    }
  }

  /// تعيين تاريخ انتهاء صلاحية الجلسة
  /// يتم استدعاء هذه الدالة عند تسجيل الدخول
  Future<void> setSessionExpiry(
      {int expiryDays = _defaultSessionExpiryDays}) async {
    final expiryDate = DateTime.now().add(Duration(days: expiryDays));
    await _secureStorage.write(
      key: _sessionExpiryKey,
      value: expiryDate.millisecondsSinceEpoch.toString(),
    );
  }

  /// تعيين مدة عدم النشاط المسموح بها
  /// يمكن للمستخدم تغيير هذه القيمة من إعدادات التطبيق
  Future<void> setInactivityTimeout(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_inactivityTimeoutKey, minutes);
  }

  /// الحصول على مدة عدم النشاط المسموح بها
  Future<int> getInactivityTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_inactivityTimeoutKey) ??
        _defaultInactivityTimeoutMinutes;
  }

  /// إنهاء الجلسة
  /// يتم استدعاء هذه الدالة عند تسجيل الخروج أو عند انتهاء صلاحية الجلسة
  Future<void> endSession() async {
    await _secureStorage.delete(key: _lastActivityKey);
    await _secureStorage.delete(key: _sessionExpiryKey);
  }

  /// إنشاء توقيع للجلسة
  /// يستخدم للتحقق من صحة الجلسة
  Future<String> createSessionSignature(String userId) async {
    final lastActivityString = await _secureStorage.read(key: _lastActivityKey);
    final expiryString = await _secureStorage.read(key: _sessionExpiryKey);

    if (lastActivityString == null || expiryString == null) {
      throw Exception('Session data not found');
    }

    final data = '$userId:$lastActivityString:$expiryString';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);

    return digest.toString();
  }

  /// التحقق من صحة توقيع الجلسة
  Future<bool> verifySessionSignature(String userId, String signature) async {
    try {
      final calculatedSignature = await createSessionSignature(userId);
      return signature == calculatedSignature;
    } catch (e) {
      return false;
    }
  }
}
