import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

/// حالات المصادقة المختلفة في التطبيق
enum AuthStatus {
  /// المستخدم غير مصادق عليه (غير مسجل دخول)
  unauthenticated,
  
  /// المستخدم مصادق عليه (مسجل دخول) ولكن لم يتم التحقق من البريد الإلكتروني
  authenticatedUnverified,
  
  /// المستخدم مصادق عليه بالكامل (مسجل دخول وتم التحقق من البريد الإلكتروني)
  authenticated,
  
  /// جاري التحميل أو التحقق من حالة المصادقة
  loading,
}

/// مزود حالة المصادقة
final authStateProvider = StreamProvider<AuthStatus>((ref) {
  return fb_auth.FirebaseAuth.instance.authStateChanges().map((user) {
    if (user == null) {
      return AuthStatus.unauthenticated;
    } else if (!user.emailVerified) {
      return AuthStatus.authenticatedUnverified;
    } else {
      return AuthStatus.authenticated;
    }
  });
});

/// مزود للوصول المباشر إلى حالة المصادقة الحالية
final currentAuthStatusProvider = Provider<AuthStatus>((ref) {
  final authStateAsync = ref.watch(authStateProvider);
  
  return authStateAsync.when(
    data: (status) => status,
    loading: () => AuthStatus.loading,
    error: (_, __) => AuthStatus.unauthenticated,
  );
});
