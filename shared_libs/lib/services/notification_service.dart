import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/notification_model.dart'; // تأكد من أن هذا المسار صحيح بناءً على مكان وجود NotificationModel

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    await _requestPermissions();
    _setupTokenRefresh();
    _listenToForegroundMessages();
  }

  Future<void> _requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _setupTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      // TODO: إرسال التوكن للسيرفر عند الحاجة
    });
  }

  void _listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // TODO: التعامل مع الرسائل داخل التطبيق
    });
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<List<NotificationModel>> getNotifications() async {
    // Placeholder - بيانات تجريبية مؤقتة
    return [
      NotificationModel(
        id: '1',
        title: 'مرحبا بك',
        body: 'هذا إشعار تجريبي',
        timestamp: DateTime.now(),
        isRead: false,
      ),
      NotificationModel(
        id: '2',
        title: 'تنبيه جديد',
        body: 'إشعار جديد بانتظارك',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
      ),
    ];
  }

  Future<void> markAsRead(String id) async {
    // TODO: تنفيذ منطق التعليم كمقروء على السيرفر أو قاعدة البيانات
  }

  Future<void> markAllAsRead() async {
    // TODO: تنفيذ منطق التعليم الكلي كمقروء
  }
}
