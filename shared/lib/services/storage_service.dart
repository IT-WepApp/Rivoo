import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// مزود خدمة التخزين
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// خدمة التخزين المحلي للتطبيق
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

  /// حفظ قيمة نصية
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  /// الحصول على قيمة نصية
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// حفظ قيمة منطقية
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  /// الحصول على قيمة منطقية
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// حفظ قيمة عددية صحيحة
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  /// الحصول على قيمة عددية صحيحة
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  /// حفظ قيمة عددية عشرية
  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  /// الحصول على قيمة عددية عشرية
  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  /// حفظ قائمة نصية
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  /// الحصول على قائمة نصية
  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  /// حذف قيمة
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  /// مسح جميع القيم
  Future<bool> clear() async {
    return await _prefs.clear();
  }

  /// التحقق من وجود مفتاح
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  /// حفظ قيمة نصية بشكل آمن
  Future<void> setSecureString(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  /// الحصول على قيمة نصية مخزنة بشكل آمن
  Future<String?> getSecureString(String key) async {
    return await _secureStorage.read(key: key);
  }

  /// حذف قيمة مخزنة بشكل آمن
  Future<void> removeSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  /// مسح جميع القيم المخزنة بشكل آمن
  Future<void> clearSecure() async {
    await _secureStorage.deleteAll();
  }

  /// التحقق من وجود مفتاح في التخزين الآمن
  Future<bool> containsKeySecure(String key) async {
    final value = await _secureStorage.read(key: key);
    return value != null;
  }
}
