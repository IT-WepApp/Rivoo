/// ثوابت تطبيق لوحة الإدارة
class AdminConstants {
  /// عنوان التطبيق الرئيسي
  static const String appTitle = 'لوحة الإدارة';
  
  /// ثوابت المسارات
  static const String dashboardRoute = '/dashboard';
  static const String usersRoute = '/users';
  static const String productsRoute = '/products';
  static const String ordersRoute = '/orders';
  static const String settingsRoute = '/settings';
  
  /// ثوابت API
  static const String apiBaseUrl = 'https://api.rivoosy.com/admin';
  static const int apiTimeoutSeconds = 30;
  
  /// ثوابت التخزين
  static const String tokenKey = 'admin_auth_token';
  static const String userDataKey = 'admin_user_data';
  
  /// ثوابت الجلسة
  static const int sessionTimeoutMinutes = 30;
  static const bool enableAutoLogout = true;
  
  // منع إنشاء نسخة من الفئة
  AdminConstants._();
}
