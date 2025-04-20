# تحسين حجم التطبيق في RivooSy Flutter

هذا الملف يحتوي على إرشادات وتعديلات لتحسين حجم التطبيق وأدائه.

## 1. تعديل ملف pubspec.yaml

```yaml
# إضافة الحزم التالية
dependencies:
  flutter_native_splash: ^2.3.10
  flutter_launcher_icons: ^0.13.1
  flutter_image_compress: ^2.1.0
  cached_network_image: ^3.3.1
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0

# إضافة إعدادات شاشة البداية
flutter_native_splash:
  color: "#FFFFFF"
  color_dark: "#121212"
  image: assets/images/splash_logo.png
  android: true
  ios: true
  web: false
  
  android_12:
    image: assets/images/splash_logo.png
    icon_background_color: "#FFFFFF"
    icon_background_color_dark: "#121212"

# إضافة إعدادات أيقونة التطبيق
flutter_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/images/app_icon.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/images/app_icon_foreground.png"
```

## 2. تعديل ملف android/app/build.gradle

```gradle
android {
    // ...
    
    defaultConfig {
        // ...
        
        // تمكين تقسيم الحزم حسب المعمارية
        ndk {
            abiFilters 'armeabi-v7a', 'arm64-v8a', 'x86_64'
        }
    }
    
    // إضافة إعدادات تقسيم الحزم
    splits {
        abi {
            enable true
            reset()
            include 'armeabi-v7a', 'arm64-v8a', 'x86_64'
            universalApk false
        }
    }
    
    // تحسين حجم الحزمة
    buildTypes {
        release {
            // ...
            
            // تمكين تقليص الكود
            minifyEnabled true
            shrinkResources true
            
            // استخدام ملف proguard الافتراضي
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
    
    // تمكين R8
    compileOptions {
        // ...
    }
}
```

## 3. إنشاء ملف proguard-rules.pro

```
# حفظ الفئات المستخدمة في التطبيق
-keep class com.rivoosyapp.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# حفظ الفئات المستخدمة في Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# حفظ الفئات المستخدمة في Riverpod
-keep class com.riverpod.** { *; }

# حفظ الفئات المستخدمة في GoRouter
-keep class go_router.** { *; }

# قواعد عامة
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
```

## 4. تحويل الصور إلى صيغة WebP

إنشاء سكريبت لتحويل جميع الصور في مجلد assets/images إلى صيغة WebP:

```dart
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<void> convertImagesToWebP() async {
  final directory = Directory('assets/images');
  final entities = await directory.list().toList();
  
  for (var entity in entities) {
    if (entity is File) {
      final extension = path.extension(entity.path).toLowerCase();
      if (extension == '.jpg' || extension == '.jpeg' || extension == '.png') {
        final outputPath = entity.path.replaceAll(extension, '.webp');
        
        final result = await FlutterImageCompress.compressAndGetFile(
          entity.path,
          outputPath,
          format: CompressFormat.webp,
          quality: 90,
        );
        
        if (result != null) {
          final originalSize = await entity.length();
          final newSize = await result.length();
          
          print('تم تحويل ${entity.path}');
          print('الحجم الأصلي: ${originalSize ~/ 1024} كيلوبايت');
          print('الحجم الجديد: ${newSize ~/ 1024} كيلوبايت');
          print('نسبة التحسين: ${(1 - newSize / originalSize) * 100}%');
          
          // حذف الملف الأصلي بعد التحويل
          await entity.delete();
        }
      }
    }
  }
}
```

## 5. استخدام CachedNetworkImage

استبدال جميع استخدامات Image.network بـ CachedNetworkImage:

```dart
// قبل
Image.network(
  product.imageUrl!,
  fit: BoxFit.cover,
)

// بعد
CachedNetworkImage(
  imageUrl: product.imageUrl!,
  fit: BoxFit.cover,
  placeholder: (context, url) => const Center(
    child: CircularProgressIndicator(),
  ),
  errorWidget: (context, url, error) => const Icon(
    Icons.image_not_supported,
    color: Colors.grey,
  ),
)
```

## 6. تحسين استخدام الذاكرة

```dart
// إضافة هذه الدالة في main.dart
void _setupMemoryManagement() {
  // تنظيف الذاكرة المؤقتة عند تقليل التطبيق
  SystemChannels.lifecycle.setMessageHandler((msg) async {
    if (msg == AppLifecycleState.paused.toString()) {
      await ImageCache.instance.clear();
      await ImageCache.instance.clearLiveImages();
    }
    return null;
  });
  
  // تحديد حجم ذاكرة التخزين المؤقت للصور
  PaintingBinding.instance.imageCache.maximumSize = 100;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 50 ميجابايت
}
```

## 7. تحسين أداء القوائم

استخدام ListView.builder بدلاً من ListView العادي، واستخدام const للعناصر الثابتة:

```dart
// قبل
ListView(
  children: items.map((item) => ItemWidget(item: item)).toList(),
)

// بعد
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    final item = items[index];
    return ItemWidget(key: ValueKey(item.id), item: item);
  },
)
```

## 8. تأخير تحميل الموارد غير الضرورية

```dart
// استخدام FutureBuilder لتأخير تحميل البيانات غير الضرورية
FutureBuilder<List<Product>>(
  future: _loadProducts(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const AppLoadingIndicator();
    }
    
    if (snapshot.hasError) {
      return AppErrorWidget(
        message: 'حدث خطأ أثناء تحميل المنتجات',
        onRetry: () => setState(() {}),
      );
    }
    
    final products = snapshot.data ?? [];
    return ProductGrid(products: products);
  },
)
```

## 9. تحسين استخدام الموارد

```dart
// استخدام ValueNotifier بدلاً من setState للتغييرات البسيطة
final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);

// في الواجهة
ValueListenableBuilder<bool>(
  valueListenable: _isLoading,
  builder: (context, isLoading, child) {
    return isLoading
        ? const AppLoadingIndicator()
        : child!;
  },
  child: const ProductList(),
)
```

## 10. تحسين أداء الرسوم المتحركة

```dart
// استخدام RepaintBoundary لتحسين أداء الرسوم المتحركة
RepaintBoundary(
  child: AnimatedWidget(),
)
```

## 11. تعليمات لإنشاء حزمة الإنتاج

```bash
# إنشاء شاشة البداية
flutter pub run flutter_native_splash:create

# إنشاء أيقونة التطبيق
flutter pub run flutter_launcher_icons

# بناء حزمة الإنتاج مع تقسيم المعماريات
flutter build apk --split-per-abi --obfuscate --split-debug-info=build/app/outputs/symbols

# أو بناء حزمة App Bundle للنشر على Google Play
flutter build appbundle --obfuscate --split-debug-info=build/app/outputs/symbols
```

## 12. ملاحظات إضافية

1. استخدم `flutter_secure_storage` بدلاً من `Caesar` لتخزين البيانات الحساسة
2. استخدم `const` للعناصر الثابتة لتحسين الأداء
3. استخدم `SizedBox.shrink()` بدلاً من `Container()` الفارغ
4. استخدم `ListView.builder` بدلاً من `ListView` العادي للقوائم الطويلة
5. استخدم `cached_network_image` لتحسين أداء تحميل الصور
6. استخدم صيغة WebP للصور بدلاً من PNG أو JPEG
7. استخدم تقسيم الحزم حسب المعمارية لتقليل حجم التطبيق
8. استخدم R8 وProGuard لتقليص الكود وتشويشه
