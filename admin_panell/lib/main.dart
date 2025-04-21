import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme.dart';
import 'core/services/crashlytics_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  await Firebase.initializeApp();

  // تهيئة Crashlytics
  final crashlyticsManager = crashlyticsManagerProvider;
  await crashlyticsManager.initialize();

  // تغليف التطبيق بمعالج استثناءات لالتقاط جميع الأخطاء غير المتوقعة
  runApp(
    const ProviderScope(
      child: AdminPanelApp(),
    ),
  );
}

class AdminPanelApp extends ConsumerWidget {
  const AdminPanelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'لوحة الإدارة',
      theme: appTheme,
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      debugShowCheckedModeBanner: false,
    );
  }
}
