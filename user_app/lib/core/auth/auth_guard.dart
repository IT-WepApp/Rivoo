import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/core/state/auth_state_provider.dart';
import 'package:shared_libs/models/user_model.dart';

/// حارس المصادقة للتحقق من صلاحيات الوصول للمسارات
class AuthGuard {
  /// التحقق من حالة تسجيل الدخول
  static Future<String?> guardAuth(
    BuildContext context,
    GoRouterState state,
    WidgetRef ref,
  ) async {
    final isAuthenticated = ref.read(isAuthenticatedProvider);

    if (isAuthenticated) {
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
    final isAuthenticated = ref.read(isAuthenticatedProvider);

    if (!isAuthenticated) {
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
    List<String> allowedRoles,
  ) async {
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    final userRole = ref.read(userRoleProvider);

    if (!isAuthenticated) {
      // غير مصدق، إعادة توجيه لتسجيل الدخول
      return '/auth/login';
    }
    if (userRole != null && allowedRoles.contains(userRole)) {
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
    return guardRole(context, state, ref, [UserRoles.admin]);
  }

  /// التحقق من صلاحيات العميل
  static Future<String?> guardCustomer(
    BuildContext context,
    GoRouterState state,
    WidgetRef ref,
  ) async {
    return guardRole(context, state, ref, [UserRoles.customer]);
  }

  /// التحقق من صلاحيات السائق
  static Future<String?> guardDriver(
    BuildContext context,
    GoRouterState state,
    WidgetRef ref,
  ) async {
    return guardRole(context, state, ref, [UserRoles.driver]);
  }

  /// التحقق من صلاحيات المسؤول أو العميل
  static Future<String?> guardAdminOrCustomer(
    BuildContext context,
    GoRouterState state,
    WidgetRef ref,
  ) async {
    return guardRole(context, state, ref, [UserRoles.admin, UserRoles.customer]);
  }

  /// التحقق من صلاحيات المسؤول أو السائق
  static Future<String?> guardAdminOrDriver(
    BuildContext context,
    GoRouterState state,
    WidgetRef ref,
  ) async {
    return guardRole(context, state, ref, [UserRoles.admin, UserRoles.driver]);
  }
}
