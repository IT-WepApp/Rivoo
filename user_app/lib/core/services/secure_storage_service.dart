import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// خدمة التخزين الآمن للبيانات الحساسة
class SecureStorageService {
  final FlutterSecureStorage _storage;

  /// إنشاء نسخة من خدمة التخزين الآمن
  SecureStorageService() : _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  /// حفظ قيمة في التخزين الآمن
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  /// قراءة قيمة من التخزين الآمن
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  /// حذف قيمة من التخزين الآمن
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  /// حذف جميع القيم من التخزين الآمن
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  /// التحقق من وجود قيمة في التخزين الآمن
  Future<bool> containsKey({required String key}) async {
    return await _storage.containsKey(key: key);
  }

  /// الحصول على جميع القيم من التخزين الآمن
  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }

  /// حفظ رمز المصادقة
  Future<void> saveAuthToken(String token) async {
    await write(key: 'auth_token', value: token);
  }

  /// قراءة رمز المصادقة
  Future<String?> getAuthToken() async {
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
  }

  /// قراءة رمز تحديث المصادقة
  Future<String?> getRefreshToken() async {
    return await read(key: 'refresh_token');
  }

  /// مسح بيانات المصادقة
  Future<void> clearAuthData() async {
    await delete(key: 'auth_token');
    await delete(key: 'refresh_token');
    await delete(key: 'user_id');
    await delete(key: 'user_email');
    await delete(key: 'user_name');
    await delete(key: 'is_logged_in');
  }
}
