import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:shared_libs/lib/widgets/shared_widgets.dart';
import 'firebase_options.dart';

// Import app router
import 'router.dart';

// Remove or refactor NotificationService initialization if handled differently
// import 'package:seller_panel/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize services like Notifications *after* getting seller/store ID (e.g., after login)
  // await NotificationService().initialize(storeId: 'YOUR_STORE_ID_AFTER_LOGIN');

  runApp(
      const ProviderScope(child: SellerPanelApp())); // Wrap with ProviderScope
}

class SellerPanelApp extends StatelessWidget {
  const SellerPanelApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter, // Use the appRouter defined in router.dart
      title: 'Seller Panel', // Changed title
      theme: AppTheme.lightTheme, // Use shared theme
      darkTheme: AppTheme.darkTheme, // Use shared theme
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
    );
  }
}
