import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import 'auth_service.dart';

/// خدمة الإشعارات للبائعين
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // تهيئة خدمة الإشعارات
  Future<void> initialize() async {
    // طلب إذن الإشعارات
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // تهيئة الإشعارات المحلية
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings =
          InitializationSettings(android: androidSettings, iOS: iosSettings);

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // إعداد قناة الإشعارات للأندرويد
      const androidChannel = AndroidNotificationChannel(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        description: AppConstants.notificationChannelDescription,
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);

      // الاستماع للإشعارات في الخلفية
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // الاستماع للإشعارات في المقدمة
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // الحصول على رمز FCM وتحديثه في Firestore
      final token = await _messaging.getToken();
      if (token != null) {
        await _updateFcmToken(token);
      }

      // الاستماع لتغييرات رمز FCM
      _messaging.onTokenRefresh.listen(_updateFcmToken);
    }
  }

  // معالج الإشعارات في الخلفية
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // يمكن إضافة منطق خاص هنا للتعامل مع الإشعارات في الخلفية
    print('تم استلام إشعار في الخلفية: ${message.notification?.title}');
  }

  // معالج الإشعارات في المقدمة
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.notificationChannelId,
            AppConstants.notificationChannelName,
            channelDescription: AppConstants.notificationChannelDescription,
            icon: android.smallIcon ?? '@mipmap/ic_launcher',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }

    // تخزين الإشعار في Firestore
    await _storeNotification(message);
  }

  // معالج النقر على الإشعار
  void _onNotificationTapped(NotificationResponse response) {
    // يمكن إضافة منطق للتنقل إلى الشاشة المناسبة عند النقر على الإشعار
    print('تم النقر على الإشعار: ${response.payload}');
  }

  // تحديث رمز FCM في Firestore
  Future<void> _updateFcmToken(String token) async {
    final authService = AuthService();
    final userId = await authService.getCurrentUserId();

    if (userId != null) {
      await _firestore
          .collection(AppConstants.sellersCollection)
          .doc(userId)
          .update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });
    }
  }

  // تخزين الإشعار في Firestore
  Future<void> _storeNotification(RemoteMessage message) async {
    final authService = AuthService();
    final userId = await authService.getCurrentUserId();

    if (userId != null) {
      await _firestore
          .collection(AppConstants.sellersCollection)
          .doc(userId)
          .collection(AppConstants.notificationsCollection)
          .add({
        'title': message.notification?.title,
        'body': message.notification?.body,
        'data': message.data,
        'read': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  // الحصول على إشعارات البائع
  Stream<QuerySnapshot> getSellerNotifications() {
    final authService = AuthService();
    final userId = authService.getCurrentUserId();
    
    if (userId == null) {
      // إرجاع تدفق فارغ في حالة عدم وجود مستخدم
      return Stream.empty();
    }
    
    return _firestore
        .collection(AppConstants.sellersCollection)
        .doc(userId)
        .collection(AppConstants.notificationsCollection)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // تحديث حالة قراءة الإشعار
  Future<void> markNotificationAsRead(String notificationId) async {
    final authService = AuthService();
    final userId = await authService.getCurrentUserId();

    if (userId != null) {
      await _firestore
          .collection(AppConstants.sellersCollection)
          .doc(userId)
          .collection(AppConstants.notificationsCollection)
          .doc(notificationId)
          .update({
        'read': true,
      });
    }
  }

  // حذف إشعار
  Future<void> deleteNotification(String notificationId) async {
    final authService = AuthService();
    final userId = await authService.getCurrentUserId();

    if (userId != null) {
      await _firestore
          .collection(AppConstants.sellersCollection)
          .doc(userId)
          .collection(AppConstants.notificationsCollection)
          .doc(notificationId)
          .delete();
    }
  }

  // تحديث حالة قراءة جميع الإشعارات
  Future<void> markAllNotificationsAsRead() async {
    final authService = AuthService();
    final userId = await authService.getCurrentUserId();

    if (userId != null) {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection(AppConstants.sellersCollection)
          .doc(userId)
          .collection(AppConstants.notificationsCollection)
          .where('read', isEqualTo: false)
          .get();

      for (final doc in notifications.docs) {
        batch.update(doc.reference, {'read': true});
      }

      await batch.commit();
    }
  }
  
  // مسح جميع الإشعارات
  Future<void> clearAllNotifications() async {
    final authService = AuthService();
    final userId = await authService.getCurrentUserId();

    if (userId != null) {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection(AppConstants.sellersCollection)
          .doc(userId)
          .collection(AppConstants.notificationsCollection)
          .get();

      for (final doc in notifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    }
  }

  // إلغاء الاشتراك في الإشعارات
  Future<void> unsubscribe() async {
    final token = await _messaging.getToken();
    if (token != null) {
      final authService = AuthService();
      await authService.removeFcmToken(token);
    }
    await _messaging.deleteToken();
  }
}

// مزود خدمة الإشعارات
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// مزود إشعارات البائع
final sellerNotificationsProvider = StreamProvider<QuerySnapshot>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.getSellerNotifications();
});

// مزود عدد الإشعارات غير المقروءة
final unreadNotificationsCountProvider = StreamProvider<int>((ref) {
  final notificationsStream = ref.watch(sellerNotificationsProvider);

  return notificationsStream.when(
    data: (snapshot) {
      final unreadCount =
          snapshot.docs.where((doc) => doc['read'] == false).length;
      return Stream.value(unreadCount);
    },
    loading: () => Stream.value(0),
    error: (_, __) => Stream.value(0),
  );
});
