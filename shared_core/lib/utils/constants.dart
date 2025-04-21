// ثوابت التطبيق المشتركة

/// ثوابت واجهة المستخدم
class UIConstants {
  // المسافات
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  
  // نصف قطر الزوايا
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  
  // أحجام الخط
  static const double fontSizeXS = 12.0;
  static const double fontSizeS = 14.0;
  static const double fontSizeM = 16.0;
  static const double fontSizeL = 18.0;
  static const double fontSizeXL = 20.0;
  static const double fontSizeXXL = 24.0;
  
  // سماكة الخط
  static const int fontWeightLight = 300;
  static const int fontWeightRegular = 400;
  static const int fontWeightMedium = 500;
  static const int fontWeightSemiBold = 600;
  static const int fontWeightBold = 700;
  
  // أحجام الأيقونات
  static const double iconSizeXS = 16.0;
  static const double iconSizeS = 20.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 40.0;
  
  // ارتفاعات الأزرار
  static const double buttonHeightS = 36.0;
  static const double buttonHeightM = 44.0;
  static const double buttonHeightL = 52.0;
  
  // مدة الرسوم المتحركة
  static const int animationDurationFast = 150;
  static const int animationDurationMedium = 300;
  static const int animationDurationSlow = 500;
}

/// ثوابت الشبكة
class NetworkConstants {
  // عناوين API
  static const String baseUrl = 'https://api.rivoosy.com';
  static const String authEndpoint = '/auth';
  static const String productsEndpoint = '/products';
  static const String ordersEndpoint = '/orders';
  static const String usersEndpoint = '/users';
  static const String categoriesEndpoint = '/categories';
  static const String reviewsEndpoint = '/reviews';
  static const String notificationsEndpoint = '/notifications';
  
  // مهل الانتظار
  static const int connectionTimeout = 30000; // بالميلي ثانية
  static const int receiveTimeout = 30000; // بالميلي ثانية
  
  // رؤوس الطلبات
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // رموز الاستجابة
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusServerError = 500;
}

/// ثوابت التخزين
class StorageConstants {
  // مفاتيح التخزين الآمن
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  
  // مفاتيح التخزين المشترك
  static const String keyLanguage = 'language';
  static const String keyThemeMode = 'theme_mode';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyLastSyncTime = 'last_sync_time';
  
  // مجلدات التخزين
  static const String userAvatarsFolder = 'user_avatars';
  static const String productImagesFolder = 'product_images';
  static const String categoryImagesFolder = 'category_images';
  static const String receiptImagesFolder = 'receipt_images';
}

/// ثوابت المصادقة
class AuthConstants {
  // أدوار المستخدمين
  static const String roleAdmin = 'admin';
  static const String roleSeller = 'seller';
  static const String roleDelivery = 'delivery';
  static const String roleUser = 'user';
  
  // مدة صلاحية الرموز
  static const int accessTokenExpiry = 3600; // بالثواني (ساعة واحدة)
  static const int refreshTokenExpiry = 2592000; // بالثواني (30 يوم)
  
  // متطلبات كلمة المرور
  static const int passwordMinLength = 8;
  static const bool passwordRequireUppercase = true;
  static const bool passwordRequireLowercase = true;
  static const bool passwordRequireDigit = true;
  static const bool passwordRequireSpecialChar = true;
}

/// ثوابت التطبيق
class AppConstants {
  // معلومات التطبيق
  static const String appName = 'RivooSy';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String appPackageName = 'com.rivoosy.app';
  
  // اللغات المدعومة
  static const List<String> supportedLocales = ['ar', 'en', 'fr', 'tr', 'nb'];
  static const String defaultLocale = 'ar';
  
  // الإعدادات الافتراضية
  static const bool defaultDarkMode = false;
  static const bool defaultNotificationsEnabled = true;
  
  // حدود التطبيق
  static const int maxProductImages = 5;
  static const int maxReviewLength = 500;
  static const int maxAddressesPerUser = 5;
  static const int maxItemsPerOrder = 20;
  static const double minOrderAmount = 10.0;
}
