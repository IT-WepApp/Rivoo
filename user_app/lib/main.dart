import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_app/core/providers/app_providers.dart';
import 'package:user_app/l10n/l10n.dart';
import 'package:user_app/router.dart';
import 'package:user_app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة التفضيلات المشتركة
  final sharedPreferences = await SharedPreferences.getInstance();
  
  // تعيين اتجاه الشاشة للدعم في الوضع العمودي والأفقي
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // الحصول على إعدادات السمة
    final themeMode = ref.watch(themeModeProvider);
    
    // الحصول على إعدادات اللغة
    final locale = ref.watch(localeProvider);
    
    return MaterialApp.router(
      title: 'RivooSy',
      debugShowCheckedModeBanner: false,
      
      // إعدادات السمة
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      
      // إعدادات التوطين
      locale: locale,
      supportedLocales: L10n.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // توجيه التطبيق
      routerConfig: appRouter,
      
      // تكييف التطبيق مع الحجم الفعلي للشاشة
      builder: (context, child) {
        // ضبط مقياس النص ليكون متناسبًا مع إعدادات المستخدم
        final mediaQueryData = MediaQuery.of(context);
        final scale = mediaQueryData.textScaleFactor.clamp(0.8, 1.2);
        
        return MediaQuery(
          data: mediaQueryData.copyWith(textScaleFactor: scale),
          child: child!,
        );
      },
    );
  }
}
