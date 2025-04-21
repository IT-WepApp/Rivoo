import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// خدمة التخزين الآمن
/// توفر واجهة للتخزين الآمن للبيانات الحساسة مثل التوكنات ومعلومات المصادقة
class SecureStorageServiceImpl {
  final FlutterSecureStorage _storage;

  /// إنشاء نسخة جديدة من خدمة التخزين الآمن
  SecureStorageServiceImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// تخزين قيمة بشكل آمن
  ///
  /// [key] مفتاح التخزين
  /// [value] القيمة المراد تخزينها
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  /// قراءة قيمة مخزنة
  ///
  /// [key] مفتاح التخزين
  /// يعيد القيمة المخزنة أو null إذا لم تكن موجودة
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  /// حذف قيمة مخزنة
  ///
  /// [key] مفتاح التخزين المراد حذفه
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  /// حذف جميع القيم المخزنة
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  /// التحقق من وجود قيمة مخزنة
  ///
  /// [key] مفتاح التخزين
  /// يعيد true إذا كانت القيمة موجودة، وfalse إذا لم تكن موجودة
  Future<bool> containsKey({required String key}) async {
    return await _storage.containsKey(key: key);
  }
}
