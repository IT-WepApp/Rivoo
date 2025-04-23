/// ثوابت المسارات في التطبيق
///
/// يحتوي هذا الملف على جميع ثوابت المسارات المستخدمة في التطبيق
/// لتسهيل إدارة التنقل وتجنب الأخطاء الإملائية

class RouteConstants {
  // منع إنشاء نسخة من الفئة
  RouteConstants._();

  // المسارات الرئيسية
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyOtp = '/verify-otp';
  static const String verifyEmail = '/verify-email';
  static const String resetPassword = '/reset-password';
  
  // المسارات الرئيسية بعد تسجيل الدخول
  static const String home = '/home';
  static const String categories = '/categories';
  static const String cart = '/cart';
  static const String profile = '/profile';
  
  // مسارات المنتجات
  static const String products = '/products';
  static const String productDetails = '/product-details';
  static const String productSearch = '/product-search';
  static const String productFilter = '/product-filter';
  static const String productList = '/products';
  
  // مسارات الطلبات
  static const String orders = '/orders';
  static const String orderDetails = '/order-details';
  static const String orderTracking = '/order-tracking';
  static const String orderHistory = '/order-history';
  
  // مسارات الدفع
  static const String checkout = '/checkout';
  static const String payment = '/payment';
  static const String paymentSuccess = '/payment-success';
  static const String paymentFailed = '/payment-failed';
  
  // مسارات المستخدم
  static const String editProfile = '/edit-profile';
  static const String addresses = '/addresses';
  static const String addAddress = '/add-address';
  static const String editAddress = '/edit-address';
  static const String favorites = '/favorites';
  static const String shippingAddresses = '/shipping-addresses';
  static const String addShippingAddress = '/shipping-address/add';
  static const String editShippingAddress = '/shipping-address/edit';
  
  // مسارات أخرى
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String help = '/help';
  static const String termsAndConditions = '/terms-and-conditions';
  static const String privacyPolicy = '/privacy-policy';
  static const String contactUs = '/contact-us';
  static const String faq = '/faq';
  static const String ratings = '/ratings';
  static const String addRating = '/add-rating';
  
  // مسارات المتجر
  static const String store = '/store';
  static const String storeDetails = '/store-details';
  static const String storeProducts = '/store-products';
  static const String storeReviews = '/store-reviews';
}
