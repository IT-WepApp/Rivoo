import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/core/auth/auth_guard.dart';
import 'package:user_app/features/auth/presentation/screens/login_screen.dart';
import 'package:user_app/features/auth/presentation/screens/register_screen.dart';
import 'package:user_app/features/home/presentation/screens/home_screen.dart';
import 'package:user_app/features/payment/presentation/screens/payment_screen.dart';
import 'package:user_app/features/payment/presentation/screens/payment_result_screen.dart';
import 'package:user_app/features/product_details/presentation/screens/product_details_screen.dart';
import 'package:user_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:user_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:user_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:user_app/features/support/presentation/screens/support_tickets_screen.dart';
import 'package:user_app/features/support/presentation/screens/create_ticket_screen.dart';
import 'package:user_app/features/support/presentation/screens/ticket_details_screen.dart';
import 'package:user_app/features/order_tracking/presentation/pages/order_tracking_page.dart';
import 'package:user_app/features/ratings/presentation/screens/product_reviews_screen.dart';
import 'package:user_app/features/ratings/presentation/screens/add_review_screen.dart';
import 'package:user_app/features/auth/presentation/screens/unauthorized_screen.dart';

/// مزود مسارات التطبيق
final routerProvider = Provider<AppRouter>((ref) => AppRouter(ref));

/// موجه التطبيق
/// يتحكم في تسجيل وإنشاء المسارات في التطبيق
class AppRouter {
  final ProviderRef _ref;
  
  AppRouter(this._ref);
  
  /// إنشاء مسارات التطبيق
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
          settings: settings,
        );
        
      case '/login':
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
          settings: settings,
        );
        
      case '/register':
        return MaterialPageRoute(
          builder: (context) => const RegisterScreen(),
          settings: settings,
        );
        
      case '/unauthorized':
        return MaterialPageRoute(
          builder: (context) => const UnauthorizedScreen(),
          settings: settings,
        );
        
      case '/product':
        return MaterialPageRoute(
          builder: (context) => ProductDetailsScreen(
            productId: (settings.arguments as Map<String, dynamic>)['productId'] as String,
          ),
          settings: settings,
        );
        
      case '/cart':
        return AuthGuardRoute(
          builder: (context) => const CartScreen(),
          settings: settings,
          requiredRoles: ['customer', 'admin'],
        );
        
      case '/profile':
        return AuthGuardRoute(
          builder: (context) => const ProfileScreen(),
          settings: settings,
        );
        
      case '/settings':
        return AuthGuardRoute(
          builder: (context) => const SettingsScreen(),
          settings: settings,
        );
        
      case '/payment':
        return AuthGuardRoute(
          builder: (context) {
            final args = settings.arguments as Map<String, dynamic>;
            return PaymentScreen(
              amount: args['amount'] as int,
              currency: args['currency'] as String,
              orderId: args['orderId'] as String,
            );
          },
          settings: settings,
          requiredRoles: ['customer', 'admin'],
        );
        
      case '/payment/result':
        return AuthGuardRoute(
          builder: (context) {
            final args = settings.arguments as Map<String, dynamic>;
            return PaymentResultScreen(
              orderId: args['orderId'] as String,
              amount: args['amount'] as int,
              currency: args['currency'] as String,
            );
          },
          settings: settings,
          requiredRoles: ['customer', 'admin'],
        );
        
      case '/orders':
        return AuthGuardRoute(
          builder: (context) => const OrderTrackingPage(),
          settings: settings,
          requiredRoles: ['customer', 'admin'],
        );
        
      case '/order':
        return AuthGuardRoute(
          builder: (context) => OrderTrackingPage(
            orderId: (settings.arguments as Map<String, dynamic>)['orderId'] as String,
          ),
          settings: settings,
          requiredRoles: ['customer', 'admin'],
        );
        
      case '/reviews':
        return MaterialPageRoute(
          builder: (context) => ProductReviewsScreen(
            productId: (settings.arguments as Map<String, dynamic>)['productId'] as String,
          ),
          settings: settings,
        );
        
      case '/reviews/add':
        return AuthGuardRoute(
          builder: (context) => AddReviewScreen(
            productId: (settings.arguments as Map<String, dynamic>)['productId'] as String,
          ),
          settings: settings,
          requiredRoles: ['customer', 'admin'],
        );
        
      case '/support':
        return AuthGuardRoute(
          builder: (context) => const SupportTicketsScreen(),
          settings: settings,
        );
        
      case '/support/create':
        return AuthGuardRoute(
          builder: (context) => const CreateTicketScreen(),
          settings: settings,
        );
        
      case '/support/ticket':
        return AuthGuardRoute(
          builder: (context) => TicketDetailsScreen(
            ticketId: (settings.arguments as Map<String, dynamic>)['ticketId'] as String,
          ),
          settings: settings,
        );
        
      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('صفحة غير موجودة'),
            ),
          ),
          settings: settings,
        );
    }
  }
}
