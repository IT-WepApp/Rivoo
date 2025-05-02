class AppConstants {
  // --- General App Settings ---
  static const String appName = 'RivooSy';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'support@rivoosyapp.com';
  static const String privacyPolicyUrl =
      'https://rivoosyapp.com/privacy-policy';
  static const String termsOfServiceUrl =
      'https://rivoosyapp.com/terms-of-service';

  // --- API Endpoints ---
  static const String baseUrl = 'https://api.rivoosyapp.com';
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/users';
  static const String productsEndpoint = '/products';
  static const String ordersEndpoint = '/orders';
  static const String categoriesEndpoint = '/categories';
  static const String notificationsEndpoint = '/notifications';

  // --- Authentication Settings ---
  static const int passwordMinLength = 8; // Default for user app
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 10;
  static const int sessionTimeoutMinutes = 60;
  static const int maxLoginAttempts = 5;

  // --- Secure Storage Keys (User App / General) ---
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String userNameKey = 'user_name';
  static const String userPhoneKey = 'user_phone';
  static const String userProfileImageKey = 'user_profile_image';
  static const String isLoggedInKey = 'is_logged_in';
  static const String fcmTokenKey = 'fcm_token';

  // --- Default Values ---
  static const int defaultPageSize = 10;
  static const String defaultCurrency = 'USD'; // Consider making this configurable
  static const String defaultLanguage = 'en'; // Consider making this configurable
  static const String defaultCountryCode = '+1'; // Consider making this configurable

  // --- Error Messages ---
  static const String networkErrorMessage =
      'Network error. Please check your internet connection.';
  static const String serverErrorMessage =
      'Server error. Please try again later.';
  static const String authErrorMessage =
      'Authentication error. Please login again.';
  static const String validationErrorMessage =
      'Please check your input and try again.';
  static const String unknownErrorMessage =
      'An unknown error occurred. Please try again.';

  // --- Seller Panel Specific Constants ---
  static const String sellerAppName = 'RivooSy Seller';
  static const String sellerAppVersion = '1.0.0';
  static const String sellerRole = 'seller';
  static const int sellerPasswordMinLength = 6;
  // Secure Storage Keys (Seller Panel)
  static const String sellerTokenKey = 'seller_auth_token';
  static const String sellerUserIdKey = 'seller_user_id';
  static const String sellerRefreshTokenKey = 'seller_refresh_token';
  // Firebase Collections (Consider moving if used elsewhere, e.g., admin)
  static const String sellersCollection = 'sellers';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String notificationsCollection = 'notifications'; // Naming conflict with API endpoint?
  // Order Statuses (Potentially shared with other apps)
  static const String orderStatusPending = 'pending';
  static const String orderStatusPreparing = 'preparing';
  static const String orderStatusDelivering = 'delivering';
  static const String orderStatusDelivered = 'delivered';
  static const String orderStatusCancelled = 'cancelled';
  // Notifications (Seller Specific)
  static const String sellerNotificationChannelId = 'seller_notifications';
  static const String sellerNotificationChannelName = 'Seller Notifications';
  static const String sellerNotificationChannelDescription =
      'Notifications for seller app';
  // Image Constraints (Seller Specific)
  static const int maxProductImages = 5;
  static const int maxImageSizeInMB = 5;
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp'
  ];
  static const String productImagesPath = 'products/images'; // Storage path
  // Statistics (Seller Specific)
  static const int defaultStatsDays = 30;
}

