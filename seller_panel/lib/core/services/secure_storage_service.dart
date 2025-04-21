import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// واجهة لخدمة التخزين الآمن
/// تتبع مبادئ Clean Architecture بفصل الواجهة عن التنفيذ
abstract class SecureStorageService {
  /// حفظ قيمة بشكل آمن
  Future<void> write({required String key, required String value});

  /// قراءة قيمة مخزنة بشكل آمن
  Future<String?> read({required String key});

  /// حذف قيمة مخزنة
  Future<void> delete({required String key});

  /// حذف جميع القيم المخزنة
  Future<void> deleteAll();

  /// التحقق من وجود قيمة مخزنة
  Future<bool> containsKey({required String key});

  /// الحصول على جميع القيم المخزنة
  Future<Map<String, String>> readAll();
}

/// تنفيذ خدمة التخزين الآمن باستخدام flutter_secure_storage
class SecureStorageServiceImpl implements SecureStorageService {
  final FlutterSecureStorage _storage;

  /// مفاتيح التخزين المستخدمة في التطبيق
  static const String userTokenKey = 'user_token';
  static const String sellerIdKey = 'seller_id';
  static const String userEmailKey = 'user_email';
  static const String userNameKey = 'user_name';
  static const String userRoleKey = 'user_role';
  static const String lastLoginKey = 'last_login';

  /// إعدادات التشفير للتخزين الآمن
  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
    resetOnError: true,
  );

  static const IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
    synchronizable: true,
  );

  /// إنشاء نسخة من خدمة التخزين الآمن
  SecureStorageServiceImpl()
      : _storage = const FlutterSecureStorage(
          aOptions: _androidOptions,
          iOptions: _iosOptions,
        );

  @override
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  @override
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  @override
  Future<bool> containsKey({required String key}) async {
    return await _storage.containsKey(key: key);
  }

  @override
  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }

  /// حفظ توكن المستخدم
  Future<void> saveUserToken(String token) async {
    await write(key: userTokenKey, value: token);
  }

  /// قراءة توكن المستخدم
  Future<String?> getUserToken() async {
    return await read(key: userTokenKey);
  }

  /// حفظ معرف البائع
  Future<void> saveSellerId(String sellerId) async {
    await write(key: sellerIdKey, value: sellerId);
  }

  /// قراءة معرف البائع
  Future<String?> getSellerId() async {
    return await read(key: sellerIdKey);
  }

  /// حفظ بيانات المستخدم الأساسية
  Future<void> saveUserData({
    required String email,
    required String name,
    required String role,
  }) async {
    await write(key: userEmailKey, value: email);
    await write(key: userNameKey, value: name);
    await write(key: userRoleKey, value: role);
    await write(key: lastLoginKey, value: DateTime.now().toIso8601String());
  }

  /// التحقق من وجود جلسة مستخدم نشطة
  Future<bool> hasActiveSession() async {
    final token = await getUserToken();
    return token != null && token.isNotEmpty;
  }

  /// تسجيل خروج المستخدم (حذف جميع البيانات المخزنة)
  Future<void> logout() async {
    await deleteAll();
  }
}
