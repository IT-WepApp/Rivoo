import 'package:cloud_functions/cloud_functions.dart';

/// خدمة التفويض
/// توفر واجهة للتحقق من صلاحيات المستخدم وإدارة الأدوار
class AuthorizationService {
  final FirebaseFunctions _functions;

  /// إنشاء نسخة جديدة من خدمة التفويض
  AuthorizationService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  /// التحقق من صلاحيات المستخدم
  ///
  /// [userId] معرف المستخدم
  /// [permission] الصلاحية المطلوب التحقق منها
  /// يعيد true إذا كان المستخدم يملك الصلاحية، وfalse إذا لم يكن يملكها
  Future<bool> hasPermission(String userId, String permission) async {
    try {
      final callable = _functions.httpsCallable('checkPermission');
      final result = await callable.call<Map<String, dynamic>>({
        'userId': userId,
        'permission': permission,
      });

      return result.data['hasPermission'] as bool;
    } catch (e) {
      // في حالة حدوث خطأ، نفترض أن المستخدم لا يملك الصلاحية
      return false;
    }
  }

  /// الحصول على أدوار المستخدم
  ///
  /// [userId] معرف المستخدم
  /// يعيد قائمة بأدوار المستخدم
  Future<List<String>> getUserRoles(String userId) async {
    try {
      final callable = _functions.httpsCallable('getUserRoles');
      final result = await callable.call<Map<String, dynamic>>({
        'userId': userId,
      });

      final roles = result.data['roles'] as List<dynamic>;
      return roles.map((role) => role.toString()).toList();
    } catch (e) {
      // في حالة حدوث خطأ، نعيد قائمة فارغة
      return [];
    }
  }

  /// إضافة دور للمستخدم
  ///
  /// [userId] معرف المستخدم
  /// [role] الدور المراد إضافته
  /// يعيد true إذا تمت الإضافة بنجاح، وfalse إذا فشلت العملية
  Future<bool> addRoleToUser(String userId, String role) async {
    try {
      final callable = _functions.httpsCallable('addRoleToUser');
      final result = await callable.call<Map<String, dynamic>>({
        'userId': userId,
        'role': role,
      });

      return result.data['success'] as bool;
    } catch (e) {
      return false;
    }
  }

  /// إزالة دور من المستخدم
  ///
  /// [userId] معرف المستخدم
  /// [role] الدور المراد إزالته
  /// يعيد true إذا تمت الإزالة بنجاح، وfalse إذا فشلت العملية
  Future<bool> removeRoleFromUser(String userId, String role) async {
    try {
      final callable = _functions.httpsCallable('removeRoleFromUser');
      final result = await callable.call<Map<String, dynamic>>({
        'userId': userId,
        'role': role,
      });

      return result.data['success'] as bool;
    } catch (e) {
      return false;
    }
  }
}
