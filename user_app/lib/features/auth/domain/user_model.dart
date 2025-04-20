import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// نموذج بيانات المستخدم باستخدام Freezed
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    required String email,
    required String role,
    String? phoneNumber,
    String? profileImageUrl,
    @Default([]) List<String> addresses,
    @Default(false) bool isEmailVerified,
    @Default({}) Map<String, dynamic> preferences,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) = _UserModel;

  /// إنشاء نموذج من JSON
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  /// إنشاء نموذج فارغ
  factory UserModel.empty() => const UserModel(
        id: '',
        name: '',
        email: '',
        role: 'customer',
      );
}

/// تعريف أدوار المستخدمين في النظام
class UserRoles {
  static const String customer = 'customer';
  static const String driver = 'driver';
  static const String admin = 'admin';
  static const String guest = 'guest';

  /// التحقق من صلاحية الدور
  static bool isValidRole(String role) {
    return [customer, driver, admin, guest].contains(role);
  }

  /// التحقق من صلاحيات المستخدم
  static bool hasPermission(String userRole, String requiredRole) {
    if (requiredRole == guest) return true;
    if (userRole == admin) return true;
    return userRole == requiredRole;
  }
}
