import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// خدمة التخزين الآمن للبيانات الحساسة
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // تخزين رمز المصادقة
  Future<void> storeAuthToken(String token) async {
    await _secureStorage.write(key: AppConstants.tokenKey, value: token);
  }

  // استرجاع رمز المصادقة
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: AppConstants.tokenKey);
  }

  // تخزين معرف المستخدم
  Future<void> storeUserId(String userId) async {
    await _secureStorage.write(key: AppConstants.userIdKey, value: userId);
  }

  // استرجاع معرف المستخدم
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: AppConstants.userIdKey);
  }

  // تخزين رمز التحديث
  Future<void> storeRefreshToken(String refreshToken) async {
    await _secureStorage.write(key: AppConstants.refreshTokenKey, value: refreshToken);
  }

  // استرجاع رمز التحديث
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.refreshTokenKey);
  }

  // حذف جميع بيانات المصادقة
  Future<void> clearAuthData() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
    await _secureStorage.delete(key: AppConstants.userIdKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
  }

  // تخزين بيانات مشفرة عامة
  Future<void> storeSecureData(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  // استرجاع بيانات مشفرة عامة
  Future<String?> getSecureData(String key) async {
    return await _secureStorage.read(key: key);
  }

  // حذف بيانات مشفرة عامة
  Future<void> deleteSecureData(String key) async {
    await _secureStorage.delete(key: key);
  }

  // التحقق من وجود بيانات مشفرة
  Future<bool> hasSecureData(String key) async {
    final value = await _secureStorage.read(key: key);
    return value != null;
  }

  // حذف جميع البيانات المشفرة
  Future<void> clearAllSecureData() async {
    await _secureStorage.deleteAll();
  }

  // تخزين إعدادات المستخدم (غير حساسة) باستخدام SharedPreferences
  Future<void> storeUserPreference(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // استرجاع إعدادات المستخدم (غير حساسة)
  Future<String?> getUserPreference(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // حذف إعدادات المستخدم (غير حساسة)
  Future<void> deleteUserPreference(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // حذف جميع إعدادات المستخدم (غير حساسة)
  Future<void> clearAllUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
