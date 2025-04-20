import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:seller_panel/services/notification_service.dart';

@GenerateMocks([
  FirebaseMessaging, 
  FlutterLocalNotificationsPlugin,
  AndroidFlutterLocalNotificationsPlugin,
  NotificationResponse
])
void main() {
  late NotificationService notificationService;
  late MockFirebaseMessaging mockMessaging;
  late MockFlutterLocalNotificationsPlugin mockLocalNotifications;
  late MockAndroidFlutterLocalNotificationsPlugin mockAndroidPlugin;

  setUp(() {
    mockMessaging = MockFirebaseMessaging();
    mockLocalNotifications = MockFlutterLocalNotificationsPlugin();
    mockAndroidPlugin = MockAndroidFlutterLocalNotificationsPlugin();
    
    // استبدال الكائنات الحقيقية بالكائنات المزيفة للاختبار
    notificationService = NotificationService();
    
    // تعيين الحقول الخاصة باستخدام التفكير (reflection)
    // هذا يتطلب تعديل الفئة NotificationService لتسهيل الاختبار
    // أو استخدام مكتبة مثل mockito_extensions
  });

  group('NotificationService Tests', () {
    test('getToken يجب أن يعيد توكن FCM', () async {
      // الإعداد
      when(mockMessaging.getToken()).thenAnswer((_) async => 'test-fcm-token');
      
      // التنفيذ
      final token = await notificationService.getToken();
      
      // التحقق
      expect(token, 'test-fcm-token');
      verify(mockMessaging.getToken()).called(1);
    });

    test('getToken يجب أن يعيد null عند حدوث خطأ', () async {
      // الإعداد
      when(mockMessaging.getToken()).thenThrow(Exception('Test error'));
      
      // التنفيذ
      final token = await notificationService.getToken();
      
      // التحقق
      expect(token, null);
      verify(mockMessaging.getToken()).called(1);
    });

    test('initialize يجب أن يطلب الأذونات ويهيئ الإشعارات المحلية', () async {
      // الإعداد
      final mockNotificationSettings = NotificationSettings(
        authorizationStatus: AuthorizationStatus.authorized,
        alert: AppleNotificationSetting.enabled,
        announcement: AppleNotificationSetting.disabled,
        badge: AppleNotificationSetting.enabled,
        carPlay: AppleNotificationSetting.disabled,
        lockScreen: AppleNotificationSetting.enabled,
        notificationCenter: AppleNotificationSetting.enabled,
        showPreviews: AppleShowPreviewSetting.always,
        sound: AppleNotificationSetting.enabled,
        criticalAlert: AppleNotificationSetting.disabled,
        providesAppNotificationSettings: false,
      );
      
      when(mockMessaging.requestPermission()).thenAnswer((_) async => mockNotificationSettings);
      when(mockLocalNotifications.initialize(any, onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse')))
          .thenAnswer((_) async => true);
      when(mockLocalNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>())
          .thenReturn(mockAndroidPlugin);
      when(mockAndroidPlugin.createNotificationChannel(any)).thenAnswer((_) async => true);
      when(mockMessaging.subscribeToTopic(any)).thenAnswer((_) async => true);
      
      // التنفيذ
      await notificationService.initialize('test-store-id');
      
      // التحقق
      verify(mockMessaging.requestPermission()).called(1);
      verify(mockLocalNotifications.initialize(any, onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'))).called(1);
      verify(mockLocalNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()).called(1);
      verify(mockAndroidPlugin.createNotificationChannel(any)).called(1);
      verify(mockMessaging.subscribeToTopic('test-store-id')).called(1);
    });

    test('unsubscribeFromStoreTopic يجب أن يلغي الاشتراك من موضوع المتجر', () async {
      // الإعداد
      when(mockMessaging.unsubscribeFromTopic(any)).thenAnswer((_) async => true);
      
      // التنفيذ
      await notificationService.unsubscribeFromStoreTopic('test-store-id');
      
      // التحقق
      verify(mockMessaging.unsubscribeFromTopic('test-store-id')).called(1);
    });
  });
}
