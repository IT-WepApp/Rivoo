import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import '../entities/user_entity.dart'; // تأكد أن المسار صحيح حسب هيكل مشروعك

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity with EquatableMixin {
  const UserModel({
    required String id,
    required String name,
    required String email,
    required String role,
    String? storeId,
  }) : super(id: id, name: name, email: email, role: role, storeId: storeId);

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? storeId,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      storeId: storeId ?? this.storeId,
    );
  }

  @override
  List<Object?> get props => [id, name, email, role, storeId];
}
