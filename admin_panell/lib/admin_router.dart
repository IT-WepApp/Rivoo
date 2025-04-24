import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

// استيراد مزود المصادقة
import 'core/auth/auth_provider.dart';

// استيراد صفحات التطبيق
import 'features/auth/presentation/pages/login_page.dart';
import 'features/dashboard/presentation/pages/admin_home_page.dart';
import 'features/category_management/presentation/pages/category_management_page.dart';
import 'features/product_management/presentation/pages/product_list_page.dart';
import 'features/order_management/presentation/pages/order_list_page.dart';
import 'features/user_management/presentation/pages/user_list_page.dart';
import 'features/store_management/presentation/pages/store_list_page.dart';
import 'features/statistics_and_reports/presentation/pages/statistics_and_reports_page.dart';

/// ثوابت المسارات
class AdminRoutes {
  static const String login = '/';
  static const String adminHome = '/adminHome';
  static const String categoryManagement = '/categoryManagement';
  static const String productManagement = '/productManagement';
  static const String orderManagement = '/orderManagement';
  static const String userManagement = '/userManagement';
  static const String storeManagement = '/storeManagement';
  static const String statistics = '/statistics';
}

/// مزود موجه التطبيق
final adminRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    // استخدام refreshListenable لإعادة تقييم التوجيه عند تغير حالة المصادقة
    refreshListenable: GoRouterRefreshStream(ref.read(authProvider.notifier).stream),
    
    // آلية التوجيه (redirect)
    redirect: (context, state) {
      // الحصول على حالة المصادقة الحالية
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isLoggingIn = state.matchedLocation == AdminRoutes.login;
      
      // إذا لم يكن المستخدم مسجل الدخول ولم يكن في صفحة تسجيل الدخول
      if (!isLoggedIn && !isLoggingIn) {
        return AdminRoutes.login;
      }
      
      // إذا كان المستخدم مسجل الدخول وكان في صفحة تسجيل الدخول
      if (isLoggedIn && isLoggingIn) {
        return AdminRoutes.adminHome;
      }
      
      // السماح بالتنقل
      return null;
    },
    
    // المسار الأولي
    initialLocation: AdminRoutes.login,
    
    // تعريف المسارات
    routes: [
      // صفحة تسجيل الدخول
      GoRoute(
        path: AdminRoutes.login,
        builder: (context, state) => const AdminLoginPage(),
      ),
      
      // الصفحة الرئيسية للمسؤول
      GoRoute(
        path: AdminRoutes.adminHome,
        builder: (context, state) => const AdminHomePage(),
      ),
      
      // صفحة إدارة الفئات
      GoRoute(
        path: AdminRoutes.categoryManagement,
        builder: (context, state) => const CategoryManagementPage(),
      ),
      
      // صفحة إدارة المنتجات
      GoRoute(
        path: AdminRoutes.productManagement,
        builder: (context, state) => const ProductListPage(),
      ),
      
      // صفحة إدارة الطلبات
      GoRoute(
        path: AdminRoutes.orderManagement,
        builder: (context, state) => const OrderListPage(),
      ),
      
      // صفحة إدارة المستخدمين
      GoRoute(
        path: AdminRoutes.userManagement,
        builder: (context, state) => const UserListPage(),
      ),
      
      // صفحة إدارة المتاجر
      GoRoute(
        path: AdminRoutes.storeManagement,
        builder: (context, state) => const StoreListPage(),
      ),
      
      // صفحة الإحصائيات والتقارير
      GoRoute(
        path: AdminRoutes.statistics,
        builder: (context, state) => const StatisticsAndReportsPage(),
      ),
    ],
    
    // معالجة الأخطاء
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('خطأ')),
      body: Center(child: Text('الصفحة غير موجودة: ${state.error}')),
    ),
  );
});

/// فئة مساعدة لتحويل StateNotifier إلى Listenable لاستخدامه مع GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
