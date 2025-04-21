import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // إضافة لاستيراد kIsWeb و defaultTargetPlatform

/// إعدادات Firebase للتطبيق
/// ملاحظة: يجب استبدال هذه القيم بالقيم الفعلية من لوحة تحكم Firebase الخاصة بك
/// https://console.firebase.google.com/
class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBRivooSy_example_key_android',
    appId: '1:123456789012:android:a1b2c3d4e5f6g7h8',
    messagingSenderId: '123456789012',
    projectId: 'rivoosy-app',
    storageBucket: 'rivoosy-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBRivooSy_example_key_ios',
    appId: '1:123456789012:ios:a1b2c3d4e5f6g7h8',
    messagingSenderId: '123456789012',
    projectId: 'rivoosy-app',
    storageBucket: 'rivoosy-app.appspot.com',
    iosClientId:
        '123456789012-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com',
    iosBundleId: 'com.rivoosy.sellerPanel',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBRivooSy_example_key_web',
    appId: '1:123456789012:web:a1b2c3d4e5f6g7h8',
    messagingSenderId: '123456789012',
    projectId: 'rivoosy-app',
    authDomain: 'rivoosy-app.firebaseapp.com',
    storageBucket: 'rivoosy-app.appspot.com',
    measurementId: 'G-MEASUREMENT_ID',
  );

  /// الحصول على إعدادات Firebase المناسبة للمنصة الحالية
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
        throw UnsupportedError('المنصة غير مدعومة: $defaultTargetPlatform');
    }
  }
}
