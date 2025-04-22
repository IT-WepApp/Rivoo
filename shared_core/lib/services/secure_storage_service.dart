import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة التخزين الآمن المحسنة
/// توفر طبقة إضافية من الأمان لتخزين البيانات الحساسة
class SecureStorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // مفتاح التشفير المستخدم لتوقيع البيانات
  static const String _encryptionKeyKey = 'encryption_key';

  /// تخزين قيمة بشكل آمن
  /// يتم تشفير القيمة وإضافة توقيع رقمي للتحقق من سلامتها
  Future<void> secureWrite({
    required String key,
    required String value,
    bool withBiometrics = false,
  }) async {
    try {
      // الحصول على مفتاح التشفير أو إنشاء مفتاح جديد
      final encryptionKey = await _getOrCreateEncryptionKey();

      // إنشاء توقيع رقمي للبيانات
      final signature = _createSignature(value, encryptionKey);

      // تخزين البيانات مع التوقيع
      final secureData = json.encode({
        'data': value,
        'signature': signature,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      // تحديد خيارات التخزين الآمن
      final options = withBiometrics
          ? const AndroidOptions(resetOnError: true)
          : null;

      // تخزين البيانات بشكل آمن
      await _secureStorage.write(
        key: key,
        value: secureData,
        aOptions: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// قراءة قيمة مخزنة بشكل آمن
  /// يتم التحقق من التوقيع الرقمي للتأكد من سلامة البيانات
  Future<String?> secureRead({
    required String key,
    bool withBiometrics = false,
  }) async {
    try {
      // تحديد خيارات التخزين الآمن
      final options = withBiometrics
          ? const AndroidOptions(resetOnError: true)
          : null;

      // قراءة البيانات المخزنة
      final secureData = await _secureStorage.read(
        key: key,
        aOptions: options,
      );

      if (secureData == null) return null;

      // تحليل البيانات المخزنة
      final Map<String, dynamic> data = json.decode(secureData);
      final storedValue = data['data'] as String;
      final storedSignature = data['signature'] as String;

      // الحصول على مفتاح التشفير
      final encryptionKey = await _getEncryptionKey();
      if (encryptionKey == null) return null;

      // التحقق من التوقيع الرقمي
      final calculatedSignature = _createSignature(storedValue, encryptionKey);
      if (calculatedSignature != storedSignature) {
        // إذا كان التوقيع غير متطابق، فقد تم العبث بالبيانات
        await _secureStorage.delete(key: key);
        return null;
      }

      return storedValue;
    } catch (e) {
      return null;
    }
  }

  /// حذف قيمة مخزنة
  Future<void> secureDelete({required String key}) async {
    await _secureStorage.delete(key: key);
  }

  /// حذف جميع القيم المخزنة
  Future<void> secureDeleteAll() async {
    await _secureStorage.deleteAll();
  }

  /// إنشاء توقيع رقمي للبيانات
  String _createSignature(String data, String key) {
    final hmac = Hmac(sha256, utf8.encode(key));
    final digest = hmac.convert(utf8.encode(data));
    return digest.toString();
  }

  /// الحصول على مفتاح التشفير المخزن
  Future<String?> _getEncryptionKey() async {
    return await _secureStorage.read(key: _encryptionKeyKey);
  }

  /// الحصول على مفتاح التشفير المخزن أو إنشاء مفتاح جديد
  Future<String> _getOrCreateEncryptionKey() async {
    final existingKey = await _getEncryptionKey();
    if (existingKey != null) return existingKey;

    // إنشاء مفتاح تشفير جديد
    final key = _generateRandomKey();
    await _secureStorage.write(key: _encryptionKeyKey, value: key);
    return key;
  }

  /// إنشاء مفتاح عشوائي
  String _generateRandomKey() {
    final random = List<int>.generate(
        32, (i) => DateTime.now().microsecondsSinceEpoch % 256);
    return base64Url.encode(random);
  }

  /// تخزين بيانات غير حساسة
  Future<bool> savePreference(
      {required String key, required String value}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(key, value);
    } catch (e) {
      return false;
    }
  }

  /// قراءة بيانات غير حساسة
  Future<String?> getPreference({required String key}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e) {
      return null;
    }
  }

  /// حذف بيانات غير حساسة
  Future<bool> removePreference({required String key}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(key);
    } catch (e) {
      return false;
    }
  }
}
