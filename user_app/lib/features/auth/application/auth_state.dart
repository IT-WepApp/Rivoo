import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

/// حالة المصادقة المحتملة
enum AuthenticationStatus {
  initial,
  authenticated,
  unauthenticated,
  verifying,
  loading,
  error,
}

/// أدوار المستخدم
enum UserRole {
  customer,
  driver,
  admin,
  guest,
}

/// نموذج بيانات المستخدم
class UserData {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final UserRole role;
  final bool isEmailVerified;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  UserData({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    required this.role,
    required this.isEmailVerified,
    this.createdAt,
    this.lastLoginAt,
  });

  factory UserData.fromUser(User user, {UserRole role = UserRole.customer}) {
    return UserData(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
      role: role,
      isEmailVerified: user.emailVerified,
    );
  }

  UserData copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    UserRole? role,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserData(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

/// حالة المصادقة باستخدام Freezed
@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(AuthenticationStatus.initial) AuthenticationStatus status,
    UserData? userData,
    User? firebaseUser,
    String? errorMessage,
    @Default(false) bool isLoading,
  }) = _AuthState;

  const AuthState._();

  /// هل المستخدم مسجل الدخول
  bool get isAuthenticated =>
      status == AuthenticationStatus.authenticated && userData != null;

  /// هل البريد الإلكتروني مؤكد
  bool get isEmailVerified => userData?.isEmailVerified ?? false;

  /// هل المستخدم لديه دور محدد
  bool hasRole(UserRole role) => userData?.role == role;

  /// هل المستخدم لديه أي من الأدوار المحددة
  bool hasAnyRole(List<UserRole> roles) =>
      userData != null && roles.contains(userData!.role);
}
