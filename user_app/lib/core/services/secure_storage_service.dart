import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة التخزين الآمن للبيانات الحساسة
class SecureStorageService {
  final FlutterSecureStorage _storage;
  final String _encryptionKey = 'RivooSy_SecureStorage_Key'; // مفتاح للتشفير المحلي

  /// إنشاء نسخة من خدمة التخزين الآمن
  SecureStorageService() : _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
      synchronizable: false,
    ),
  );

  /// حفظ قيمة في التخزين الآمن
  Future<void> write({required String key, required String value}) async {
    // تشفير القيمة قبل التخزين
    final encryptedValue = _encrypt(value);
    await _storage.write(key: key, value: encryptedValue);
  }

  /// قراءة قيمة من التخزين الآمن
  Future<String?> read({required String key}) async {
    final encryptedValue = await _storage.read(key: key);
    if (encryptedValue == null) return null;
    
    // فك تشفير القيمة
    return _decrypt(encryptedValue);
  }

  /// حذف قيمة من التخزين الآمن
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  /// حذف جميع القيم من التخزين الآمن
  Future<void> deleteAll() async {
    await _storage.deleteAll();
    
    // حذف أي بيانات مخزنة في SharedPreferences أيضًا
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// التحقق من وجود قيمة في التخزين الآمن
  Future<bool> containsKey({required String key}) async {
    return await _storage.containsKey(key: key);
  }

  /// الحصول على جميع القيم من التخزين الآمن
  Future<Map<String, String>> readAll() async {
    final encryptedMap = await _storage.readAll();
    final decryptedMap = <String, String>{};
    
    // فك تشفير جميع القيم
    for (final entry in encryptedMap.entries) {
      final decryptedValue = _decrypt(entry.value);
      if (decryptedValue != null) {
        decryptedMap[entry.key] = decryptedValue;
      }
    }
    
    return decryptedMap;
  }

  /// حفظ رمز المصادقة
  Future<void> saveAuthToken(String token) async {
    await write(key: 'auth_token', value: token);
    
    // حفظ تاريخ انتهاء الصلاحية (مثلاً بعد ساعة)
    final expiryTime = DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch.toString();
    await write(key: 'auth_token_expiry', value: expiryTime);
  }

  /// قراءة رمز المصادقة
  Future<String?> getAuthToken() async {
    // التحقق من انتهاء صلاحية الرمز
    final expiryTimeStr = await read(key: 'auth_token_expiry');
    if (expiryTimeStr != null) {
      final expiryTime = int.tryParse(expiryTimeStr) ?? 0;
      if (DateTime.now().millisecondsSinceEpoch > expiryTime) {
        // الرمز منتهي الصلاحية، حذفه
        await delete(key: 'auth_token');
        await delete(key: 'auth_token_expiry');
        return null;
      }
    }
    
    return await read(key: 'auth_token');
  }

  /// حفظ معرف المستخدم
  Future<void> saveUserId(String userId) async {
    await write(key: 'user_id', value: userId);
  }

  /// قراءة معرف المستخدم
  Future<String?> getUserId() async {
    return await read(key: 'user_id');
  }

  /// حفظ بريد المستخدم الإلكتروني
  Future<void> saveUserEmail(String email) async {
    await write(key: 'user_email', value: email);
  }

  /// قراءة بريد المستخدم الإلكتروني
  Future<String?> getUserEmail() async {
    return await read(key: 'user_email');
  }

  /// حفظ اسم المستخدم
  Future<void> saveUserName(String name) async {
    await write(key: 'user_name', value: name);
  }

  /// قراءة اسم المستخدم
  Future<String?> getUserName() async {
    return await read(key: 'user_name');
  }

  /// حفظ حالة تسجيل الدخول
  Future<void> saveIsLoggedIn(bool isLoggedIn) async {
    await write(key: 'is_logged_in', value: isLoggedIn.toString());
  }

  /// قراءة حالة تسجيل الدخول
  Future<bool> getIsLoggedIn() async {
    final value = await read(key: 'is_logged_in');
    return value == 'true';
  }

  /// حفظ رمز FCM
  Future<void> saveFCMToken(String token) async {
    await write(key: 'fcm_token', value: token);
  }

  /// قراءة رمز FCM
  Future<String?> getFCMToken() async {
    return await read(key: 'fcm_token');
  }

  /// حفظ رمز تحديث المصادقة
  Future<void> saveRefreshToken(String token) async {
    await write(key: 'refresh_token', value: token);
    
    // حفظ تاريخ انتهاء الصلاحية (مثلاً بعد 30 يوم)
    final expiryTime = DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch.toString();
    await write(key: 'refresh_token_expiry', value: expiryTime);
  }

  /// قراءة رمز تحديث المصادقة
  Future<String?> getRefreshToken() async {
    // التحقق من انتهاء صلاحية الرمز
    final expiryTimeStr = await read(key: 'refresh_token_expiry');
    if (expiryTimeStr != null) {
      final expiryTime = int.tryParse(expiryTimeStr) ?? 0;
      if (DateTime.now().millisecondsSinceEpoch > expiryTime) {
        // الرمز منتهي الصلاحية، حذفه
        await delete(key: 'refresh_token');
        await delete(key: 'refresh_token_expiry');
        return null;
      }
    }
    
    return await read(key: 'refresh_token');
  }

  /// حفظ دور المستخدم
  Future<void> saveUserRole(String role) async {
    await write(key: 'user_role', value: role);
  }

  /// قراءة دور المستخدم
  Future<String?> getUserRole() async {
    return await read(key: 'user_role');
  }

  /// مسح بيانات المصادقة
  Future<void> clearAuthData() async {
    await delete(key: 'auth_token');
    await delete(key: 'auth_token_expiry');
    await delete(key: 'refresh_token');
    await delete(key: 'refresh_token_expiry');
    await delete(key: 'user_id');
    await delete(key: 'user_email');
    await delete(key: 'user_name');
    await delete(key: 'is_logged_in');
    await delete(key: 'user_role');
  }

  /// تشفير البيانات
  String _encrypt(String data) {
    // استخدام SHA-256 لتشفير البيانات
    // في التطبيق الحقيقي، يجب استخدام خوارزمية تشفير أكثر أمانًا مثل AES
    final key = utf8.encode(_encryptionKey);
    final bytes = utf8.encode(data);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    
    // دمج البيانات الأصلية مع قيمة التشفير
    final combined = base64Encode(bytes) + '.' + digest.toString();
    return combined;
  }

  /// فك تشفير البيانات
  String? _decrypt(String encryptedData) {
    try {
      // فصل البيانات المشفرة عن قيمة التشفير
      final parts = encryptedData.split('.');
      if (parts.length != 2) return null;
      
      final encodedData = parts[0];
      final digestValue = parts[1];
      
      // فك تشفير البيانات
      final bytes = base64Decode(encodedData);
      final data = utf8.decode(bytes);
      
      // التحقق من صحة البيانات
      final key = utf8.encode(_encryptionKey);
      final hmacSha256 = Hmac(sha256, key);
      final digest = hmacSha256.convert(bytes);
      
      if (digest.toString() != digestValue) {
        // البيانات قد تكون تم العبث بها
        return null;
      }
      
      return data;
    } catch (e) {
      print('Error decrypting data: $e');
      return null;
    }
  }
}
