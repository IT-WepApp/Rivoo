import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:user_app/features/auth/presentation/screens/login_screen.dart';
import 'package:user_app/features/auth/presentation/screens/register_screen.dart';
import 'package:user_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:user_app/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:user_app/features/home/presentation/home_screen.dart';
import 'package:user_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:user_app/features/orders/presentation/screens/order_details_screen.dart';
import 'package:user_app/features/orders/presentation/screens/orders_screen.dart';
import 'package:user_app/features/payment/presentation/screens/payment_screen.dart';
import 'package:user_app/features/payment/presentation/screens/payment_result_screen.dart';
import 'package:user_app/features/products/presentation/screens/product_details_screen.dart';
import 'package:user_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:user_app/features/splash/presentation/splash_screen.dart';
import 'package:user_app/features/store/presentation/store_screen.dart';

// مزود للمسارات
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // شاشة البداية
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // المصادقة
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // الشاشة الرئيسية
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // المتجر
      GoRoute(
        path: '/store/:id',
        builder: (context, state) {
          final storeId = state.pathParameters['id']!;
          return StoreScreen(storeId: storeId);
        },
      ),
      
      // تفاصيل المنتج
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return ProductDetailsScreen(productId: productId);
        },
      ),
      
      // سلة التسوق
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      
      // المفضلة
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      
      // الإشعارات
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      
      // الملف الشخصي
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      
      // الطلبات
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/order/:id',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderDetailsScreen(orderId: orderId);
        },
      ),
      
      // الدفع
      GoRoute(
        path: '/payment',
        builder: (context, state) {
          final amount = double.parse(state.queryParameters['amount'] ?? '0');
          final currency = state.queryParameters['currency'] ?? 'USD';
          final orderId = state.queryParameters['orderId'] ?? '';
          
          return PaymentScreen(
            amount: amount,
            currency: currency,
            orderId: orderId,
          );
        },
      ),
      GoRoute(
        path: '/payment-result',
        builder: (context, state) {
          final isSuccess = state.queryParameters['success'] == 'true';
          final orderId = state.queryParameters['orderId'] ?? '';
          final amount = double.parse(state.queryParameters['amount'] ?? '0');
          final currency = state.queryParameters['currency'] ?? 'USD';
          final errorMessage = state.queryParameters['error'];
          
          return PaymentResultScreen(
            isSuccess: isSuccess,
            orderId: orderId,
            amount: amount,
            currency: currency,
            errorMessage: errorMessage,
          );
        },
      ),
    ],
    // إعادة توجيه المستخدم غير المصادق إلى صفحة تسجيل الدخول
    redirect: (context, state) {
      // يمكن إضافة منطق إعادة التوجيه هنا
      return null;
    },
    // تكوين خيارات التنقل
    debugLogDiagnostics: true,
  );
});
