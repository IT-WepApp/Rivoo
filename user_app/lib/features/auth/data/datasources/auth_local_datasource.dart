import 'package:user_app/features/auth/domain/entities/user.dart';

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
}
