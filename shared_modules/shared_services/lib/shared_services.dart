library shared_services;

// Export service implementations
export 'src/services/auth_service.dart';
export 'src/services/authentication_repository.dart';
export 'src/services/category_service.dart';
export 'src/services/delivery_person_service.dart';
export 'src/services/order_service.dart';
export 'src/services/product_service.dart';
export 'src/services/secure_storage_service.dart';
export 'src/services/statistics_service.dart';
export 'src/services/store_service.dart';
export 'src/services/user_service.dart';

// Export providers
export 'src/services/auth_service.dart'
    show authServiceProvider; // Assuming it exists
// export 'src/services/authentication_repository.dart' show authenticationRepositoryProvider; // Define if needed
export 'src/services/category_service.dart' show categoryServiceProvider;
// export 'src/services/delivery_person_service.dart' show deliveryPersonServiceProvider; // Define if needed
export 'src/services/order_service.dart' show orderServiceProvider;
export 'src/services/product_service.dart' show productServiceProvider;
// export 'src/services/secure_storage_service.dart' show secureStorageServiceProvider; // Define if needed
export 'src/services/statistics_service.dart' show statisticsServiceProvider;
export 'src/services/store_service.dart' show storeServiceProvider;
export 'src/services/user_service.dart' show userServiceProvider;
