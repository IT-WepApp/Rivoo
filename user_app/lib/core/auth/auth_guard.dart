import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/features/auth/presentation/viewmodels/auth_view_model.dart';

/// حارس المصادقة
/// يستخدم للتحقق من حالة المصادقة قبل الوصول إلى الصفحات المحمية
class AuthGuard {
  final WidgetRef ref;
  
  AuthGuard(this.ref);
  
  /// التحقق من حالة المصادقة
  bool isAuthenticated() {
    final authState = ref.read(authViewModelProvider);
    return authState.isAuthenticated;
  }
  
  /// التحقق من دور المستخدم
  bool hasRole(String role) {
    final authState = ref.read(authViewModelProvider);
    if (!authState.isAuthenticated || authState.userData == null) {
      return false;
    }
    
    return authState.userData!.role == role;
  }
  
  /// التحقق من وجود أي من الأدوار المحددة
  bool hasAnyRole(List<String> roles) {
    final authState = ref.read(authViewModelProvider);
    if (!authState.isAuthenticated || authState.userData == null) {
      return false;
    }
    
    return roles.contains(authState.userData!.role);
  }
}

/// مغلف حارس المصادقة
/// يستخدم لتغليف الصفحات المحمية بحارس المصادقة
class AuthGuardWrapper extends ConsumerWidget {
  final Widget child;
  final String? requiredRole;
  final List<String>? requiredRoles;
  final String redirectRoute;
  
  const AuthGuardWrapper({
    Key? key,
    required this.child,
    this.requiredRole,
    this.requiredRoles,
    this.redirectRoute = '/login',
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authGuard = AuthGuard(ref);
    
    // التحقق من حالة المصادقة
    if (!authGuard.isAuthenticated()) {
      // إعادة التوجيه إلى صفحة تسجيل الدخول
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(redirectRoute);
      });
      
      // عرض شاشة تحميل مؤقتة
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // التحقق من الدور المطلوب
    if (requiredRole != null && !authGuard.hasRole(requiredRole!)) {
      // إعادة التوجيه إلى صفحة غير مصرح بها
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/unauthorized');
      });
      
      // عرض شاشة تحميل مؤقتة
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // التحقق من الأدوار المطلوبة
    if (requiredRoles != null && !authGuard.hasAnyRole(requiredRoles!)) {
      // إعادة التوجيه إلى صفحة غير مصرح بها
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/unauthorized');
      });
      
      // عرض شاشة تحميل مؤقتة
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // عرض الصفحة المحمية
    return child;
  }
}

/// مغلف حارس المصادقة للمسارات
/// يستخدم لتغليف المسارات المحمية بحارس المصادقة
class AuthGuardRoute<T> extends MaterialPageRoute<T> {
  final String? requiredRole;
  final List<String>? requiredRoles;
  final String redirectRoute;
  
  AuthGuardRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    this.requiredRole,
    this.requiredRoles,
    this.redirectRoute = '/login',
  }) : super(
    builder: (context) => Consumer(
      builder: (context, ref, _) => AuthGuardWrapper(
        requiredRole: requiredRole,
        requiredRoles: requiredRoles,
        redirectRoute: redirectRoute,
        child: builder(context),
      ),
    ),
    settings: settings,
  );
}
