import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart'; // Needed for Scaffold
import 'features/auth/presentation/pages/seller_login_page.dart';
import 'features/home/presentation/pages/seller_home_page.dart';
import 'features/products/presentation/pages/product_list_page.dart';
import 'features/products/presentation/pages/add_product_page.dart';
import 'features/products/presentation/pages/edit_product_page.dart';
import 'features/orders/presentation/pages/order_list_page.dart'; // Changed from orders_page
import 'features/promotions/presentation/pages/promotion_management_page.dart';
import 'features/statistics/presentation/pages/statistics_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';

// Implement proper auth guard
Future<String?> sellerAuthGuard(GoRouterState state) async {
  bool isAuthenticated = true; // Replace with actual check
  // ignore: dead_code
  if (!isAuthenticated && state.matchedLocation != '/') {
    return '/'; // Redirect to login
  }
  return null;
}

final GoRouter appRouter = GoRouter(
  // redirect: (context, state) => sellerAuthGuard(state),
  initialLocation: '/', // Start at login
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const SellerLoginPage(),
    ),
    GoRoute(
        path: '/sellerHome',
        builder: (context, state) => const SellerHomePage(),
        routes: [
          GoRoute(
            path: 'sellerProducts', //   /sellerHome/sellerProducts
            builder: (context, state) => const ProductListPage(),
          ),
          GoRoute(
            path: 'addProduct', //      /sellerHome/addProduct
            builder: (context, state) => const AddProductPage(),
          ),
          GoRoute(
              path: 'editProduct/:productId', // /sellerHome/editProduct/some_id
              builder: (context, state) {
                final productId = state.pathParameters['productId'];
                if (productId == null) {
                  return const Scaffold(
                      body: Center(child: Text('Missing Product ID')));
                }
                return EditProductPage(productId: productId);
              }),
          GoRoute(
            path: 'sellerOrders', //      /sellerHome/sellerOrders
            builder: (context, state) => const OrderListPage(),
          ),
          GoRoute(
              path: 'sellerPromotions', // /sellerHome/sellerPromotions
              builder: (context, state) {
                // Decide if promotions are general or per-product
                // Example: Navigating to general promotions page
                return const PromotionManagementPage(
                    productId: '_general_'); // Or specific product ID
              },
              routes: [
                // Optional: Route for managing promotion for a specific product
                GoRoute(
                    path: ':productId', // /sellerHome/sellerPromotions/some_id
                    builder: (context, state) {
                      final productId = state.pathParameters['productId'];
                      if (productId == null) {
                        return const Scaffold(
                            body: Center(child: Text('Missing Product ID')));
                      }
                      return PromotionManagementPage(productId: productId);
                    })
              ]),
          GoRoute(
            path: 'sellerStats', //       /sellerHome/sellerStats
            builder: (context, state) => const StatisticsPage(),
          ),
          GoRoute(
            path: 'sellerProfile', //     /sellerHome/sellerProfile
            builder: (context, state) => const ProfilePage(),
          ),
        ]),
    // Add other top-level routes if necessary
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(child: Text('Page not found: ${state.error}')),
  ),
);
