import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// واجهة خدمة التخزين الآمن
abstract class SecureStorageService {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();

  // طرق إضافية مطلوبة من قبل AuthService
  Future<void> storeUserId(String userId);
  Future<void> storeAuthToken(String token);
  Future<void> clearAuthData();
  Future<String?> getUserId();
  Future<String?> getAuthToken();
}

/// تنفيذ خدمة التخزين الآمن باستخدام flutter_secure_storage
class SecureStorageServiceImpl implements SecureStorageService {
  final FlutterSecureStorage _storage;

  // مفاتيح التخزين
  static const String _userIdKey = 'user_id';
  static const String _authTokenKey = 'auth_token';

  SecureStorageServiceImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

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
  Future<void> storeUserId(String userId) async {
    await write(_userIdKey, userId);
  }

  @override
  Future<void> storeAuthToken(String token) async {
    await write(_authTokenKey, token);
  }

  @override
  Future<void> clearAuthData() async {
    await delete(_userIdKey);
    await delete(_authTokenKey);
  }

  @override
  Future<String?> getUserId() async {
    return await read(_userIdKey);
  }

  @override
  Future<String?> getAuthToken() async {
    return await read(_authTokenKey);
  }
}
