import 'package:user_app/core/architecture/domain/entity.dart';

/// نموذج المستخدم
class User extends Entity {
  /// معرف المستخدم
  final String id;
  
  /// اسم المستخدم
  final String name;
  
  /// البريد الإلكتروني للمستخدم
  final String email;
  
  /// رقم هاتف المستخدم
  final String? phone;
  
  /// عنوان المستخدم
  final String? address;
  
  /// صورة المستخدم
  final String? profileImage;
  
  /// تاريخ إنشاء الحساب
  final DateTime createdAt;
  
  /// تاريخ آخر تحديث للحساب
  final DateTime updatedAt;

  /// إنشاء نموذج مستخدم جديد
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  /// إنشاء نسخة جديدة من المستخدم مع تحديث بعض الحقول
  User copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? profileImage,
    DateTime? updatedAt,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        address,
        profileImage,
        createdAt,
        updatedAt,
      ];
}
