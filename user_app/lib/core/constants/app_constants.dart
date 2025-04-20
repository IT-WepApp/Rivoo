class AppConstants {
  // Secure Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String userNameKey = 'user_name';
  static const String userPhoneKey = 'user_phone';
  static const String userProfileImageKey = 'user_profile_image';
  static const String isLoggedInKey = 'is_logged_in';
  static const String fcmTokenKey = 'fcm_token';
  
  // Authentication Settings
  static const int passwordMinLength = 8;
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 10;
  static const int sessionTimeoutMinutes = 60;
  static const int maxLoginAttempts = 5;
  
  // API Endpoints
  static const String baseUrl = 'https://api.rivoosyapp.com';
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/users';
  static const String productsEndpoint = '/products';
  static const String ordersEndpoint = '/orders';
  static const String categoriesEndpoint = '/categories';
  static const String notificationsEndpoint = '/notifications';
  
  // App Settings
  static const String appName = 'RivooSy';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'support@rivoosyapp.com';
  static const String privacyPolicyUrl = 'https://rivoosyapp.com/privacy-policy';
  static const String termsOfServiceUrl = 'https://rivoosyapp.com/terms-of-service';
  
  // Default Values
  static const int defaultPageSize = 10;
  static const String defaultCurrency = 'USD';
  static const String defaultLanguage = 'en';
  static const String defaultCountryCode = '+1';
  
  // Error Messages
  static const String networkErrorMessage = 'Network error. Please check your internet connection.';
  static const String serverErrorMessage = 'Server error. Please try again later.';
  static const String authErrorMessage = 'Authentication error. Please login again.';
  static const String validationErrorMessage = 'Please check your input and try again.';
  static const String unknownErrorMessage = 'An unknown error occurred. Please try again.';
}
