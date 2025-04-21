// واجهة مستودع المصادقة في طبقة Domain
// lib/features/auth/domain/repositories/auth_repository.dart

import '../entities/user_entity.dart';

/// واجهة مستودع المصادقة
abstract class AuthRepository {
  /// تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<UserEntity> signIn(String email, String password);

  /// تسجيل الخروج
  Future<void> signOut();

  /// التحقق من حالة المصادقة الحالية
  Future<UserEntity?> getCurrentUser();

  /// التحقق مما إذا كان المستخدم مسجل الدخول
  Future<bool> isSignedIn();
}
