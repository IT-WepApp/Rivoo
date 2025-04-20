// مصدر البيانات المحلي (Local Data Source) في طبقة Data
// lib/features/auth/data/datasources/auth_local_datasource.dart

import 'dart:convert';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';

/// واجهة مصدر البيانات المحلي للمصادقة
abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getLastSignedInUser();
  Future<void> clearUser();
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<bool> hasToken();
}

/// تنفيذ مصدر البيانات المحلي باستخدام SecureStorageService
class SecureStorageAuthDataSource implements AuthLocalDataSource {
  final SecureStorageService _secureStorage;
  
  static const String userKey = 'cached_user';
  static const String tokenKey = 'access_token';

  SecureStorageAuthDataSource(this._secureStorage);

  @override
  Future<void> cacheUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _secureStorage.write(userKey, userJson);
  }

  @override
  Future<UserModel?> getLastSignedInUser() async {
    final userJson = await _secureStorage.read(userKey);
    
    if (userJson == null) {
      return null;
    }
    
    try {
      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } catch (e) {
      print('Error parsing cached user: $e');
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    await _secureStorage.delete(userKey);
  }
  
  @override
  Future<void> saveToken(String token) async {
    await _secureStorage.write(tokenKey, token);
  }
  
  @override
  Future<String?> getToken() async {
    return await _secureStorage.read(tokenKey);
  }
  
  @override
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
