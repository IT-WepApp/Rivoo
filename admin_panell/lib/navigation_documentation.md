# توثيق نظام التنقل في لوحة تحكم المسؤول (admin_panell)

## نظرة عامة

تم تصميم وتنفيذ نظام تنقل مخصص للإدارة في تطبيق admin_panell، يربط الصفحات التالية عبر Navigator:
- AdminLoginPage (صفحة تسجيل الدخول)
- AdminHomePage (الصفحة الرئيسية)
- CategoryManagementPage (صفحة إدارة الفئات)
- OrderListPage (صفحة قائمة الطلبات)
- ProductListPage (صفحة قائمة المنتجات)
- StoreListPage (صفحة قائمة المتاجر)
- UserListPage (صفحة قائمة المستخدمين)
- StatisticsAndReportsPage (صفحة الإحصائيات والتقارير)

تم استخدام GoRouter لتنفيذ نظام التنقل، مع تطبيق حماية المسارات (AuthGuard) بحيث تكون جميع الصفحات محمية ما عدا صفحة تسجيل الدخول.

## الملفات الرئيسية

1. **admin_router.dart**: يحتوي على تعريف جميع المسارات وآلية التوجيه (redirect).
2. **auth_provider.dart**: يوفر مزودات حالة المصادقة باستخدام Riverpod.
3. **admin_drawer.dart**: يوفر قائمة تنقل جانبية للوصول إلى جميع الصفحات.

## المسارات المعرفة

تم تعريف المسارات التالية في ملف `admin_router.dart`:

```dart
class AdminRoutes {
  static const String login = '/';
  static const String adminHome = '/adminHome';
  static const String categoryManagement = '/categoryManagement';
  static const String productManagement = '/productManagement';
  static const String orderManagement = '/orderManagement';
  static const String userManagement = '/userManagement';
  static const String storeManagement = '/storeManagement';
  static const String statistics = '/statistics';
}
```

## آلية حماية المسارات

تم تنفيذ آلية حماية المسارات (AuthGuard) من خلال دالة `redirect` في GoRouter:

```dart
redirect: (context, state) {
  // الحصول على حالة المصادقة الحالية
  final isLoggedIn = authState.status == AuthStatus.authenticated;
  final isLoggingIn = state.matchedLocation == AdminRoutes.login;
  
  // إذا لم يكن المستخدم مسجل الدخول ولم يكن في صفحة تسجيل الدخول
  if (!isLoggedIn && !isLoggingIn) {
    return AdminRoutes.login;
  }
  
  // إذا كان المستخدم مسجل الدخول وكان في صفحة تسجيل الدخول
  if (isLoggedIn && isLoggingIn) {
    return AdminRoutes.adminHome;
  }
  
  // السماح بالتنقل
  return null;
}
```

## إدارة حالة المصادقة

تم استخدام Riverpod لإدارة حالة المصادقة من خلال مزودات معرفة في ملف `auth_provider.dart`:

```dart
/// مزود حالة المصادقة
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// مزود حالة المصادقة (للاستماع فقط)
final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authProvider);
});

/// مزود حالة تسجيل الدخول
final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.status == AuthStatus.authenticated;
});
```

## قائمة التنقل الجانبية

تم تنفيذ قائمة تنقل جانبية (AdminDrawer) توفر وصولاً سهلاً إلى جميع الصفحات المطلوبة. يتم إضافة هذه القائمة إلى جميع صفحات لوحة التحكم (ما عدا صفحة تسجيل الدخول).

## الصفحة الرئيسية

تم تنفيذ الصفحة الرئيسية (AdminHomePage) بحيث توفر أزرار وصول سريع إلى جميع الصفحات المطلوبة، مما يسهل التنقل بين الصفحات.

## كيفية استخدام نظام التنقل

### التنقل بين الصفحات

يمكن استخدام الأساليب التالية للتنقل بين الصفحات:

1. **استخدام context.go**:
   ```dart
   context.go(AdminRoutes.categoryManagement);
   ```

2. **استخدام context.push**:
   ```dart
   context.push(AdminRoutes.productManagement);
   ```

### إضافة معلمات للمسارات

يمكن إضافة معلمات للمسارات عند الحاجة:

```dart
context.go('${AdminRoutes.productManagement}?id=$productId');
```

### الوصول إلى المعلمات

يمكن الوصول إلى المعلمات في الصفحة المستهدفة:

```dart
final productId = GoRouterState.of(context).queryParameters['id'];
```

## ملاحظات هامة

1. يجب التأكد من استخدام `context.go` أو `context.push` بدلاً من `Navigator.push` التقليدي.
2. يجب استخدام ثوابت المسارات المعرفة في `AdminRoutes` عند التنقل بين الصفحات.
3. يجب إضافة `AdminDrawer` إلى جميع صفحات لوحة التحكم (ما عدا صفحة تسجيل الدخول).
