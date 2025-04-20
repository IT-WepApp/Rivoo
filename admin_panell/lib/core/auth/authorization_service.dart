import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../storage/secure_storage_service.dart';

/// تعريف الأدوار المتاحة في النظام
enum UserRole {
  user,    // مستخدم عادي
  editor,  // محرر
  admin,   // مشرف
  superAdmin // مدير النظام
}

/// تحويل UserRole إلى سلسلة نصية
String userRoleToString(UserRole role) {
  switch (role) {
    case UserRole.user:
      return 'user';
    case UserRole.editor:
      return 'editor';
    case UserRole.admin:
      return 'admin';
    case UserRole.superAdmin:
      return 'superAdmin';
    default:
      return 'user';
  }
}

/// تحويل سلسلة نصية إلى UserRole
UserRole stringToUserRole(String? roleStr) {
  switch (roleStr) {
    case 'user':
      return UserRole.user;
    case 'editor':
      return UserRole.editor;
    case 'admin':
      return UserRole.admin;
    case 'superAdmin':
      return UserRole.superAdmin;
    default:
      return UserRole.user;
  }
}

/// خدمة إدارة الصلاحيات
class AuthorizationService {
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;
  final SecureStorageService _secureStorage;

  AuthorizationService({
    FirebaseAuth? auth,
    FirebaseFunctions? functions,
    required SecureStorageService secureStorage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _functions = functions ?? FirebaseFunctions.instance,
        _secureStorage = secureStorage;

  /// الحصول على دور المستخدم الحالي
  Future<UserRole> getCurrentUserRole() async {
    // محاولة الحصول على الدور من التخزين المحلي أولاً للأداء
    final cachedRole = await _secureStorage.getUserRole();
    if (cachedRole != null) {
      return stringToUserRole(cachedRole);
    }

    // إذا لم يكن هناك دور مخزن، نحاول الحصول عليه من Firebase
    final user = _auth.currentUser;
    if (user == null) {
      return UserRole.user; // المستخدم غير مسجل الدخول
    }

    try {
      // تحديث معلومات المستخدم للحصول على أحدث البيانات
      await user.reload();
      final idTokenResult = await user.getIdTokenResult(true);
      final claims = idTokenResult.claims;
      final roleStr = claims?['role'] as String?;
      if (roleStr != null) {
        // تخزين الدور في التخزين المحلي للاستخدام المستقبلي
        await _secureStorage.saveUserRole(roleStr);
        return stringToUserRole(roleStr);
      }
    } catch (e) {
      // في حالة حدوث خطأ، نعيد الدور الافتراضي
      print('Error getting user role: $e');
    }

    return UserRole.user;
  }

  /// التحقق مما إذا كان المستخدم الحالي لديه دور معين
  Future<bool> hasRole(UserRole requiredRole) async {
    final currentRole = await getCurrentUserRole();
    
    // التحقق من الدور بناءً على التسلسل الهرمي
    switch (requiredRole) {
      case UserRole.user:
        // أي مستخدم مسجل الدخول لديه على الأقل دور مستخدم
        return true;
      case UserRole.editor:
        return currentRole == UserRole.editor || 
               currentRole == UserRole.admin || 
               currentRole == UserRole.superAdmin;
      case UserRole.admin:
        return currentRole == UserRole.admin || 
               currentRole == UserRole.superAdmin;
      case UserRole.superAdmin:
        return currentRole == UserRole.superAdmin;
      default:
        return false;
    }
  }

  /// التحقق مما إذا كان المستخدم الحالي لديه إذن للوصول إلى ميزة معينة
  Future<bool> canAccess(String featureId) async {
    // يمكن تنفيذ منطق أكثر تعقيدًا هنا للتحقق من الوصول إلى ميزات محددة
    // بناءً على مزيج من الأدوار والأذونات المخصصة
    
    switch (featureId) {
      case 'user_management':
        return await hasRole(UserRole.admin);
      case 'content_editing':
        return await hasRole(UserRole.editor);
      case 'system_settings':
        return await hasRole(UserRole.superAdmin);
      case 'view_reports':
        return await hasRole(UserRole.editor);
      default:
        return await hasRole(UserRole.user);
    }
  }

  /// تعيين دور للمستخدم (يتطلب وظيفة Cloud Function)
  Future<void> setUserRole(String userId, UserRole role) async {
    try {
      // هذه الوظيفة تحتاج إلى تنفيذها في Cloud Functions لأسباب أمنية
      await _functions.httpsCallable('setUserRole').call({
        'userId': userId,
        'role': userRoleToString(role),
      });
      
      // إذا كان المستخدم المستهدف هو المستخدم الحالي، نحدث التخزين المحلي
      if (_auth.currentUser?.uid == userId) {
        await _secureStorage.saveUserRole(userRoleToString(role));
      }
    } catch (e) {
      print('Error setting user role: $e');
      rethrow;
    }
  }
}

// مزود للوصول إلى خدمة إدارة الصلاحيات من أي مكان في التطبيق
final authorizationServiceProvider = AuthorizationService(
  secureStorage: secureStorageServiceProvider,
);
