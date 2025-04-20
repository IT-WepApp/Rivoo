import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:developer'; // Import developer log

// Consider making this a singleton or providing via Riverpod
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Define notification channel (should match AndroidManifest.xml if using default channel)
  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'seller_channel_id', // id
    'Seller Notifications', // title
    description:
        'Channel for seller-specific notifications (e.g., new orders).', // description
    importance: Importance.max,
  );

  Future<void> initialize(String? storeId) async {
    if (_isInitialized) return; // Prevent multiple initializations

    try {
      // Request permission (iOS/macOS)
      final settings = await _messaging.requestPermission();
      log('Notification permission status: ${settings.authorizationStatus}', name: 'NotificationService');

      // Initialize local notifications plugin
      await _localNotifications.initialize(
          const InitializationSettings(
              android: AndroidInitializationSettings('@mipmap/ic_launcher') // Use default app icon
              // Add iOS/macOS settings if needed
          ),
          // Handle notification tap when app is in background/terminated
          onDidReceiveNotificationResponse: (NotificationResponse details) {
             log('Notification tapped with payload: ${details.payload}', name: 'NotificationService');
             // Handle payload (e.g., navigate to relevant order)
          }
        );

       // Create the Android notification channel
       await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      // Subscribe to store-specific topic if ID is available
      if (storeId != null && storeId.isNotEmpty) {
          await _messaging.subscribeToTopic(storeId);
          log('Subscribed to topic: $storeId', name: 'NotificationService');
      }

      // Set up foreground message handling
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
       _isInitialized = true;
       log('NotificationService Initialized', name: 'NotificationService');

    } catch (e, stacktrace) {
       log('Error initializing NotificationService', error: e, stackTrace: stacktrace, name: 'NotificationService');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
     log('Foreground message received: ${message.messageId}', name: 'NotificationService');

     RemoteNotification? notification = message.notification;
     AndroidNotification? android = message.notification?.android;

     // Show local notification using the defined channel
     if (notification != null && android != null) {
       _localNotifications.show(
           notification.hashCode, // Unique ID for the notification
           notification.title,
           notification.body,
            NotificationDetails(
               android: AndroidNotificationDetails(
                 _channel.id,
                 _channel.name,
                 channelDescription: _channel.description,
                  icon: android.smallIcon, // Use icon from FCM message if available
                  // other properties...
               ),
                 // Add iOS details if needed
            ),
           payload: message.data.isNotEmpty ? message.data.toString() : null // Use message data as payload
         );
     }
  }

  Future<String?> getToken() async {
    try {
       final token = await _messaging.getToken();
       log('FCM Token: $token', name: 'NotificationService');
       return token;
    } catch (e, stacktrace) {
       log('Error getting FCM token', error: e, stackTrace: stacktrace, name: 'NotificationService');
       return null;
    }
  }

   // Method to unsubscribe when seller logs out or changes store
   Future<void> unsubscribeFromStoreTopic(String? storeId) async {
      if (storeId != null && storeId.isNotEmpty) {
        try {
           await _messaging.unsubscribeFromTopic(storeId);
           log('Unsubscribed from topic: $storeId', name: 'NotificationService');
        } catch (e, stacktrace) {
            log('Error unsubscribing from topic', error: e, stackTrace: stacktrace, name: 'NotificationService');
        }
      }
   }
}