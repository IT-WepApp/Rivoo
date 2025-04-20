/// ثوابت التطبيق المستخدمة في جميع أنحاء التطبيق
///
/// يحتوي هذا الملف على جميع الثوابت المستخدمة في التطبيق
/// لتسهيل الصيانة وتجنب الأخطاء الناتجة عن استخدام القيم المباشرة
class AppConstants {
  // ثوابت التخزين
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userDataKey = 'user_data';
  static const String isDarkModeKey = 'is_dark_mode';
  static const String languageCodeKey = 'language_code';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String cartItemsKey = 'cart_items';
  static const String favoriteItemsKey = 'favorite_items';
  
  // ثوابت الشبكة
  static const int connectionTimeout = 30000; // 30 ثانية
  static const int receiveTimeout = 30000; // 30 ثانية
  static const int maxRetryAttempts = 3;
  
  // ثوابت المصادقة
  static const int otpExpiryMinutes = 5;
  static const int minimumPasswordLength = 8;
  static const int sessionTimeoutMinutes = 60; // 60 دقيقة
  
  // ثوابت واجهة المستخدم
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultButtonHeight = 48.0;
  static const double defaultIconSize = 24.0;
  static const double defaultAnimationDuration = 300.0; // 300 مللي ثانية
  
  // ثوابت الصور
  static const String placeholderImagePath = 'assets/images/placeholder.png';
  static const String logoPath = 'assets/images/logo.png';
  static const String userPlaceholderPath = 'assets/images/user_placeholder.png';
  
  // ثوابت الطلبات
  static const int maxItemsPerOrder = 50;
  static const double minimumOrderAmount = 10.0;
  static const double deliveryFee = 5.0;
  static const double freeDeliveryThreshold = 50.0;
  
  // ثوابت التقييم
  static const int maxRating = 5;
  static const int minReviewLength = 10;
  static const int maxReviewLength = 500;
  
  // ثوابت الإشعارات
  static const String notificationChannelId = 'rivoosyapp_channel';
  static const String notificationChannelName = 'RivooSy Notifications';
  static const String notificationChannelDescription = 'Receive notifications from RivooSy';
  
  // ثوابت الخريطة
  static const double defaultZoomLevel = 15.0;
  static const double defaultLatitude = 24.7136; // الرياض
  static const double defaultLongitude = 46.6753; // الرياض
  static const int locationUpdateIntervalSeconds = 5;
}
