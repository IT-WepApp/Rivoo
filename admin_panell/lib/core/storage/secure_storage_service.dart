import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// واجهة مجردة لخدمة التخزين الآمن
abstract class SecureStorageService {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();
  Future<bool> containsKey(String key);
  Future<Map<String, String>> readAll();
}

/// تنفيذ خدمة التخزين الآمن باستخدام flutter_secure_storage
class SecureStorageServiceImpl implements SecureStorageService {
  final FlutterSecureStorage _storage;

  // الثوابت المستخدمة لتخزين البيانات الحساسة
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  static const String userNameKey = 'user_name';

  SecureStorageServiceImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
        );

  @override
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  @override
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  @override
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  @override
  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }

  // طرق مساعدة للتعامل مع بيانات المصادقة

  Future<void> saveAccessToken(String token) async {
    await write(accessTokenKey, token);
  }

  Future<String?> getAccessToken() async {
    return await read(accessTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await write(refreshTokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    return await read(refreshTokenKey);
  }

  Future<void> saveUserId(String userId) async {
    await write(userIdKey, userId);
  }

  Future<String?> getUserId() async {
    return await read(userIdKey);
  }

  Future<void> saveUserRole(String role) async {
    await write(userRoleKey, role);
  }

  Future<String?> getUserRole() async {
    return await read(userRoleKey);
  }

  Future<void> saveUserName(String name) async {
    await write(userNameKey, name);
  }

  Future<String?> getUserName() async {
    return await read(userNameKey);
  }

  Future<void> clearAuthData() async {
    await delete(accessTokenKey);
    await delete(refreshTokenKey);
    await delete(userIdKey);
    await delete(userRoleKey);
    await delete(userNameKey);
  }
}

// مزود للوصول إلى خدمة التخزين الآمن من أي مكان في التطبيق
final secureStorageServiceProvider = SecureStorageServiceImpl();
