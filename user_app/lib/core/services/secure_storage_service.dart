import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// خدمة التخزين الآمن للبيانات الحساسة
/// 
/// تستخدم هذه الخدمة حزمة flutter_secure_storage لتخزين البيانات الحساسة مثل
/// كلمات المرور والرموز المميزة بطريقة آمنة على الجهاز.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  /// إنشاء نسخة جديدة من خدمة التخزين الآمن
  /// 
  /// يمكن تخصيص إعدادات التخزين من خلال تمرير خيارات مخصصة
  SecureStorageService({
    AndroidOptions? androidOptions,
    IOSOptions? iosOptions,
  }) : _storage = FlutterSecureStorage(
          aOptions: androidOptions ?? const AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: iosOptions ?? const IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );

  /// تخزين قيمة في التخزين الآمن
  /// 
  /// [key] المفتاح المستخدم للوصول إلى القيمة لاحقاً
  /// [value] القيمة المراد تخزينها
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  /// قراءة قيمة من التخزين الآمن
  /// 
  /// [key] المفتاح المستخدم للوصول إلى القيمة
  /// يرجع القيمة المخزنة أو null إذا لم يتم العثور على المفتاح
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  /// حذف قيمة من التخزين الآمن
  /// 
  /// [key] المفتاح المراد حذفه
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  /// حذف جميع القيم من التخزين الآمن
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  /// التحقق من وجود مفتاح في التخزين الآمن
  /// 
  /// [key] المفتاح المراد التحقق منه
  /// يرجع true إذا كان المفتاح موجوداً، وfalse إذا لم يكن موجوداً
  Future<bool> containsKey({required String key}) async {
    return await _storage.containsKey(key: key);
  }

  /// الحصول على جميع المفاتيح والقيم المخزنة
  /// 
  /// يرجع خريطة تحتوي على جميع المفاتيح والقيم المخزنة
  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }
}
