import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'admin_router.dart';
import 'theme.dart';
import 'core/services/crashlytics_manager.dart';
import 'core/services/crashlytics_manager_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// تعريف مزود خدمة Crashlytics
final crashlyticsManagerProvider = Provider<CrashlyticsManager>((ref) {
  return CrashlyticsManagerImpl();
});

// تعريف سمة التطبيق
final appTheme = AppTheme.lightTheme;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  await Firebase.initializeApp();
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

  // إنشاء حاوية المزودات
  final container = ProviderContainer();
  
  // تهيئة Crashlytics
  final crashlyticsManager = container.read(crashlyticsManagerProvider);
  await crashlyticsManager.initialize();

  // تغليف التطبيق بمعالج استثناءات لالتقاط جميع الأخطاء غير المتوقعة
  runApp(
    ProviderScope(
      parent: container,
      child: const AdminPanelApp(),
    ),
  );
}

class AdminPanelApp extends ConsumerWidget {
  const AdminPanelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // استخدام مزود موجه التطبيق المحسن
    final router = ref.watch(adminRouterProvider);

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
