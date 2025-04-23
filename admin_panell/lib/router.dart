import 'package:flutter/material.dart'; // Added Material import
import 'package:go_router/go_router.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/dashboard/presentation/pages/admin_home_page.dart';
import 'features/category_management/presentation/pages/category_management_page.dart';
import 'features/product_management/presentation/pages/product_list_page.dart';
import 'features/order_management/presentation/pages/order_list_page.dart';
import 'features/user_management/presentation/pages/user_list_page.dart';
import 'features/store_management/presentation/pages/store_list_page.dart';
import 'features/statistics_and_reports/presentation/pages/statistics_and_reports_page.dart';

// Placeholder/Example Auth Guard (Implement proper logic)
Future<String?> authGuard(BuildContext context, GoRouterState state) async {
  // Added BuildContext
  // Implement actual authentication check (e.g., check Firebase auth state, token)
  // Example: final authService = ProviderContainer().read(authServiceProvider);
  // bool isAuthenticated = authService.currentUser != null;
  bool isAuthenticated = true; // Replace with your actual logic

  final loggingIn = state.matchedLocation == '/';

  // ignore: dead_code
  if (!isAuthenticated) {
// Redirect to login if not authenticated and not already on login page
  }
  if (isAuthenticated && loggingIn) {
    //  Redirect to the appropriate home based on user role if needed
    return '/adminHome'; // Redirect logged-in users from login page to admin home
  }

  return null; // Allow navigation
}

final appRouter = GoRouter(
  // Apply auth guard globally
  // Note: Consider using refreshListenable with Riverpod for reactive auth state
  redirect: authGuard,
  initialLocation: '/', // Start at the login page
  routes: [
    GoRoute(
      path: '/', // Login Page
      builder: (context, state) =>
          const AdminLoginPage(), // Assuming this is the main entry/login
    ),
    GoRoute(
        path: '/adminHome', // Admin Dashboard
        builder: (context, state) => const AdminHomePage(),
        routes: [
          // Nested routes accessible from the admin home/dashboard
          GoRoute(
            path:
                'categoryManagement', // Relative path: /adminHome/categoryManagement
            builder: (context, state) => const CategoryManagementPage(),
          ),
          GoRoute(
            path: 'productManagement',
            builder: (context, state) => const ProductListPage(),
          ),
          GoRoute(
            path: 'orderManagement',
            builder: (context, state) => const OrderListPage(),
          ),
          GoRoute(
            path: 'userManagement',
            builder: (context, state) => const UserListPage(),
          ),
          GoRoute(
            path: 'storeManagement',
            builder: (context, state) => const StoreListPage(),
          ),
          GoRoute(
            path: 'statistics',
            builder: (context, state) => const StatisticsAndReportsPage(),
          ),
          // Add other admin sections here
        ]),
    // Add routes for other roles if this app handles them,
    // or remove if login page redirects to specific role apps.
    // Example (if needed):
    // GoRoute(
    //   path: '/deliveryHome',
    //   builder: (context, state) => const DeliveryHomePage(),
    // ),
    // GoRoute(
    //   path: '/sellerHome',
    //   builder: (context, state) => const SellerHomePage(),
    // ),
    // GoRoute(
    //   path: '/userHome',
    //   builder: (context, state) => const UserHomePage(),
    // ),
  ],
  // Optional: Error handling for unknown routes
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(child: Text('Page not found: ${state.error}')),
  ),
);
