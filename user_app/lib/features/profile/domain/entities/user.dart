import 'package:user_app/core/architecture/domain/entity.dart';

/// كيان المستخدم
class User extends Entity {
  /// اسم المستخدم
  final String name;
  
  /// البريد الإلكتروني للمستخدم
  final String email;
  
  /// رقم الهاتف للمستخدم
  final String? phone;
  
  /// صورة المستخدم
  final String? avatarUrl;
  
  /// عنوان المستخدم
  final String? address;
  
  /// تاريخ إنشاء الحساب
  final DateTime createdAt;
  
  /// تاريخ آخر تسجيل دخول
  final DateTime? lastLoginAt;
  
  /// هل البريد الإلكتروني مؤكد
  final bool isEmailVerified;
  
  /// هل رقم الهاتف مؤكد
  final bool isPhoneVerified;

  /// إنشاء كيان المستخدم
  const User({
    required String id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.address,
    required this.createdAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
  }) : super(id: id);

  /// نسخة جديدة من الكيان مع تحديث بعض الحقول
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? address,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    bool? isPhoneVerified,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        avatarUrl,
        address,
        createdAt,
        lastLoginAt,
        isEmailVerified,
        isPhoneVerified,
      ];
}
