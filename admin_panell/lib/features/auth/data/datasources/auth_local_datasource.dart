import 'package:shared_libs/services/secure_storage_service.dart';
import 'package:shared_libs/entities/user_entity.dart';
import 'package:admin_panell/features/auth/domain/entities/user_role.dart';

/// مصدر البيانات المحلي للمصادقة
class AuthLocalDataSource {
  final SecureStorageService _secureStorageService;

  AuthLocalDataSource(this._secureStorageService);

  /// حفظ رمز الوصول
  Future<void> saveAccessToken(String token) async {
    await _secureStorageService.write('access_token', token);
  }

  /// الحصول على رمز الوصول
  Future<String?> getAccessToken() async {
    return await _secureStorageService.read('access_token');
  }

  /// حذف رمز الوصول
  Future<void> deleteAccessToken() async {
    await _secureStorageService.delete('access_token');
  }

  /// حفظ بيانات المستخدم
  Future<void> saveUserData(UserEntity user) async {
    await _secureStorageService.write('user_id', user.id);
    await _secureStorageService.write('user_name', user.name);
    await _secureStorageService.write('user_email', user.email?? '');
    await _secureStorageService.write('user_role', user.role.toString());
  }

  /// الحصول على بيانات المستخدم
  Future<UserEntity?> getUserData() async {
    final id = await _secureStorageService.read('user_id');
    final name = await _secureStorageService.read('user_name');
    final email = await _secureStorageService.read('user_email');
    final roleString = await _secureStorageService.read('user_role');

    if (id == null || name == null || email == null || roleString == null) {
      return null;
    }

    UserRole role;
    switch (roleString) {
      case 'UserRole.admin':
        role = UserRole.admin;
        break;
      case 'UserRole.seller':
        role = UserRole.salesManager;
        break;
      case 'UserRole.delivery':
        role = UserRole.deliverManager;
        break;
      default:
        role = UserRole.user;
    }

    return UserEntity(
      id: id,
      name: name,
      email: email,
      role: role.name,
    );
  }

  /// حذف بيانات المستخدم
  Future<void> deleteUserData() async {
    await _secureStorageService.delete('user_id');
    await _secureStorageService.delete('user_name');
    await _secureStorageService.delete('user_email');
    await _secureStorageService.delete('user_role');
  }

  /// التحقق من حالة تسجيل الدخول
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
  
  /// الحصول على آخر مستخدم قام بتسجيل الدخول
  Future<UserEntity?> getLastSignedInUser() async {
    return await getUserData();
  }
  
  /// تخزين بيانات المستخدم في التخزين المحلي
  Future<void> cacheUser(UserEntity user) async {
    await saveUserData(user);
  }
  
  /// مسح بيانات المستخدم من التخزين المحلي
  Future<void> clearUser() async {
    await deleteUserData();
  }
}
