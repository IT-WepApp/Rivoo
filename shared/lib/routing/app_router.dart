import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

/// ثوابت مسارات التطبيق
class AppRoutes {
  // منع إنشاء نسخ من الكلاس
  AppRoutes._();

  // مسارات المستخدم
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';
  static const String orderDetails = '/order-details';
  static const String productDetails = '/product-details';
  static const String categoryProducts = '/category-products';
  static const String search = '/search';

  // مسارات البائع
  static const String sellerDashboard = '/seller/dashboard';
  static const String sellerProducts = '/seller/products';
  static const String sellerAddProduct = '/seller/products/add';
  static const String sellerEditProduct = '/seller/products/edit';
  static const String sellerOrders = '/seller/orders';
  static const String sellerOrderDetails = '/seller/orders/details';
  static const String sellerProfile = '/seller/profile';
  static const String sellerSettings = '/seller/settings';

  // مسارات التوصيل
  static const String deliveryDashboard = '/delivery/dashboard';
  static const String deliveryOrders = '/delivery/orders';
  static const String deliveryOrderDetails = '/delivery/orders/details';
  static const String deliveryProfile = '/delivery/profile';
  static const String deliverySettings = '/delivery/settings';

  // مسارات الإدارة
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminSellers = '/admin/sellers';
  static const String adminDelivery = '/admin/delivery';
  static const String adminProducts = '/admin/products';
  static const String adminCategories = '/admin/categories';
  static const String adminOrders = '/admin/orders';
  static const String adminSettings = '/admin/settings';
}

/// مزود نظام التوجيه
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // التحقق من حالة المصادقة وإعادة التوجيه حسب الحاجة
      final isLoggedIn = authState.state == AuthState.authenticated;
      final isGoingToLogin = state.location == AppRoutes.login;
      final isGoingToRegister = state.location == AppRoutes.register;
      final isGoingToForgotPassword = state.location == AppRoutes.forgotPassword;
      final isGoingToSplash = state.location == AppRoutes.splash;
      
      // إذا كان المستخدم غير مسجل دخول ويحاول الوصول إلى صفحة محمية
      if (!isLoggedIn && 
          !isGoingToLogin && 
          !isGoingToRegister && 
          !isGoingToForgotPassword && 
          !isGoingToSplash) {
        return AppRoutes.login;
      }
      
      // إذا كان المستخدم مسجل دخول ويحاول الوصول إلى صفحة تسجيل الدخول
      if (isLoggedIn && (isGoingToLogin || isGoingToRegister || isGoingToForgotPassword || isGoingToSplash)) {
        // توجيه المستخدم إلى الصفحة المناسبة حسب دوره
        if (authState.user?.role == 'seller') {
          return AppRoutes.sellerDashboard;
        } else if (authState.user?.role == 'delivery') {
          return AppRoutes.deliveryDashboard;
        } else if (authState.user?.role == 'admin') {
          return AppRoutes.adminDashboard;
        } else {
          return AppRoutes.home;
        }
      }
      
      return null;
    },
    routes: [
      // مسارات عامة
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      
      // مسارات المستخدم
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.cart,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: AppRoutes.orderSuccess,
        builder: (context, state) => const OrderSuccessScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.orderDetails}/:id',
        builder: (context, state) {
          final orderId = state.params['id']!;
          return OrderDetailsScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.productDetails}/:id',
        builder: (context, state) {
          final productId = state.params['id']!;
          return ProductDetailsScreen(productId: productId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.categoryProducts}/:id',
        builder: (context, state) {
          final categoryId = state.params['id']!;
          return CategoryProductsScreen(categoryId: categoryId);
        },
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) {
          final query = state.queryParams['q'] ?? '';
          return SearchScreen(query: query);
        },
      ),
      
      // مسارات البائع
      GoRoute(
        path: AppRoutes.sellerDashboard,
        builder: (context, state) => const SellerDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.sellerProducts,
        builder: (context, state) => const SellerProductsScreen(),
      ),
      GoRoute(
        path: AppRoutes.sellerAddProduct,
        builder: (context, state) => const SellerAddProductScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.sellerEditProduct}/:id',
        builder: (context, state) {
          final productId = state.params['id']!;
          return SellerEditProductScreen(productId: productId);
        },
      ),
      GoRoute(
        path: AppRoutes.sellerOrders,
        builder: (context, state) => const SellerOrdersScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.sellerOrderDetails}/:id',
        builder: (context, state) {
          final orderId = state.params['id']!;
          return SellerOrderDetailsScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: AppRoutes.sellerProfile,
        builder: (context, state) => const SellerProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.sellerSettings,
        builder: (context, state) => const SellerSettingsScreen(),
      ),
      
      // مسارات التوصيل
      GoRoute(
        path: AppRoutes.deliveryDashboard,
        builder: (context, state) => const DeliveryDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.deliveryOrders,
        builder: (context, state) => const DeliveryOrdersScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.deliveryOrderDetails}/:id',
        builder: (context, state) {
          final orderId = state.params['id']!;
          return DeliveryOrderDetailsScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: AppRoutes.deliveryProfile,
        builder: (context, state) => const DeliveryProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.deliverySettings,
        builder: (context, state) => const DeliverySettingsScreen(),
      ),
      
      // مسارات الإدارة
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminUsers,
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminSellers,
        builder: (context, state) => const AdminSellersScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminDelivery,
        builder: (context, state) => const AdminDeliveryScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminProducts,
        builder: (context, state) => const AdminProductsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminCategories,
        builder: (context, state) => const AdminCategoriesScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminOrders,
        builder: (context, state) => const AdminOrdersScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminSettings,
        builder: (context, state) => const AdminSettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
});

// تعريف الشاشات المستخدمة في التوجيه
// ملاحظة: هذه الشاشات ستكون موجودة في التطبيقات الفعلية وليست جزءًا من الحزمة المشتركة
// نستخدم هنا فقط تعريفات مؤقتة لأغراض التوجيه

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailsScreen({Key? key, required this.orderId}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class ProductDetailsScreen extends StatelessWidget {
  final String productId;
  const ProductDetailsScreen({Key? key, required this.productId}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class CategoryProductsScreen extends StatelessWidget {
  final String categoryId;
  const CategoryProductsScreen({Key? key, required this.categoryId}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class SearchScreen extends StatelessWidget {
  final String query;
  const SearchScreen({Key? key, required this.query}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class SellerProductsScreen extends StatelessWidget {
  const SellerProductsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class SellerAddProductScreen extends StatelessWidget {
  const SellerAddProductScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class SellerEditProductScreen extends StatelessWidget {
  final String productId;
  const SellerEditProductScreen({Key? key, required this.productId}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class SellerOrdersScreen extends StatelessWidget {
  const SellerOrdersScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class SellerOrderDetailsScreen extends StatelessWidget {
  final String orderId;
  const SellerOrderDetailsScreen({Key? key, required this.orderId}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class SellerProfileScreen extends StatelessWidget {
  const SellerProfileScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class SellerSettingsScreen extends StatelessWidget {
  const SellerSettingsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class DeliveryDashboardScreen extends StatelessWidget {
  const DeliveryDashboardScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class DeliveryOrdersScreen extends StatelessWidget {
  const DeliveryOrdersScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class DeliveryOrderDetailsScreen extends StatelessWidget {
  final String orderId;
  const DeliveryOrderDetailsScreen({Key? key, required this.orderId}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class DeliveryProfileScreen extends StatelessWidget {
  const DeliveryProfileScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class DeliverySettingsScreen extends StatelessWidget {
  const DeliverySettingsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class AdminSellersScreen extends StatelessWidget {
  const AdminSellersScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class AdminDeliveryScreen extends StatelessWidget {
  const AdminDeliveryScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class AdminCategoriesScreen extends StatelessWidget {
  const AdminCategoriesScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class ErrorScreen extends StatelessWidget {
  final Exception? error;
  const ErrorScreen({Key? key, this.error}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}
