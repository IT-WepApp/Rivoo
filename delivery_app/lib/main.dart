import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// استخدام prefix لحل التعارض
import 'package:shared_libs/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:delivery_app/firebase_options.dart';
import 'package:delivery_app/features/auth/presentation/pages/delivery_login_page.dart';
import 'package:delivery_app/features/home/presentation/pages/delivery_home_page.dart';
import 'package:delivery_app/features/order_history/presentation/pages/order_history_page_corrected.dart';
import 'package:delivery_app/features/profile/presentation/pages/profile_page.dart';
import 'package:delivery_app/features/map/presentation/pages/delivery_map_page_corrected.dart';
import 'package:delivery_app/features/settings/presentation/pages/settings_page.dart';
import 'package:delivery_app/features/settings/presentation/pages/language_selection_page.dart';
import 'package:delivery_app/presentation/providers/locale_provider.dart';
import 'package:delivery_app/presentation/providers/theme_provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling background message: ${message.messageId}");
}

final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _setupNotifications() async {
  const initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: null,
    macOS: null,
  );

  await _flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (notificationResponse) {
      final payload = notificationResponse.payload;
      if (payload != null) {
        debugPrint('Notification payload: $payload');
        // Navigate to specific page if needed
      }
    },
  );

  FirebaseMessaging.instance.subscribeToTopic('all');
  FirebaseMessaging.instance.subscribeToTopic('delivery');

  await FirebaseMessaging.instance
      .requestPermission(alert: true, badge: true, sound: true);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((message) {
    debugPrint('Foreground message: ${message.data}');
    final notification = message.notification;
    final android = message.notification?.android;
    if (notification != null && android != null) {
      _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'delivery_channel_id',
            'Delivery Notifications',
            channelDescription: 'Notifications for delivery updates',
            icon: android.smallIcon,
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  });

  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      debugPrint('App opened from terminated: ${message.messageId}');
      // Navigate if needed
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    debugPrint('App opened from background: ${message.messageId}');
    // Navigate if needed
  });
}

Future<void> _sendFCMTokenToServerIfNeeded(
    String? deliveryPersonId, String? token) async {
  if (deliveryPersonId == null || token == null) return;
  debugPrint("Sending FCM Token: $token for user: $deliveryPersonId");

  // Example: Send token to backend
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // تكوين Firebase Crashlytics
  await _setupCrashlytics();

  // إعداد الإشعارات
  await _setupNotifications();

  // تسجيل رمز FCM
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _sendFCMTokenToServerIfNeeded(currentUserId, newToken);
  });

  final initialToken = await FirebaseMessaging.instance.getToken();
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  await _sendFCMTokenToServerIfNeeded(currentUserId, initialToken);

  runApp(const ProviderScope(child: DeliveryApp()));
}

Future<void> _setupCrashlytics() async {
  // تمكين التقاط الأخطاء بواسطة Crashlytics في وضع الإنتاج فقط
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(!kDebugMode);

  // التقاط أخطاء Flutter غير المعالجة
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // التقاط أخطاء Dart غير المعالجة
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const DeliveryLoginPage()),
    GoRoute(
        path: '/deliveryHome', builder: (_, __) => const DeliveryHomePage()),
    GoRoute(
        path: '/deliveryHistory', builder: (_, __) => const OrderHistoryPage()),
    GoRoute(path: '/deliveryProfile', builder: (_, __) => const ProfilePage()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
    GoRoute(
        path: '/settings/language',
        builder: (_, __) => const LanguageSelectionPage()),
    GoRoute(
      path: '/deliveryMap/:orderId',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId'];
        if (orderId == null) {
          return const Scaffold(
              body: Center(child: Text('Error: Missing Order ID')));
        }
        return DeliveryMapPage(orderId: orderId);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(child: Text('Page not found: ${state.error}')),
  ),
);

class DeliveryApp extends ConsumerWidget {
  const DeliveryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      routerConfig: _router,
      title: AppLocalizations.of(context).appTitle ?? 'Delivery App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'), // العربية
        Locale('en'), // English
        Locale('fr'), // Français
        Locale('tr'), // Türkçe
        Locale('ur'), // اردو
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}
