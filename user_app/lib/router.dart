import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async'; 

import 'package:user_app/features/auth/presentation/pages/login_page.dart';
import 'package:user_app/features/cart/presentation/pages/shopping_cart_page.dart';
import 'package:user_app/features/home/presentation/widgets/home_page_wrapper.dart'; 
import 'package:user_app/features/orders/presentation/pages/my_orders_page.dart';
import 'package:user_app/features/orders/presentation/pages/order_confirmation_page.dart';
import 'package:user_app/features/orders/presentation/pages/order_details_page.dart';
import 'package:user_app/features/profile/presentation/pages/profile_page.dart';
import 'package:user_app/features/store/presentation/pages/store_details_page.dart';
import 'package:user_app/features/auth/application/auth_notifier.dart'; 
import 'package:user_app/features/home/presentation/pages/home_page.dart'; 

final goRouterProvider = Provider<GoRouter>((ref) {
  final authStateChanges = ref.watch(authStateChangesProvider); 

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true, 

    redirect: (BuildContext context, GoRouterState state) {
      final loggedIn = authStateChanges.valueOrNull != null; 
      final loggingIn = state.matchedLocation == '/login';

      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/home'; 
      return null;
    },
    
    // refreshListenable is not strictly needed when watching the provider in redirect
    // but using GoRouterRefreshNotifier is a common pattern.
    // The deprecation warning for .stream might be ignorable for now.
    refreshListenable: GoRouterRefreshNotifier(ref.read(authStateChangesProvider.stream)), 

    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (BuildContext context, GoRouterState state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return HomePageWrapper(child: child);
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/home', 
            name: 'home',
            builder: (BuildContext context, GoRouterState state) => const HomePage(), 
             routes: [
               GoRoute(
                 path: 'store/:storeId', 
                 name: 'store-details',
                 builder: (BuildContext context, GoRouterState state) {
                   final storeId = state.pathParameters['storeId']!;
                   return StoreDetailsPage(storeId: storeId);
                 },
               ),
             ]
          ),
          GoRoute(
            path: '/cart',
            name: 'cart',
            builder: (BuildContext context, GoRouterState state) => const ShoppingCartPage(),
          ),
          GoRoute(
            path: '/my-orders',
            name: 'my-orders',
            builder: (BuildContext context, GoRouterState state) => const MyOrdersPage(),
             routes: <RouteBase>[
                GoRoute(
                  path: ':orderId', 
                  name: 'order-details',
                  builder: (BuildContext context, GoRouterState state) {
                     final orderId = state.pathParameters['orderId']!;
                     return OrderDetailsPage(orderId: orderId);
                  },
                ),
             ]
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (BuildContext context, GoRouterState state) => const ProfilePage(),
          ),
        ],
      ),
      GoRoute(
        path: '/order-confirmation',
        name: 'order-confirmation',
        builder: (BuildContext context, GoRouterState state) {
          return const OrderConfirmationPage();
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error - Page Not Found')),
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});

// Helper class remains the same but relies on .stream
class GoRouterRefreshNotifier extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshNotifier(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
