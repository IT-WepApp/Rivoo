import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_app/features/notifications/application/notification_service.dart';
import 'package:user_app/router.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

// استقبال الإشعارات في الخلفية
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('تم استلام إشعار في الخلفية: ${message.messageId}');
}

void main() async {
  // الحفاظ على شاشة البداية حتى اكتمال التهيئة
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  // تهيئة Firebase
  await Firebase.initializeApp();
  
  // إعداد استقبال الإشعارات في الخلفية
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // تحميل إعدادات الثيم
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  
  // تعيين وضع النظام
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: isDarkMode ? AppTheme.darkTheme().scaffoldBackgroundColor : AppTheme.lightTheme().scaffoldBackgroundColor,
      systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
    ),
  );
  
  // تعيين اتجاه التطبيق للوضع الرأسي فقط
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(
    ProviderScope(
      child: MyApp(isDarkMode: isDarkMode),
    ),
  );
  
  // إزالة شاشة البداية بعد اكتمال التهيئة
  FlutterNativeSplash.remove();
}

class MyApp extends ConsumerStatefulWidget {
  final bool isDarkMode;
  
  const MyApp({super.key, required this.isDarkMode});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late bool _isDarkMode;
  
  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    
    // تهيئة خدمة الإشعارات
    Future.delayed(Duration.zero, () {
      ref.read(notificationServiceProvider).initialize();
    });
  }
  
  void _toggleThemeMode() async {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    
    // حفظ إعدادات الثيم
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    
    // تحديث وضع النظام
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: _isDarkMode ? AppTheme.darkTheme().scaffoldBackgroundColor : AppTheme.lightTheme().scaffoldBackgroundColor,
        systemNavigationBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'RivooSy',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'), // العربية
        Locale('en'), // الإنجليزية
      ],
      locale: const Locale('ar'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
}
