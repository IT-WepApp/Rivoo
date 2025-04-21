import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/features/auth/application/auth_notifier.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final bool isRead;
  final String type;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.data,
    required this.timestamp,
    this.isRead = false,
    required this.type,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? imageUrl,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    bool? isRead,
    String? type,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'data': data,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
      'type': type,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      imageUrl: map['imageUrl'],
      data: map['data'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      isRead: map['isRead'] ?? false,
      type: map['type'] ?? 'general',
    );
  }

  factory NotificationModel.fromRemoteMessage(RemoteMessage message) {
    return NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'إشعار جديد',
      body: message.notification?.body ?? '',
      imageUrl: message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl,
      data: message.data,
      timestamp: message.sentTime ?? DateTime.now(),
      isRead: false,
      type: message.data['type'] ?? 'general',
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationModel.fromJson(String source) =>
      NotificationModel.fromMap(json.decode(source));
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? _userId;

  NotificationService(this._userId);

  Future<void> initialize() async {
    // طلب إذن الإشعارات
    await _requestPermission();

    // تهيئة الإشعارات المحلية
    await _initializeLocalNotifications();

    // تسجيل معالجات الإشعارات
    _registerForegroundHandler();
    _registerBackgroundHandlers();

    // الحصول على رمز الجهاز
    await _getToken();
  }

  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('إعدادات إذن الإشعارات: ${settings.authorizationStatus}');
  }

  Future<void> _initializeLocalNotifications() async {
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
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // إنشاء قناة الإشعارات لنظام Android
    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'إشعارات مهمة',
      description: 'هذه القناة مخصصة للإشعارات المهمة',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _registerForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('تم استلام إشعار في المقدمة: ${message.notification?.title}');

      // حفظ الإشعار في قاعدة البيانات
      _saveNotification(NotificationModel.fromRemoteMessage(message));

      // عرض إشعار محلي
      _showLocalNotification(message);
    });
  }

  void _registerBackgroundHandlers() {
    // معالج الإشعارات في الخلفية
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // معالج النقر على الإشعار عندما يكون التطبيق مغلقًا
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        _handleNotificationTap(message);
      }
    });

    // معالج النقر على الإشعار عندما يكون التطبيق في الخلفية
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  Future<void> _getToken() async {
    if (_userId == null) return;

    final token = await _firebaseMessaging.getToken();
    print('رمز FCM: $token');

    if (token != null) {
      // حفظ الرمز في Firestore
      await _firestore.collection('users').doc(_userId).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });

      // الاشتراك في موضوعات الإشعارات
      await _subscribeToTopics();
    }
  }

  Future<void> _subscribeToTopics() async {
    // الاشتراك في الإشعارات العامة
    await _firebaseMessaging.subscribeToTopic('general');

    // الاشتراك في إشعارات المستخدم
    if (_userId != null) {
      await _firebaseMessaging.subscribeToTopic('user_$_userId');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'إشعارات مهمة',
            channelDescription: 'هذه القناة مخصصة للإشعارات المهمة',
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            largeIcon: android?.imageUrl != null
                ? FilePathAndroidBitmap(android!.imageUrl!)
                : null,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: json.encode(message.data),
      );
    }
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      final data = json.decode(response.payload!);
      // معالجة النقر على الإشعار المحلي
      print('تم النقر على الإشعار المحلي: $data');

      // يمكن إضافة منطق التنقل هنا
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    print('تم النقر على الإشعار: ${message.notification?.title}');

    // تحديث حالة الإشعار إلى "مقروء"
    if (message.messageId != null && _userId != null) {
      _firestore
          .collection('users')
          .doc(_userId)
          .collection('notifications')
          .doc(message.messageId)
          .update({'isRead': true});
    }

    // يمكن إضافة منطق التنقل هنا بناءً على نوع الإشعار
    final notificationType = message.data['type'] ?? 'general';
    final targetId = message.data['targetId'];

    // مثال على منطق التنقل
    switch (notificationType) {
      case 'order':
        if (targetId != null) {
          // التنقل إلى صفحة تفاصيل الطلب
          print('التنقل إلى تفاصيل الطلب: $targetId');
        }
        break;
      case 'promotion':
        // التنقل إلى صفحة العروض
        print('التنقل إلى صفحة العروض');
        break;
      default:
        // التنقل إلى صفحة الإشعارات
        print('التنقل إلى صفحة الإشعارات');
    }
  }

  Future<void> _saveNotification(NotificationModel notification) async {
    if (_userId == null) return;

    try {
      // حفظ الإشعار في Firestore
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap());

      // حفظ الإشعار محليًا
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList('notifications') ?? [];
      notificationsJson.add(notification.toJson());

      // الاحتفاظ بآخر 50 إشعار فقط
      if (notificationsJson.length > 50) {
        notificationsJson.removeAt(0);
      }

      await prefs.setStringList('notifications', notificationsJson);
    } catch (e) {
      print('خطأ في حفظ الإشعار: $e');
    }
  }

  Future<List<NotificationModel>> getNotifications() async {
    if (_userId == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('خطأ في جلب الإشعارات: $e');
      return [];
    }
  }

  Future<List<NotificationModel>> getLocalNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList('notifications') ?? [];

      return notificationsJson
          .map((json) => NotificationModel.fromJson(json))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      print('خطأ في جلب الإشعارات المحلية: $e');
      return [];
    }
  }

  Future<void> markAsRead(String notificationId) async {
    if (_userId == null) return;

    try {
      // تحديث حالة الإشعار في Firestore
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});

      // تحديث حالة الإشعار محليًا
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList('notifications') ?? [];

      final updatedNotifications = notificationsJson.map((json) {
        final notification = NotificationModel.fromJson(json);
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true).toJson();
        }
        return json;
      }).toList();

      await prefs.setStringList('notifications', updatedNotifications);
    } catch (e) {
      print('خطأ في تحديث حالة الإشعار: $e');
    }
  }

  Future<void> markAllAsRead() async {
    if (_userId == null) return;

    try {
      // الحصول على جميع الإشعارات غير المقروءة
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      // تحديث حالة جميع الإشعارات في Firestore
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      // تحديث حالة جميع الإشعارات محليًا
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList('notifications') ?? [];

      final updatedNotifications = notificationsJson.map((json) {
        final notification = NotificationModel.fromJson(json);
        return notification.copyWith(isRead: true).toJson();
      }).toList();

      await prefs.setStringList('notifications', updatedNotifications);
    } catch (e) {
      print('خطأ في تحديث حالة جميع الإشعارات: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    if (_userId == null) return;

    try {
      // حذف الإشعار من Firestore
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notifications')
          .doc(notificationId)
          .delete();

      // حذف الإشعار محليًا
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList('notifications') ?? [];

      final updatedNotifications = notificationsJson.where((json) {
        final notification = NotificationModel.fromJson(json);
        return notification.id != notificationId;
      }).toList();

      await prefs.setStringList('notifications', updatedNotifications);
    } catch (e) {
      print('خطأ في حذف الإشعار: $e');
    }
  }

  Future<void> clearAllNotifications() async {
    if (_userId == null) return;

    try {
      // حذف جميع الإشعارات من Firestore
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notifications')
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // حذف جميع الإشعارات محليًا
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('notifications');
    } catch (e) {
      print('خطأ في حذف جميع الإشعارات: $e');
    }
  }
}

// معالج الإشعارات في الخلفية
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // تأكد من تهيئة Firebase
  // await Firebase.initializeApp();

  print('تم استلام إشعار في الخلفية: ${message.notification?.title}');

  // لا يمكن الوصول إلى قاعدة البيانات المحلية أو Firestore هنا
  // يمكن فقط عرض إشعار محلي
}

// مزود خدمة الإشعارات
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final userId = ref.watch(userIdProvider);
  return NotificationService(userId);
});

// مزود قائمة الإشعارات
final notificationsProvider =
    FutureProvider<List<NotificationModel>>((ref) async {
  final notificationService = ref.watch(notificationServiceProvider);
  return await notificationService.getNotifications();
});

// مزود عدد الإشعارات غير المقروءة
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.when(
    data: (list) => list.where((notification) => !notification.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
