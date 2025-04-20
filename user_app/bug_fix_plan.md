# خطة إصلاح الأخطاء البرمجية في تطبيق user_app

## المشكلات المحددة

بعد تحليل الأخطاء البرمجية في الملف المرفق، تم تحديد المشكلات التالية:

1. **ملفات مفقودة**: هناك عدة ملفات مطلوبة غير موجودة في هيكل المشروع.
2. **مسارات استيراد غير صحيحة**: هناك مشكلات في مسارات الاستيراد (import) في ملفات المصادقة.
3. **مراجع غير معرفة**: هناك استخدام لمتغيرات وكلاسات غير معرفة.
4. **أساليب مهملة**: هناك استخدام لأساليب مهملة مثل `updateEmail()`.

## خطة الإصلاح

### 1. إنشاء الملفات المفقودة

سيتم إنشاء الملفات المفقودة التالية بالترتيب:

1. `/home/ubuntu/RivooSy_Flutter/user_app/lib/core/constants/app_constants.dart`
   - يحتوي على ثوابت التطبيق مثل مفاتيح التخزين الآمن وإعدادات المصادقة

2. `/home/ubuntu/RivooSy_Flutter/user_app/lib/core/constants/route_constants.dart`
   - يحتوي على ثوابت مسارات التنقل في التطبيق

3. `/home/ubuntu/RivooSy_Flutter/user_app/lib/core/utils/validators.dart`
   - يحتوي على دوال التحقق من صحة المدخلات مثل البريد الإلكتروني وكلمة المرور

4. `/home/ubuntu/RivooSy_Flutter/user_app/lib/core/services/secure_storage_service.dart`
   - يحتوي على خدمة التخزين الآمن باستخدام flutter_secure_storage

5. `/home/ubuntu/RivooSy_Flutter/user_app/lib/theme/app_widgets.dart`
   - يحتوي على مكونات واجهة المستخدم المشتركة مثل AppTextField و AppButton

### 2. تصحيح مسارات الاستيراد

سيتم تصحيح مسارات الاستيراد في الملفات التالية:

1. `/home/ubuntu/RivooSy_Flutter/user_app/lib/features/auth/application/auth_service.dart`
   - تصحيح مسارات استيراد الملفات المفقودة

2. `/home/ubuntu/RivooSy_Flutter/user_app/lib/features/auth/presentation/pages/forgot_password_page.dart`
   - تصحيح مسارات استيراد الملفات المفقودة

### 3. إصلاح المراجع غير المعرفة

سيتم إصلاح المراجع غير المعرفة التالية:

1. `SecureStorageService` في ملف auth_service.dart
2. `AppConstants` في ملف auth_service.dart
3. `Validators` في ملف forgot_password_page.dart
4. `AppTextField` و `AppButton` في ملف forgot_password_page.dart

### 4. تحديث الأساليب المهملة

سيتم تحديث الأساليب المهملة التالية:

1. استبدال `updateEmail()` بـ `verifyBeforeUpdateEmail()` في ملف auth_service.dart

### 5. إضافة التبعيات المطلوبة

سيتم التأكد من إضافة التبعيات التالية في ملف pubspec.yaml:

1. `flutter_secure_storage` للتخزين الآمن
2. `go_router` للتنقل

## خطوات التنفيذ

1. إنشاء المجلدات المفقودة في هيكل المشروع
2. إنشاء ملفات الثوابت (app_constants.dart و route_constants.dart)
3. إنشاء ملف validators.dart
4. إنشاء ملف secure_storage_service.dart
5. إنشاء ملف app_widgets.dart
6. تصحيح ملف auth_service.dart
7. تصحيح ملف forgot_password_page.dart
8. التحقق من ملف pubspec.yaml وإضافة التبعيات المطلوبة
9. اختبار الإصلاحات للتأكد من حل جميع المشكلات

## النتائج المتوقعة

بعد تنفيذ هذه الإصلاحات، يجب أن:

1. تختفي جميع أخطاء "Target of URI doesn't exist"
2. تختفي جميع أخطاء "Undefined name" و "Undefined class"
3. تختفي جميع أخطاء "The method isn't defined"
4. تختفي تحذيرات الأساليب المهملة

سيتم توثيق جميع التغييرات والإصلاحات في تقرير نهائي للمستخدم.
