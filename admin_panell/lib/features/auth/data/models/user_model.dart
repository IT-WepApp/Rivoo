// نموذج بيانات المستخدم (Data Model) في طبقة Data
// lib/features/auth/data/models/user_model.dart

import '../../domain/entities/user_entity.dart';

/// نموذج بيانات المستخدم
class UserModel extends UserEntity {
  const UserModel({
    required String id,
    required String name,
    String? email,
    required String role,
  }) : super(
          id: id,
          name: name,
          email: email,
          role: role,
        );

  // تحويل من JSON إلى نموذج
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      role: json['role'] as String? ?? 'user',
    );
  }

  // تحويل من نموذج إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }

  // تحويل من AdminModel إلى UserModel
  factory UserModel.fromAdminModel(dynamic adminModel) {
    return UserModel(
      id: adminModel.id,
      name: adminModel.name,
      role: 'admin',
    );
  }
}
