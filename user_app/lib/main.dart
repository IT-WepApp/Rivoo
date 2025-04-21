import 'dart:ui';

// حزم Firebase
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';

// حزم Flutter
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// حزم داخلية
import 'core/monitoring/analytics_monitor.dart';
import 'core/services/crashlytics_service.dart';
import 'l10n/l10n.dart';
import 'router.dart';
import 'theme/app_theme.dart';

/// نقطة بداية التطبيق
void main() async {
  // تأكد من تهيئة Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة Firebase
  await Firebase.initializeApp();
  
  // تهيئة Crashlytics لتتبع الأخطاء
  if (!kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
  
  // تهيئة Performance Monitoring لقياس الأداء
  await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
  
  // تشغيل التطبيق مع إعداد ProviderScope لإدارة الحالة
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

/// الفئة الرئيسية للتطبيق
/// تقوم بإعداد الثيم والترجمة والتوجيه
class MyApp extends ConsumerWidget {
  /// إنشاء نسخة جديدة من التطبيق
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // الحصول على مزودات التطبيق
    final appRouter = ref.watch(appRouterProvider);
    final analyticsObserver = ref.watch(analyticsObserverProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    
    return MaterialApp.router(
      title: 'RivooSy',
      // إعداد الثيم
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      
      // إعداد اللغة
      locale: locale,
      supportedLocales: L10n.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // إعداد التوجيه
      routerConfig: appRouter,
      
      // إعداد المراقبة التحليلية
      navigatorObservers: [
        analyticsObserver,
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
      
      // إخفاء شريط التصحيح
      debugShowCheckedModeBanner: false,
    );
  }
}

// مزودات إعدادات التطبيق
/// مزود وضع الثيم (فاتح، داكن، تلقائي)
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// مزود اللغة الحالية
final localeProvider = StateProvider<Locale?>((ref) => null);

// مزودات التوجيه والمراقبة
/// مزود موجه التطبيق
final appRouterProvider = Provider((ref) => appRouter);

/// مزود مراقب التحليلات
final analyticsObserverProvider = Provider<NavigatorObserver>((ref) => AnalyticsMonitor(ref.read));
