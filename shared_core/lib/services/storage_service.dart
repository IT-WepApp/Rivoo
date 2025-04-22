import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة التخزين المسؤولة عن تخزين واسترجاع البيانات محلياً
/// تستخدم SharedPreferences للبيانات العادية وFlutterSecureStorage للبيانات الحساسة
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// تهيئة خدمة التخزين
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // *** التخزين العادي (SharedPreferences) ***

  /// تخزين قيمة نصية
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  /// استرجاع قيمة نصية
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// تخزين قيمة منطقية
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  /// استرجاع قيمة منطقية
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// تخزين قيمة عددية صحيحة
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  /// استرجاع قيمة عددية صحيحة
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  /// تخزين قيمة عددية عشرية
  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  /// استرجاع قيمة عددية عشرية
  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  /// تخزين قائمة نصية
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  /// استرجاع قائمة نصية
  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  /// تخزين كائن JSON
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    return await _prefs.setString(key, jsonEncode(value));
  }

  /// استرجاع كائن JSON
  Map<String, dynamic>? getJson(String key) {
    final String? jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// حذف قيمة
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  /// مسح جميع البيانات
  Future<bool> clear() async {
    return await _prefs.clear();
  }

  // *** التخزين الآمن (FlutterSecureStorage) ***

  /// تخزين قيمة آمنة
  Future<void> setSecure(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  /// استرجاع قيمة آمنة
  Future<String?> getSecure(String key) async {
    return await _secureStorage.read(key: key);
  }

  /// حذف قيمة آمنة
  Future<void> removeSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  /// مسح جميع البيانات الآمنة
  Future<void> clearSecure() async {
    await _secureStorage.deleteAll();
  }
}
