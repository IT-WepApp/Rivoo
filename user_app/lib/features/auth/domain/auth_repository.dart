import 'package:dartz/dartz.dart';
import 'package:user_app/core/architecture/domain/entity.dart';
import 'package:user_app/core/architecture/domain/failure.dart';

/// واجهة مستودع المصادقة
/// تحدد العمليات المتعلقة بالمصادقة وإدارة المستخدمين
abstract class AuthRepository {
  /// تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<Either<Failure, UserEntity>> signIn(String email, String password);
  
  /// إنشاء حساب جديد
  Future<Either<Failure, UserEntity>> signUp(String email, String password, String name);
  
  /// تسجيل الخروج
  Future<Either<Failure, void>> signOut();
  
  /// إرسال رابط إعادة تعيين كلمة المرور
  Future<Either<Failure, void>> resetPassword(String email);
  
  /// التحقق من حالة المصادقة
  Future<Either<Failure, bool>> isAuthenticated();
  
  /// الحصول على المستخدم الحالي
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  
  /// تحديث بيانات المستخدم
  Future<Either<Failure, UserEntity>> updateUserProfile(UserEntity user);
  
  /// تحديث كلمة المرور
  Future<Either<Failure, void>> updatePassword(String currentPassword, String newPassword);
  
  /// حذف الحساب
  Future<Either<Failure, void>> deleteAccount(String password);
}

/// كيان المستخدم
/// يمثل بيانات المستخدم في طبقة المجال
class UserEntity extends Entity {
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String role;
  final bool isEmailVerified;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  
  const UserEntity({
    required String id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.role,
    required this.isEmailVerified,
    this.createdAt,
    this.lastLoginAt,
  }) : super(id: id);
  
  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoUrl,
    role,
    isEmailVerified,
    createdAt,
    lastLoginAt,
  ];
  
  /// نسخ الكيان مع تحديث بعض الحقول
  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? role,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
