// نموذج لتنفيذ هيكلية Clean Architecture في ميزة المصادقة

// ملف كيان المستخدم (Entity) في طبقة Domain
// lib/features/auth/domain/entities/user_entity.dart

import 'package:equatable/equatable.dart';

/// كيان المستخدم في طبقة Domain
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String? email;
  final String role;

  const UserEntity({
    required this.id,
    required this.name,
    this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [id, name, email, role];
}
