/// ثوابت المسارات المستخدمة في التطبيق
///
/// يحتوي هذا الملف على جميع مسارات التنقل المستخدمة في التطبيق
/// لتسهيل الصيانة وتجنب الأخطاء الناتجة عن استخدام النصوص المباشرة
class RouteConstants {
  // مسارات المصادقة
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyEmail = '/verify-email';
  
  // المسارات الرئيسية
  static const String home = '/home';
  static const String profile = '/profile';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String paymentMethods = '/payment-methods';
  
  // مسارات الطلبات
  static const String orders = '/orders';
  static const String orderDetails = '/orders/:orderId';
  static const String orderTracking = '/orders/:orderId/tracking';
  
  // مسارات المنتجات
  static const String productDetails = '/products/:productId';
  static const String productReviews = '/products/:productId/reviews';
  static const String favorites = '/favorites';
  static const String categories = '/categories';
  static const String categoryProducts = '/categories/:categoryId';
  static const String search = '/search';
  
  // مسارات العنوان
  static const String addresses = '/addresses';
  static const String addAddress = '/addresses/add';
  static const String editAddress = '/addresses/:addressId/edit';
  
  // مسارات أخرى
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String help = '/help';
  static const String termsAndConditions = '/terms-and-conditions';
  static const String privacyPolicy = '/privacy-policy';
  
  // استبدال معرف في المسار
  static String orderDetailsPath(String orderId) => orderDetails.replaceAll(':orderId', orderId);
  static String orderTrackingPath(String orderId) => orderTracking.replaceAll(':orderId', orderId);
  static String productDetailsPath(String productId) => productDetails.replaceAll(':productId', productId);
  static String productReviewsPath(String productId) => productReviews.replaceAll(':productId', productId);
  static String categoryProductsPath(String categoryId) => categoryProducts.replaceAll(':categoryId', categoryId);
  static String editAddressPath(String addressId) => editAddress.replaceAll(':addressId', addressId);
}
