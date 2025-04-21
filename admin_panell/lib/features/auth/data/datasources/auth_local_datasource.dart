// مصدر البيانات المحلي للمصادقة في طبقة Data
// lib/features/auth/data/datasources/auth_local_datasource.dart

import 'dart:convert';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';
import '../../domain/entities/user_entity.dart';

/// واجهة مصدر البيانات المحلي للمصادقة
abstract class AuthLocalDataSource {
  /// تخزين بيانات المستخدم محلياً
  Future<void> cacheUser(UserEntity user);

  /// الحصول على آخر مستخدم قام بتسجيل الدخول
  Future<UserEntity?> getLastSignedInUser();

  /// حذف بيانات المستخدم المخزنة محلياً
  Future<void> clearUser();
}

/// تنفيذ مصدر البيانات المحلي للمصادقة
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService secureStorage;
  static const String USER_KEY = 'CACHED_USER';

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> cacheUser(UserEntity user) async {
    // تحويل كائن المستخدم إلى نموذج UserModel
    final userModel = user is UserModel 
        ? user 
        : UserModel(
            id: user.id,
            email: user.email,
            name: user.name,
            role: user.role,
          );
    
    // تخزين بيانات المستخدم كسلسلة JSON
    await secureStorage.write(
      key: USER_KEY,
      value: json.encode(userModel.toJson()),
    );
  }

  @override
  Future<UserEntity?> getLastSignedInUser() async {
    try {
      // قراءة بيانات المستخدم المخزنة
      final jsonString = await secureStorage.read(key: USER_KEY);
      
      if (jsonString == null) {
        return null;
      }
      
      // تحويل سلسلة JSON إلى كائن UserModel
      return UserModel.fromJson(json.decode(jsonString));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    await secureStorage.delete(key: USER_KEY);
  }
}
