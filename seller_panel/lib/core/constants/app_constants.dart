/// تعريف الثوابت المستخدمة في تطبيق لوحة تحكم البائع
class AppConstants {
  // ثوابت المصادقة
  static const String sellerRole = 'seller';
  static const int minPasswordLength = 6;
  
  // ثوابت التخزين الآمن
  static const String tokenKey = 'seller_auth_token';
  static const String userIdKey = 'seller_user_id';
  static const String refreshTokenKey = 'seller_refresh_token';
  
  // ثوابت Firebase
  static const String sellersCollection = 'sellers';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String notificationsCollection = 'notifications';
  
  // ثوابت حالة الطلب
  static const String orderStatusPending = 'pending';
  static const String orderStatusPreparing = 'preparing';
  static const String orderStatusDelivering = 'delivering';
  static const String orderStatusDelivered = 'delivered';
  static const String orderStatusCancelled = 'cancelled';
  
  // ثوابت الإشعارات
  static const String notificationChannelId = 'seller_notifications';
  static const String notificationChannelName = 'Seller Notifications';
  static const String notificationChannelDescription = 'Notifications for seller app';
  
  // ثوابت الصور
  static const int maxProductImages = 5;
  static const int maxImageSizeInMB = 5;
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  
  // ثوابت الإحصائيات
  static const int defaultStatsDays = 30;
  
  // ثوابت التطبيق
  static const String appName = 'RivooSy Seller';
  static const String appVersion = '1.0.0';
}
