import 'package:equatable/equatable.dart';
import 'user_entity.dart';

/// نموذج المستخدم الأساسي للتطبيق
class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final String role;
  final bool isEmailVerified;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    required this.role,
    this.isEmailVerified = false,
  });

  /// إنشاء نسخة جديدة من المستخدم مع تحديث بعض الحقول
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? role,
    bool? isEmailVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  /// تحويل المستخدم إلى Map لتخزينه في Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'role': role,
      'isEmailVerified': isEmailVerified,
    };
  }

  /// إنشاء مستخدم من Map مستلم من Firestore
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      photoUrl: map['photoUrl'],
      role: map['role'] ?? 'user',
      isEmailVerified: map['isEmailVerified'] ?? false,
    );
  }

  /// تحويل من UserEntity إلى User
  factory User.fromEntity(UserEntity entity) {
    return User(
      id: entity.id,
      email: entity.email ?? '',
      name: entity.name,
      role: entity.role,
      isEmailVerified: false,
    );
  }

  /// تحويل User إلى UserEntity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name ?? '',
      email: email,
      role: role,
    );
  }

  /// مستخدم فارغ للحالات الأولية
  factory User.empty() {
    return const User(
      id: '',
      email: '',
      name: null,
      photoUrl: null,
      role: 'user',
      isEmailVerified: false,
    );
  }

  @override
  List<Object?> get props => [id, email, name, photoUrl, role, isEmailVerified];
}
