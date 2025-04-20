import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:user_app/l10n/l10n.dart';
import 'package:user_app/router.dart';
import 'package:user_app/core/services/crashlytics_service.dart';
import 'package:user_app/core/state/app_state_provider.dart';
import 'package:user_app/core/state/connectivity_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // تهيئة Firebase
  await Firebase.initializeApp();
  
  // تهيئة Crashlytics
  await CrashlyticsService.initialize();

  // التقاط الأخطاء غير المعالجة
  FlutterError.onError = (details) {
    CrashlyticsService.recordError(details.exception, details.stack!);
  };

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // متابعة حالة الاتصال
    ref.listen(connectivityNotifierProvider, (prev, result) {
      result.whenData((status) {
        ref.read(appStateProvider.notifier).updateConnectionStatus(status != ConnectivityResult.none);
      });
    });
    
    // سمة وتوجه
    final isDark = ref.watch(isDarkModeProvider);
    final localeCode = ref.watch(currentLocaleProvider);

    return MaterialApp.router(
      title: 'RivooSy',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.light),
        fontFamily: 'Cairo',
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
        fontFamily: 'Cairo',
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(localeCode),
      supportedLocales: L10n.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

// مزودات الحالة
final isDarkModeProvider = StateProvider<bool>((ref) => false);
final currentLocaleProvider = StateProvider<String>((ref) => L10n.supportedLocales.first.languageCode);