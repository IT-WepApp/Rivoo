import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:user_app/core/services/crashlytics_service.dart';
import 'package:user_app/core/state/app_state_provider.dart';
import 'package:user_app/core/state/connectivity_provider.dart';
import 'package:user_app/l10n/l10n.dart';
import 'package:user_app/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة Firebase
  await Firebase.initializeApp();
  
  // تهيئة Crashlytics
  final crashlytics = FirebaseCrashlytics.instance;
  await crashlytics.setCrashlyticsCollectionEnabled(true);
  
  // التقاط الأخطاء غير المعالجة
  FlutterError.onError = (FlutterErrorDetails details) {
    crashlytics.recordFlutterError(details);
  };
  
  // بدء التطبيق داخل منطقة آمنة
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // مراقبة حالة الاتصال
    ref.listen(connectivityNotifierProvider, (previous, next) {
      next.whenData((connectivityResult) {
        final isConnected = connectivityResult != ConnectivityResult.none;
        ref.read(appStateProvider.notifier).updateConnectionStatus(isConnected);
      });
    });
    
    // الحصول على إعدادات السمة واللغة
    final isDarkMode = ref.watch(isDarkModeProvider);
    final currentLocale = ref.watch(currentLocaleProvider);
    
    return MaterialApp.router(
      title: 'RivooSy',
      debugShowCheckedModeBanner: false,
      
      // إعدادات السمة
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      
      // إعدادات اللغة
      locale: Locale(currentLocale),
      supportedLocales: L10n.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // إعدادات التوجيه
      routerConfig: appRouter,
    );
  }
}
