import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/// خدمة التخزين الآمن للبيانات الحساسة مثل الرموز المميزة وبيانات المستخدم.
class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  // --- Basic Operations ---

  /// كتابة قيمة مرتبطة بمفتاح.
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  /// قراءة قيمة مرتبطة بمفتاح.
  Future<String?> read(String key) => _storage.read(key: key);

  /// حذف قيمة مرتبطة بمفتاح.
  Future<void> delete(String key) => _storage.delete(key: key);

  /// قراءة جميع القيم.
  Future<Map<String, String>> readAll() => _storage.readAll();

  /// حذف جميع القيم.
  Future<void> deleteAll() => _storage.deleteAll();

  // --- Enhanced Auth-Related Operations ---

  static const _authTokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _tokenExpiryKey = 'token_expiry';
  static const _userDataKey = 'user_data';

  /// حفظ رمز المصادقة وتاريخ انتهاء صلاحيته.
  Future<void> saveAuthToken(String token, {int expiryMinutes = 60}) async {
    await write(_authTokenKey, token);
    final expiryDate = DateTime.now().add(Duration(minutes: expiryMinutes));
    await write(_tokenExpiryKey, expiryDate.toIso8601String());
  }

  /// قراءة رمز المصادقة.
  Future<String?> readAuthToken() => read(_authTokenKey);

  /// التحقق مما إذا كان رمز المصادقة صالحًا (لم تنته صلاحيته).
  Future<bool> isAuthTokenValid() async {
    final expiryString = await read(_tokenExpiryKey);
    if (expiryString == null) return false;
    final expiryDate = DateTime.tryParse(expiryString);
    return expiryDate != null && expiryDate.isAfter(DateTime.now());
  }

  /// حذف رمز المصادقة وتاريخ انتهاء صلاحيته.
  Future<void> deleteAuthToken() async {
    await delete(_authTokenKey);
    await delete(_tokenExpiryKey);
  }

  /// حفظ رمز التحديث.
  Future<void> saveRefreshToken(String token) => write(_refreshTokenKey, token);

  /// قراءة رمز التحديث.
  Future<String?> readRefreshToken() => read(_refreshTokenKey);

  /// حذف رمز التحديث.
  Future<void> deleteRefreshToken() => delete(_refreshTokenKey);

  /// حفظ بيانات المستخدم (كمرجع، قد تحتاج لتشفير إضافي حسب الحساسية).
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    // تحويل الخريطة إلى سلسلة JSON قبل الحفظ
    await write(_userDataKey, jsonEncode(userData));
  }

  /// قراءة بيانات المستخدم.
  Future<Map<String, dynamic>?> getUserData() async {
    final userDataString = await read(_userDataKey);
    if (userDataString != null) {
      try {
        // محاولة فك تشفير سلسلة JSON إلى خريطة
        return jsonDecode(userDataString) as Map<String, dynamic>;
      } catch (e) {
        // في حالة حدوث خطأ في فك التشفير، احذف البيانات غير الصالحة
        await deleteUserData();
        return null;
      }
    }
    return null;
  }

  /// حذف بيانات المستخدم.
  Future<void> deleteUserData() => delete(_userDataKey);

  /// مسح جميع بيانات المصادقة والتخزين الآمن.
  Future<void> clearAll() async {
    // يمكنك استخدام deleteAll() أو حذف المفاتيح المعروفة بشكل فردي
    await deleteAuthToken();
    await deleteRefreshToken();
    await deleteUserData();
    // أضف أي مفاتيح أخرى تحتاج إلى حذفها هنا
    // أو ببساطة:
    // await deleteAll(); // كن حذرًا، هذا سيحذف كل شيء في التخزين الآمن
  }
}

