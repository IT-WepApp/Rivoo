import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/core/state/auth_state_provider.dart';
import 'package:user_app/features/auth/domain/user_model.dart';

/// حارس المصادقة للتحقق من صلاحيات الوصول للمسارات
class AuthGuard {
  /// التحقق من حالة تسجيل الدخول
  static Future<String?> guardAuth(
    BuildContext context,
    GoRouterState state,
    WidgetRef ref,
  ) async {
    final authState = ref.read(authStateProvider);
    
    if (authState.isAuthenticated) {
      // المستخدم مسجل الدخول، السماح بالوصول
      return null;
    }
    // المستخدم غير مسجل الدخول، إعادة التوجيه إلى صفحة تسجيل الدخول
    return '/auth/login';
  }

  /// التحقق من حالة عدم تسجيل الدخول
  static Future<String?> guardUnauth(
    BuildContext context,
    GoRouterState state,
    WidgetRef ref,
  ) async {
    final authState = ref.read(authStateProvider);
    
    if (!authState.isAuthenticated) {
      // المستخدم غير مسجل الدخول، السماح بالوصول
      return null;
    }
    // المستخدم مسجل الدخول، إعادة التوجيه إلى الصفحة الرئيسية
    return '/home';
  }

  /// التحقق من صلاحيات المستخدم
  static Future<String?> guardRole(
    BuildContext context,
    GoRouterState state,
    WidgetRef ref,
    List<UserRole> allowedRoles,
  ) async {
    final authState = ref.read(authStateProvider);
    
    if (!authState.isAuthenticated) {
      // غير مصدق، إعادة توجيه لتسجيل الدخول
      return '/auth/login';
    }
    if (authState.user != null && allowedRoles.contains(authState.user!.role)) {
      // لديه الصلاحيات المطلوبة
      return null;
    }
    // لا يملك الصلاحيات المطلوبة
    return '/unauthorized';
  }

  /// التحقق من صلاحيات المسؤول
  static Future<String?> guardAdmin(
    BuildContext context,
    GoRouterState state,
    WidgetRef ref,
  ) async {
    return guardRole(context, state, ref, [UserRole.admin]);
  }

  /// التحقق من صلاحيات العميل
  static Future<String?> guardCustomer(
    BuildContext context,
    GoRouterState state,
    WidgetRef ref,
  ) async {
    return guardRole(context, state, ref, [UserRole.customer]);
  }

  /// التحقق من صلاحيات السائق
  static Future<String?> guardDriver(
    BuildContext context,
    GoRouterState state,
    WidgetRef ref,
  ) async {
    return guardRole(context, state, ref, [UserRole.driver]);
  }

  /// التحقق من صلاحيات المسؤول أو العميل
  static Future<String?> guardAdminOrCustomer(
    BuildContext context,
    GoRouterState state,
    WidgetRef ref,
  ) async {
    return guardRole(context, state, ref, [UserRole.admin, UserRole.customer]);
  }

  /// التحقق من صلاحيات المسؤول أو السائق
  static Future<String?> guardAdminOrDriver(
    BuildContext context,
    GoRouterState state,
    WidgetRef ref,
  ) async {
    return guardRole(context, state, ref, [UserRole.admin, UserRole.driver]);
  }
}