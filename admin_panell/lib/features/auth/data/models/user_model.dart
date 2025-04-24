// نموذج المستخدم في طبقة Data
// lib/features/auth/data/models/user_model.dart

import 'package:shared_libs/entities/user_entity.dart';

/// نموذج بيانات المستخدم
class UserModel extends UserEntity {
  const UserModel({
    required String id,
    required String email,
    required String name,
    required String role,
  }) : super(
          id: id,
          email: email,
          name: name,
          role: role,
        );

  /// إنشاء نموذج من JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
    );
  }

  /// تحويل النموذج إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
    };
  }
}
