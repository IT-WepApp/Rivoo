# كيان المستخدم الموحد في طبقة Domain

import 'package:equatable/equatable.dart';
import '../enums/user_role.dart'; // استيراد UserRole من الموقع الجديد

/// كيان المستخدم الموحد في طبقة Domain
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final UserRole role; // تم تغيير النوع إلى UserRole
  final String? phone;
  final String? address;
  final String? avatarUrl; // تم توحيد اسم حقل الصورة
  final String? storeId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;
  final bool isPhoneVerified;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    this.avatarUrl,
    this.storeId,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
  });

  /// إنشاء نسخة جديدة من الكيان مع تحديث بعض الحقول
  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? phone,
    String? address,
    String? avatarUrl,
    String? storeId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    bool? isPhoneVerified,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      storeId: storeId ?? this.storeId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
        role,
        phone,
        address,
        avatarUrl,
        storeId,
        createdAt,
        updatedAt,
        lastLoginAt,
        isEmailVerified,
        isPhoneVerified,
      ];
}

