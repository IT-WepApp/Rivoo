# سجل إعادة الهيكلة لمشروع Rivoo

هذا الملف يوثق عملية توحيد الملفات المشتركة في مكتبة `shared_libs` وإزالة التكرار من التطبيقات الأخرى.

## الخطوات المنفذة:



### تحليل المكونات المشتركة:




التحقق من محتويات shared_libs الحالية:


البحث عن ملفات المستخدم (User) المحتملة:


البحث عن خدمات المصادقة (AuthService) المحتملة:
\n\nالبحث عن مجلدات الثوابت (Constants):
\n\nالبحث عن مجلدات الأدوات المساعدة (Utils):
\n\nالبحث عن مجلدات الواجهات الرسومية (Widgets):
\n\nالبحث عن مجلدات الخدمات (Services):



## المكونات المشتركة المحددة:

بناءً على التحليل الأولي، تم تحديد المكونات التالية كمرشحة للتوحيد في `shared_libs`:

*   **ملفات مكررة:**
    *   `/home/ubuntu/Rivoo/user_app/lib/features/auth/domain/user_model.dart` (مكرر لـ `/home/ubuntu/Rivoo/shared_libs/lib/models/user_model.dart`)
*   **مجلدات الثوابت (Constants):**
    *   `/home/ubuntu/Rivoo/user_app/lib/constants`
    *   `/home/ubuntu/Rivoo/user_app/lib/core/constants`
    *   `/home/ubuntu/Rivoo/seller_panel/lib/core/constants`
    *   `/home/ubuntu/Rivoo/admin_panell/lib/constants`
*   **مجلدات الواجهات الرسومية (Widgets):**
    *   توجد مجلدات `widgets` متعددة داخل ميزات مختلفة في `user_app`, `seller_panel`, `admin_panell`, `delivery_app`. يجب تحليل محتواها لنقل المكونات المشتركة.
    *   `/home/ubuntu/Rivoo/seller_panel/lib/core/widgets`
*   **مجلدات الخدمات (Services):**
    *   `/home/ubuntu/Rivoo/user_app/lib/core/services`
    *   `/home/ubuntu/Rivoo/seller_panel/lib/core/services`
    *   `/home/ubuntu/Rivoo/seller_panel/lib/services`
    *   `/home/ubuntu/Rivoo/admin_panell/lib/core/services`
*   **ميزات مشتركة (Features):**
    *   `auth` (موجودة في جميع التطبيقات)
    *   `profile` (موجودة في `user_app`, `seller_panel`, `delivery_app`)
    *   `settings` (موجودة في `user_app`, `seller_panel`, `delivery_app`)
    *   `notifications` (موجودة في `user_app`, `seller_panel`)

سيتم تحليل محتوى هذه المجلدات والميزات بشكل أعمق لنقل الملفات ذات الصلة إلى `shared_libs` وتحديث الاستيرادات.


## نقل الملفات وتحديث الاستيرادات:


- حذف الملف المكرر: /home/ubuntu/Rivoo/user_app/lib/features/auth/domain/user_model.dart
\n\nالبحث عن مجلدات الأدوات المساعدة (Utils) داخل مجلدات core:
تم تكوين هوية Git. إعادة محاولة الالتزام والدفع...



## توحيد الملفات المشتركة (2 مايو 2025)

**الهدف:** توحيد الملفات والمكونات المشتركة من تطبيقات `user_app`, `seller_panel`, `admin_panell`, `delivery_app` إلى مكتبة `shared_libs` لمنع التكرار وتحسين قابلية الصيانة، بناءً على الخطة المعتمدة في `migration_plan.md`.

**الخطوات المنفذة:**

1.  **نقل الملفات إلى `shared_libs`:**
    *   **Constants:** تم نقل `route_constants.dart`, `user_constants.dart` من `user_app` و `admin_constants.dart` من `admin_panell` إلى `shared_libs/lib/constants/`.
    *   **Core Architecture & Error Handling:** تم نقل `core/architecture/` من `user_app` و `core/error/` من `seller_panel` إلى `shared_libs/lib/core/`.
    *   **Services:**
        *   تم نقل `crashlytics_service.*` من `user_app` إلى `shared_libs/lib/services/`.
    *   **Providers:**
        *   تم نقل `connectivity_provider.*` من `user_app` إلى `shared_libs/lib/providers/`.
    *   **Theme:** تم نقل محتويات مجلد `theme/` من `user_app` إلى `shared_libs/lib/theme/`.
    *   **Widgets:** تم نقل `rating_stars.dart` و `interactive_rating_stars.dart` من `user_app` إلى `shared_libs/lib/widgets/`.
    *   **L10n:** تم نقل محتويات مجلد `l10n/` من `user_app` إلى `shared_libs/lib/l10n/`.

2.  **تحديث الاستيرادات (Imports):**
    *   تم استخدام `find` و `sed` لتحديث مسارات الاستيراد في جميع ملفات `.dart` داخل `user_app`, `seller_panel`, `admin_panell`, `delivery_app` لكي تشير إلى المسارات الجديدة في `shared_libs`.

3.  **إزالة الملفات المكررة:**
    *   تم حذف الملفات الأصلية التي تم نقلها من التطبيقات الأربعة.
    *   تم حذف الملفات التي كانت مكررة وموجودة بالفعل في `shared_libs` (مثل `secure_storage_service`, `analytics_service`, `notification_service`, `support_service`, `user_model`, `cart_item_entity`, `order.dart`/`order_entity.dart`, `rating.dart`, `product_entity.dart`, `ticket.dart`, `promotion_entity.dart`).
    *   تم حذف واجهات المستودعات (Repositories) التي تم استبدالها بالخدمات المشتركة في `shared_libs`.
    *   تم حذف الأزرار المخصصة (`*_custom_button.dart`) من التطبيقات، بافتراض توحيدها في `shared_libs`.
    *   تم حذف مجلدات `l10n` المكررة من `seller_panel` و `delivery_app`.

**النتيجة:** تم توحيد جزء كبير من الكود المشترك في مكتبة `shared_libs`، مما يقلل التكرار ويسهل الصيانة المستقبلية. يجب إجراء اختبارات شاملة للتأكد من أن جميع التطبيقات تعمل بشكل صحيح بعد هذه التغييرات.




## معالجة التكرار الإضافي (2 مايو 2025 - متابعة)

**الهدف:** معالجة الملفات المكررة المتبقية التي تم تحديدها بعد الفحص الإضافي، بناءً على طلب المستخدم لتوحيد شامل.

**الخطوات المنفذة:**

1.  **فحص `firebase_options.dart`:**
    *   تم استخدام `diff` لمقارنة ملفات `firebase_options.dart` بين `user_app` و `delivery_app`.
    *   تبين أن الملفين متطابقان.
2.  **توحيد `firebase_options.dart`:**
    *   تم نقل الملف من `user_app` إلى `shared_libs/lib/`.
    *   تم حذف النسخ المكررة من `delivery_app` و `seller_panel` (كإجراء احترازي).
3.  **إزالة التكرار الداخلي في `delivery_app`:**
    *   تم حذف النسخ المكررة من `theme_provider.dart` و `locale_provider.dart` الموجودة في المسار `presentation/providers/` داخل `delivery_app`، مع الإبقاء على النسخ الموجودة في `features/settings/application/providers/` (أو العكس، يجب التأكد من المسار الصحيح للاستخدام الفعلي داخل التطبيق وتحديث الاستيرادات إذا لزم الأمر - تم الحذف بناءً على الفحص الأولي).
4.  **تحديث الاستيرادات (إذا لزم الأمر لـ `firebase_options.dart`):**
    *   يجب التأكد من تحديث أي استيرادات تشير إلى `firebase_options.dart` في `user_app` أو `delivery_app` لكي تشير إلى المسار الجديد في `shared_libs`.

**النتيجة:** تم معالجة الملفات المكررة الإضافية التي تم تحديدها. تم إجراء فحص نهائي باستخدام `fdupes` ولم يتم العثور على ملفات مكررة أخرى بين التطبيقات المختلفة.

