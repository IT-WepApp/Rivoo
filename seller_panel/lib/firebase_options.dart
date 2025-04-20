import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // إضافة لاستيراد kIsWeb و defaultTargetPlatform

class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your_api_key', 
    appId: 'your_app_id',
    messagingSenderId: 'your_sender_id',
    projectId: 'your_project_id',
    storageBucket: 'your_storage_bucket',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your_api_key',
    appId: 'your_app_id',
    messagingSenderId: 'your_sender_id',
    projectId: 'your_project_id',
    storageBucket: 'your_storage_bucket',
    iosClientId: 'your_ios_client_id',
    iosBundleId: 'com.example.your_app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'your_api_key',
    appId: 'your_app_id',
    messagingSenderId: 'your_sender_id',
    projectId: 'your_project_id',
    authDomain: 'your_project_id.firebaseapp.com',
    storageBucket: 'your_storage_bucket',
    measurementId: 'your_measurement_id',
  );

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }
}
