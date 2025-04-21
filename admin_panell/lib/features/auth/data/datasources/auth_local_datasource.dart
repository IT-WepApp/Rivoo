import 'package:admin_panell/core/storage/secure_storage_service.dart';
import 'package:admin_panell/features/auth/domain/entities/user_entity.dart';

/// مصدر البيانات المحلي للمصادقة
class AuthLocalDataSource {
  final SecureStorageService _secureStorageService;

  AuthLocalDataSource(this._secureStorageService);

  /// حفظ رمز الوصول
  Future<void> saveAccessToken(String token) async {
    await _secureStorageService.write(key: 'access_token', value: token);
  }

  /// الحصول على رمز الوصول
  Future<String?> getAccessToken() async {
    return await _secureStorageService.read(key: 'access_token');
  }

  /// حذف رمز الوصول
  Future<void> deleteAccessToken() async {
    await _secureStorageService.delete(key: 'access_token');
  }

  /// حفظ بيانات المستخدم
  Future<void> saveUserData(UserEntity user) async {
    await _secureStorageService.write(key: 'user_id', value: user.id);
    await _secureStorageService.write(key: 'user_name', value: user.name);
    await _secureStorageService.write(key: 'user_email', value: user.email);
    await _secureStorageService.write(key: 'user_role', value: user.role.toString());
  }

  /// الحصول على بيانات المستخدم
  Future<UserEntity?> getUserData() async {
    final id = await _secureStorageService.read(key: 'user_id');
    final name = await _secureStorageService.read(key: 'user_name');
    final email = await _secureStorageService.read(key: 'user_email');
    final roleString = await _secureStorageService.read(key: 'user_role');

    if (id == null || name == null || email == null || roleString == null) {
      return null;
    }

    UserRole role;
    switch (roleString) {
      case 'UserRole.admin':
        role = UserRole.admin;
        break;
      case 'UserRole.seller':
        role = UserRole.seller;
        break;
      case 'UserRole.delivery':
        role = UserRole.delivery;
        break;
      default:
        role = UserRole.user;
    }

    return UserEntity(
      id: id,
      name: name,
      email: email,
      role: role,
    );
  }

  /// حذف بيانات المستخدم
  Future<void> deleteUserData() async {
    await _secureStorageService.delete(key: 'user_id');
    await _secureStorageService.delete(key: 'user_name');
    await _secureStorageService.delete(key: 'user_email');
    await _secureStorageService.delete(key: 'user_role');
  }

  /// التحقق من حالة تسجيل الدخول
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
