/// ثوابت المسارات المستخدمة في تطبيق لوحة تحكم البائع
class RouteConstants {
  // المسارات الرئيسية
  static const String login = '/';
  static const String register = '/register';
  static const String forgotPassword = '/forgotPassword';
  static const String verifyEmail = '/verifyEmail';
  static const String home = '/sellerHome';

  // مسارات المنتجات
  static const String products = '/sellerHome/sellerProducts';
  static const String addProduct = '/sellerHome/addProduct';
  static const String editProduct = '/sellerHome/editProduct';

  // مسارات الطلبات
  static const String orders = '/sellerHome/sellerOrders';
  static const String orderDetails = '/sellerHome/sellerOrderDetails';

  // مسارات العروض
  static const String promotions = '/sellerHome/sellerPromotions';

  // مسارات الإحصائيات
  static const String statistics = '/sellerHome/sellerStats';

  // مسارات الملف الشخصي
  static const String profile = '/sellerHome/sellerProfile';

  // مسارات الإشعارات
  static const String notifications = '/sellerHome/sellerNotifications';

  // مسارات الدردشة
  static const String chat = '/sellerHome/sellerChat';
  static const String chatDetails = '/sellerHome/sellerChatDetails';
}
