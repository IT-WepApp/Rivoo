# خطة تنفيذ المتطلبات الإضافية لتطبيق user_app

## الأولويات والجدول الزمني

سنقوم بتنفيذ المتطلبات الإضافية وفق الأولويات التالية:

### المرحلة 1: الأمان والهيكلية الأساسية (الأولوية القصوى)

1. **استبدال Caesar بـ flutter_secure_storage**
   - تثبيت حزمة flutter_secure_storage
   - إنشاء خدمة SecureStorageService
   - استبدال جميع استخدامات Caesar بالخدمة الجديدة
   - اختبار التخزين الآمن للبيانات الحساسة

2. **تطبيق Clean Architecture**
   - إعادة هيكلة المشروع إلى Feature-based structure
   - تنظيم كل ميزة إلى طبقات (presentation, domain, data, application)
   - نقل الكود الحالي إلى الهيكل الجديد
   - التأكد من فصل المسؤوليات بشكل صحيح

3. **فصل LoginPage عن المصادقة في AuthService**
   - إعادة هيكلة AuthService لتكون مستقلة عن واجهة المستخدم
   - تحسين آلية التعامل مع Refresh Token
   - حذف كلمات المرور بعد إنشاء Refresh Token

### المرحلة 2: واجهة المستخدم والتصميم (أولوية عالية)

4. **إنشاء نظام تصميم موحد**
   - إنشاء AppColors.dart لتخزين design tokens
   - تحسين theme.dart ليشمل جميع عناصر التصميم
   - إنشاء TextTheme موحد لكل النصوص
   - دعم Light/Dark Mode في theme.dart

5. **إنشاء المكونات المشتركة**
   - تحسين AppButton, AppTextField, AppCard
   - إنشاء مكونات إضافية مثل AppDropdown, AppDialog
   - توثيق استخدام المكونات

6. **تحسين التنقل والربط**
   - تحسين نظام التوجيه باستخدام GoRouter
   - إنشاء route_constants.dart لتخزين مسارات التنقل
   - تنفيذ آلية redirect حسب الأدوار بعد تسجيل الدخول

### المرحلة 3: الاختبارات والأداء (أولوية متوسطة)

7. **إضافة اختبارات**
   - كتابة اختبارات وحدة للخدمات والمنطق
   - كتابة اختبارات واجهة للمكونات الرئيسية
   - إعداد Golden Tests لعناصر الواجهة
   - إعداد GitHub Actions لتشغيل melos run test

8. **تحسين الأداء**
   - تطبيق أفضل الممارسات مثل استخدام const, KeepAlive
   - تحسين caching للبيانات والصور
   - تحليل الأداء باستخدام DevTools

### المرحلة 4: الميزات المتقدمة (أولوية منخفضة)

9. **تحسين ميزة الخريطة المتزامنة**
   - تحسين TrackOrderPage لعرض موقع السائق في الوقت الفعلي
   - استخدام StreamBuilder للاستماع لتغييرات الموقع
   - إضافة Marker للسائق والزبون وخط Polyline

10. **التدويل والوصولية**
    - إعداد flutter_localizations وintl
    - إنشاء ملفات ARB ودعم RTL
    - تحسين الوصولية باستخدام semanticLabel وتباين الألوان

11. **التحليلات والصيانة**
    - دمج Firebase Analytics
    - تفعيل Crashlytics
    - إعداد structured logging

## خطة التنفيذ التفصيلية

### المرحلة 1: الأمان والهيكلية الأساسية

#### 1.1 استبدال Caesar بـ flutter_secure_storage

1. تثبيت حزمة flutter_secure_storage:
   ```bash
   flutter pub add flutter_secure_storage
   ```

2. إنشاء خدمة SecureStorageService:
   ```dart
   // lib/core/services/secure_storage_service.dart
   import 'package:flutter_secure_storage/flutter_secure_storage.dart';

   class SecureStorageService {
     final FlutterSecureStorage _storage = const FlutterSecureStorage();

     Future<void> write(String key, String value) async {
       await _storage.write(key: key, value: value);
     }

     Future<String?> read(String key) async {
       return await _storage.read(key: key);
     }

     Future<void> delete(String key) async {
       await _storage.delete(key: key);
     }

     Future<void> deleteAll() async {
       await _storage.deleteAll();
     }
   }
   ```

3. استبدال جميع استخدامات Caesar بالخدمة الجديدة.

#### 1.2 تطبيق Clean Architecture

1. إعادة هيكلة المشروع إلى Feature-based structure:
   ```
   lib/
   ├── core/
   │   ├── constants/
   │   │   ├── app_constants.dart
   │   │   └── route_constants.dart
   │   ├── services/
   │   │   ├── secure_storage_service.dart
   │   │   └── api_service.dart
   │   └── utils/
   │       └── validators.dart
   ├── features/
   │   ├── auth/
   │   │   ├── data/
   │   │   │   ├── datasources/
   │   │   │   ├── models/
   │   │   │   └── repositories/
   │   │   ├── domain/
   │   │   │   ├── entities/
   │   │   │   ├── repositories/
   │   │   │   └── usecases/
   │   │   ├── presentation/
   │   │   │   ├── pages/
   │   │   │   ├── widgets/
   │   │   │   └── bloc/
   │   │   └── application/
   │   │       └── auth_service.dart
   │   └── [other features]
   ├── theme/
   │   ├── app_colors.dart
   │   ├── app_theme.dart
   │   └── app_widgets.dart
   └── main.dart
   ```

2. نقل الكود الحالي إلى الهيكل الجديد.

#### 1.3 فصل LoginPage عن المصادقة في AuthService

1. إعادة هيكلة AuthService:
   ```dart
   // lib/features/auth/application/auth_service.dart
   class AuthService {
     final SecureStorageService _secureStorage;
     final FirebaseAuth _auth;

     AuthService(this._secureStorage, this._auth);

     Future<UserCredential> signIn(String email, String password) async {
       try {
         final credential = await _auth.signInWithEmailAndPassword(
           email: email,
           password: password,
         );
         
         // حفظ الرمز المميز وحذف كلمة المرور
         await _secureStorage.write('refresh_token', credential.user?.refreshToken ?? '');
         
         return credential;
       } catch (e) {
         throw Exception('فشل تسجيل الدخول: $e');
       }
     }

     // ... باقي الدوال
   }
   ```

### المرحلة 2: واجهة المستخدم والتصميم

#### 2.1 إنشاء نظام تصميم موحد

1. إنشاء AppColors.dart:
   ```dart
   // lib/theme/app_colors.dart
   import 'package:flutter/material.dart';

   class AppColors {
     // ألوان الثيم الرئيسية
     static const Color primary = Color(0xFF2E7D32);
     static const Color secondary = Color(0xFFFF8F00);
     static const Color background = Color(0xFFF5F5F5);
     static const Color error = Color(0xFFD32F2F);
     static const Color textPrimary = Color(0xFF212121);
     static const Color textSecondary = Color(0xFF757575);
     static const Color divider = Color(0xFFBDBDBD);

     // ألوان الوضع الداكن
     static const Color primaryDark = Color(0xFF1B5E20);
     static const Color secondaryDark = Color(0xFFFF6F00);
     static const Color backgroundDark = Color(0xFF121212);
     static const Color textPrimaryDark = Color(0xFFFFFFFF);
     static const Color textSecondaryDark = Color(0xFFB0B0B0);
     static const Color dividerDark = Color(0xFF424242);
   }
   ```

2. تحسين theme.dart.

#### 2.2 إنشاء المكونات المشتركة

1. تحسين AppButton, AppTextField, AppCard.

#### 2.3 تحسين التنقل والربط

1. إنشاء route_constants.dart:
   ```dart
   // lib/core/constants/route_constants.dart
   class RouteConstants {
     // Auth Routes
     static const String login = '/login';
     static const String register = '/register';
     static const String forgotPassword = '/forgot-password';
     
     // Main Routes
     static const String home = '/home';
     static const String profile = '/profile';
     static const String cart = '/cart';
     static const String checkout = '/checkout';
     
     // Order Routes
     static const String orders = '/orders';
     static const String orderDetails = '/orders/:orderId';
     static const String orderTracking = '/orders/:orderId/tracking';
     
     // Product Routes
     static const String productDetails = '/products/:productId';
     static const String favorites = '/favorites';
     
     // Other Routes
     static const String notifications = '/notifications';
     static const String settings = '/settings';
   }
   ```

### المرحلة 3: الاختبارات والأداء

#### 3.1 إضافة اختبارات

1. كتابة اختبارات وحدة للخدمات والمنطق.
2. كتابة اختبارات واجهة للمكونات الرئيسية.
3. إعداد Golden Tests لعناصر الواجهة.

#### 3.2 تحسين الأداء

1. تطبيق أفضل الممارسات مثل استخدام const, KeepAlive.
2. تحسين caching للبيانات والصور.

### المرحلة 4: الميزات المتقدمة

#### 4.1 تحسين ميزة الخريطة المتزامنة

1. تحسين TrackOrderPage لعرض موقع السائق في الوقت الفعلي.

#### 4.2 التدويل والوصولية

1. إعداد flutter_localizations وintl.

#### 4.3 التحليلات والصيانة

1. دمج Firebase Analytics.

## الجدول الزمني المقترح

- **المرحلة 1**: 3-4 أيام
- **المرحلة 2**: 2-3 أيام
- **المرحلة 3**: 2-3 أيام
- **المرحلة 4**: 3-4 أيام

**إجمالي الوقت المقدر**: 10-14 يوم عمل
