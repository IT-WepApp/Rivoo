class RouteConstants {
  // Auth Routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyEmail = '/verify-email';
  static const String resetPassword = '/reset-password';
  
  // Main Routes
  static const String home = '/';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  
  // Product Routes
  static const String products = '/products';
  static const String productDetails = '/products/:id';
  static const String productSearch = '/products/search';
  static const String productCategories = '/products/categories';
  static const String productCategory = '/products/categories/:id';
  static const String favorites = '/favorites';
  
  // Cart Routes
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String paymentMethods = '/payment-methods';
  static const String addPaymentMethod = '/payment-methods/add';
  
  // Order Routes
  static const String orders = '/orders';
  static const String orderDetails = '/orders/:id';
  static const String orderTracking = '/orders/:id/tracking';
  
  // Address Routes
  static const String addresses = '/addresses';
  static const String addAddress = '/addresses/add';
  static const String editAddress = '/addresses/:id/edit';
  
  // Rating Routes
  static const String ratings = '/ratings';
  static const String addRating = '/ratings/add';
  
  // Other Routes
  static const String about = '/about';
  static const String help = '/help';
  static const String termsOfService = '/terms-of-service';
  static const String privacyPolicy = '/privacy-policy';
  static const String contactUs = '/contact-us';
}
