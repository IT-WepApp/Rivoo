import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// حارس المسارات للتحقق من صلاحيات المستخدم
/// يستخدم للتحقق من حالة المصادقة قبل الوصول إلى الصفحات المحمية
class AuthGuard {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// التحقق من حالة المصادقة
  /// يستخدم للتحقق من أن المستخدم مسجل الدخول قبل الوصول إلى الصفحات المحمية
  Future<bool> isAuthenticated() async {
    final user = _auth.currentUser;
    return user != null;
  }

  /// التحقق من دور المستخدم
  /// يستخدم للتحقق من أن المستخدم لديه الصلاحيات المطلوبة للوصول إلى الصفحات المحمية
  Future<bool> hasRole(String requiredRole) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      // الحصول على رمز المصادقة الذي يحتوي على claims
      final idTokenResult = await user.getIdTokenResult();

      // التحقق من وجود claim الدور
      final role = idTokenResult.claims?['role'];

      // التحقق من أن الدور مطابق للدور المطلوب
      return role == requiredRole;
    } catch (e) {
      return false;
    }
  }

  /// حارس التوجيه للتحقق من حالة المصادقة
  /// يستخدم مع GoRouter للتحقق من حالة المصادقة قبل الوصول إلى الصفحات المحمية
  Future<String?> guardRoute(BuildContext context, GoRouterState state) async {
    final isLoggedIn = await isAuthenticated();

    if (!isLoggedIn) {
      // إذا لم يكن المستخدم مسجل الدخول، يتم توجيهه إلى صفحة تسجيل الدخول
      return '/login';
    }

    // إذا كان المستخدم مسجل الدخول، يتم السماح له بالوصول إلى الصفحة المطلوبة
    return null;
  }

  /// حارس التوجيه للتحقق من دور المستخدم
  /// يستخدم مع GoRouter للتحقق من دور المستخدم قبل الوصول إلى الصفحات المحمية
  Future<String?> guardRoleRoute(
      BuildContext context, GoRouterState state, String requiredRole) async {
    final isLoggedIn = await isAuthenticated();

    if (!isLoggedIn) {
      // إذا لم يكن المستخدم مسجل الدخول، يتم توجيهه إلى صفحة تسجيل الدخول
      return '/login';
    }

    final hasRequiredRole = await hasRole(requiredRole);

    if (!hasRequiredRole) {
      // إذا لم يكن المستخدم لديه الدور المطلوب، يتم توجيهه إلى صفحة غير مصرح بها
      return '/unauthorized';
    }

    // إذا كان المستخدم مسجل الدخول ولديه الدور المطلوب، يتم السماح له بالوصول إلى الصفحة المطلوبة
    return null;
  }

  /// إنشاء حارس مسار للتحقق من حالة المصادقة
  /// يستخدم مع GoRouter لإنشاء دالة حارس للتحقق من حالة المصادقة
  GoRouterRedirect createAuthGuard() {
    return (BuildContext context, GoRouterState state) async {
      return await guardRoute(context, state);
    };
  }

  /// إنشاء حارس مسار للتحقق من دور المستخدم
  /// يستخدم مع GoRouter لإنشاء دالة حارس للتحقق من دور المستخدم
  GoRouterRedirect createRoleGuard(String requiredRole) {
    return (BuildContext context, GoRouterState state) async {
      return await guardRoleRoute(context, state, requiredRole);
    };
  }
}
