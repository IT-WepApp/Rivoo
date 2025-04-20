import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:user_app/core/constants/route_constants.dart';
import 'package:user_app/features/auth/application/auth_notifier.dart';
import 'package:user_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:user_app/features/auth/presentation/pages/login_page.dart';
import 'package:user_app/features/auth/presentation/pages/register_page.dart';
import 'package:user_app/features/auth/presentation/pages/verify_email_page.dart';
import 'package:user_app/features/cart/presentation/pages/checkout_page.dart';
import 'package:user_app/features/cart/presentation/pages/shopping_cart_page.dart';
import 'package:user_app/features/favorites/presentation/pages/favorites_page.dart';
import 'package:user_app/features/home/presentation/pages/home_page.dart';
import 'package:user_app/features/notifications/presentation/pages/notifications_page.dart';
import 'package:user_app/features/order_tracking/presentation/pages/order_tracking_page.dart';
import 'package:user_app/features/orders/presentation/pages/my_orders_page.dart';
import 'package:user_app/features/orders/presentation/pages/order_details_page.dart';
import 'package:user_app/features/product/presentation/pages/product_details_page.dart';
import 'package:user_app/features/product/presentation/pages/product_list_page.dart';
import 'package:user_app/features/profile/presentation/pages/profile_page.dart';
import 'package:user_app/features/profile/presentation/pages/shipping_address_form_page.dart';
import 'package:user_app/features/profile/presentation/pages/shipping_address_list_page.dart';
import 'package:user_app/features/ratings/presentation/pages/ratings_page.dart';
import 'package:user_app/features/splash/presentation/pages/splash_page.dart';

/// مزود توجيه التطبيق
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RouteConstants.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // الصفحة الحالية
      final currentPath = state.matchedLocation;
      
      // حالة المصادقة
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      
      // الصفحات التي لا تتطلب مصادقة
      final isPublicPage = 
          currentPath == RouteConstants.splash ||
          currentPath == RouteConstants.login ||
          currentPath == RouteConstants.register ||
          currentPath == RouteConstants.forgotPassword;
      
      // إذا كانت الصفحة الحالية هي صفحة البداية، فلا نقوم بأي إعادة توجيه
      if (currentPath == RouteConstants.splash) {
        return null;
      }
      
      // إذا كان المستخدم غير مسجل الدخول ويحاول الوصول إلى صفحة محمية
      if (!isLoggedIn && !isPublicPage) {
        return RouteConstants.login;
      }
      
      // إذا كان المستخدم مسجل الدخول ويحاول الوصول إلى صفحة عامة (باستثناء صفحة البداية)
      if (isLoggedIn && isPublicPage && currentPath != RouteConstants.splash) {
        return RouteConstants.home;
      }
      
      // لا توجد إعادة توجيه
      return null;
    },
    routes: [
      // صفحة البداية
      GoRoute(
        path: RouteConstants.splash,
        builder: (context, state) => const SplashPage(),
      ),
      
      // صفحات المصادقة
      GoRoute(
        path: RouteConstants.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteConstants.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteConstants.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: RouteConstants.verifyEmail,
        builder: (context, state) => const VerifyEmailPage(),
      ),
      
      // الصفحة الرئيسية
      GoRoute(
        path: RouteConstants.home,
        builder: (context, state) => const HomePage(),
      ),
      
      // صفحات المنتجات
      GoRoute(
        path: RouteConstants.productList,
        builder: (context, state) {
          final categoryId = state.queryParameters['categoryId'];
          final categoryName = state.queryParameters['categoryName'];
          return ProductListPage(
            categoryId: categoryId,
            categoryName: categoryName,
          );
        },
      ),
      GoRoute(
        path: '${RouteConstants.productDetails}/:productId',
        builder: (context, state) {
          final productId = state.pathParameters['productId'];
          return ProductDetailsPage(productId: productId ?? '');
        },
      ),
      
      // صفحات سلة التسوق
      GoRoute(
        path: RouteConstants.cart,
        builder: (context, state) => const ShoppingCartPage(),
      ),
      GoRoute(
        path: RouteConstants.checkout,
        builder: (context, state) => const CheckoutPage(),
      ),
      
      // صفحات الطلبات
      GoRoute(
        path: RouteConstants.orders,
        builder: (context, state) => const MyOrdersPage(),
      ),
      GoRoute(
        path: '${RouteConstants.orderDetails}/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId'];
          return OrderDetailsPage(orderId: orderId ?? '');
        },
      ),
      GoRoute(
        path: '${RouteConstants.orderTracking}/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId'];
          return OrderTrackingPage(orderId: orderId ?? '');
        },
      ),
      
      // صفحات الملف الشخصي
      GoRoute(
        path: RouteConstants.profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: RouteConstants.shippingAddresses,
        builder: (context, state) => const ShippingAddressListPage(),
      ),
      GoRoute(
        path: RouteConstants.addShippingAddress,
        builder: (context, state) => const ShippingAddressFormPage(),
      ),
      GoRoute(
        path: '${RouteConstants.editShippingAddress}/:addressId',
        builder: (context, state) {
          final addressId = state.pathParameters['addressId'];
          return ShippingAddressFormPage(addressId: addressId);
        },
      ),
      
      // صفحات المفضلة
      GoRoute(
        path: RouteConstants.favorites,
        builder: (context, state) => const FavoritesPage(),
      ),
      
      // صفحات التقييمات
      GoRoute(
        path: RouteConstants.ratings,
        builder: (context, state) => const RatingsPage(),
      ),
      
      // صفحة الإشعارات
      GoRoute(
        path: RouteConstants.notifications,
        builder: (context, state) => const NotificationsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('خطأ'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'الصفحة غير موجودة',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'لم نتمكن من العثور على الصفحة المطلوبة',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RouteConstants.home),
              child: const Text('العودة إلى الصفحة الرئيسية'),
            ),
          ],
        ),
      ),
    ),
  );
});
