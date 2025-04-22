import 'package:user_app/features/auth/domain/entities/user.dart';
import 'package:user_app/features/auth/domain/entities/user_role.dart';

/// مصدر بيانات المصادقة المحلي
class AuthLocalDatasource {
  /// استرجاع بيانات المستخدم المخزنة محليًا
  Future<User?> getStoredUser() async {
    // تنفيذ استرجاع بيانات المستخدم من التخزين المحلي
    return null;
  }

  /// تخزين بيانات المستخدم محليًا
  Future<void> storeUser(User user) async {
    // تنفيذ تخزين بيانات المستخدم في التخزين المحلي
  }

  /// حذف بيانات المستخدم المخزنة محليًا
  Future<void> clearStoredUser() async {
    // تنفيذ حذف بيانات المستخدم من التخزين المحلي
  }

  /// التحقق مما إذا كان المستخدم مسجل الدخول محليًا
  Future<bool> isLoggedIn() async {
    // تنفيذ التحقق من حالة تسجيل الدخول
    return false;
  }
  
  /// حفظ بيانات المستخدم
  Future<void> saveUserData(User user) async {
    // تنفيذ حفظ بيانات المستخدم
    await storeUser(user);
  }
  
  /// حذف بيانات المستخدم
  Future<void> deleteUserData() async {
    // تنفيذ حذف بيانات المستخدم
    await clearStoredUser();
  }
  
  /// الحصول على رمز المصادقة
  Future<String?> getAuthToken() async {
    // تنفيذ الحصول على رمز المصادقة
    return null;
  }
  
  /// حذف رمز المصادقة
  Future<void> deleteAuthToken() async {
    // تنفيذ حذف رمز المصادقة
  }
}
