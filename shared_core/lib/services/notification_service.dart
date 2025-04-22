import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// خدمة الإشعارات المسؤولة عن إدارة إشعارات التطبيق
/// تستخدم Firebase Cloud Messaging للإشعارات البعيدة وFlutterLocalNotifications للإشعارات المحلية
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  /// تهيئة خدمة الإشعارات
  Future<void> init() async {
    // طلب إذن الإشعارات
    await _requestPermissions();
    
    // إعداد الإشعارات المحلية
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // إعداد معالجات إشعارات Firebase
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTapped);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // التحقق من الإشعارات التي فتحت التطبيق
    await _checkInitialMessage();
  }
  
  /// طلب أذونات الإشعارات
  Future<void> _requestPermissions() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }
  
  /// التحقق من الإشعارات التي فتحت التطبيق
  Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTapped(initialMessage);
    }
  }
  
  /// الحصول على رمز الجهاز لإرسال الإشعارات
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
  
  /// الاشتراك في موضوع معين للإشعارات
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }
  
  /// إلغاء الاشتراك من موضوع معين للإشعارات
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
  
  /// عرض إشعار محلي
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'rivoo_channel',
      'إشعارات ريفو',
      channelDescription: 'قناة إشعارات تطبيق ريفو',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
  
  /// معالجة الإشعارات في الخلفية
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    if (kDebugMode) {
      print('تم استلام إشعار في الخلفية: ${message.notification?.title}');
    }
  }
  
  /// معالجة الإشعارات في المقدمة
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('تم استلام إشعار في المقدمة: ${message.notification?.title}');
    }
    
    if (message.notification != null) {
      showLocalNotification(
        id: message.hashCode,
        title: message.notification!.title ?? 'إشعار جديد',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }
  
  /// معالجة النقر على الإشعار
  void _handleNotificationTapped(RemoteMessage message) {
    if (kDebugMode) {
      print('تم النقر على إشعار: ${message.notification?.title}');
    }
    
    // يمكن إضافة منطق التنقل هنا بناءً على بيانات الإشعار
  }
  
  /// معالجة النقر على الإشعار المحلي
  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      print('تم النقر على إشعار محلي: ${response.payload}');
    }
    
    // يمكن إضافة منطق التنقل هنا بناءً على بيانات الإشعار
  }
}
