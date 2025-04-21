/// ثوابت المسارات المستخدمة في التطبيق
class RouteConstants {
  // المسارات الرئيسية
  static const String dashboard = '/dashboard';
  static const String products = '/products';
  static const String orders = '/orders';
  static const String customers = '/customers';
  static const String statistics = '/statistics';
  static const String performance = '/performance';
  static const String settings = '/settings';
  static const String profile = '/profile';
  
  // مسارات المنتجات
  static const String productDetails = '/products/:id';
  static const String addProduct = '/products/add';
  static const String editProduct = '/products/edit/:id';
  
  // مسارات الطلبات
  static const String orderDetails = '/orders/:id';
  
  // مسارات العملاء
  static const String customerDetails = '/customers/:id';
  
  // مسارات المصادقة
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
}
