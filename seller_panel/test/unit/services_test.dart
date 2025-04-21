import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/product_service.dart';
import '../../../core/services/order_service.dart';
import '../../../core/services/notification_service.dart';

/// اختبارات وحدة للخدمات الأساسية في تطبيق البائع
class ServiceTests {
  // اختبار خدمة المصادقة
  static void testAuthService() {
    group('AuthService Tests', () {
      late MockAuthService mockAuthService;

      setUp(() {
        mockAuthService = MockAuthService();
      });

      test('Login with valid credentials should succeed', () async {
        // Arrange
        when(mockAuthService.login(
          email: 'seller@rivosy.com',
          password: 'Password123',
        )).thenAnswer((_) async => true);

        // Act
        final result = await mockAuthService.login(
          email: 'seller@rivosy.com',
          password: 'Password123',
        );

        // Assert
        expect(result, true);
        verify(mockAuthService.login(
          email: 'seller@rivosy.com',
          password: 'Password123',
        )).called(1);
      });

      test('Login with invalid credentials should fail', () async {
        // Arrange
        when(mockAuthService.login(
          email: 'seller@rivosy.com',
          password: 'WrongPassword',
        )).thenAnswer((_) async => false);

        // Act
        final result = await mockAuthService.login(
          email: 'seller@rivosy.com',
          password: 'WrongPassword',
        );

        // Assert
        expect(result, false);
        verify(mockAuthService.login(
          email: 'seller@rivosy.com',
          password: 'WrongPassword',
        )).called(1);
      });

      test('Register with valid data should succeed', () async {
        // Arrange
        when(mockAuthService.register(
          email: 'new_seller@rivosy.com',
          password: 'Password123',
          name: 'New Seller',
          phone: '0512345678',
        )).thenAnswer((_) async => true);

        // Act
        final result = await mockAuthService.register(
          email: 'new_seller@rivosy.com',
          password: 'Password123',
          name: 'New Seller',
          phone: '0512345678',
        );

        // Assert
        expect(result, true);
        verify(mockAuthService.register(
          email: 'new_seller@rivosy.com',
          password: 'Password123',
          name: 'New Seller',
          phone: '0512345678',
        )).called(1);
      });

      test('Logout should succeed', () async {
        // Arrange
        when(mockAuthService.logout()).thenAnswer((_) async => true);

        // Act
        final result = await mockAuthService.logout();

        // Assert
        expect(result, true);
        verify(mockAuthService.logout()).called(1);
      });
    });
  }

  // اختبار خدمة المنتجات
  static void testProductService() {
    group('ProductService Tests', () {
      late MockProductService mockProductService;

      setUp(() {
        mockProductService = MockProductService();
      });

      test('Get products should return list of products', () async {
        // Arrange
        final mockProducts = [
          {
            'id': '1',
            'name': 'منتج 1',
            'price': 100.0,
            'description': 'وصف المنتج 1',
            'category': 'فئة 1',
            'imageUrl': 'https://example.com/image1.jpg',
            'stock': 10,
          },
          {
            'id': '2',
            'name': 'منتج 2',
            'price': 200.0,
            'description': 'وصف المنتج 2',
            'category': 'فئة 2',
            'imageUrl': 'https://example.com/image2.jpg',
            'stock': 20,
          },
        ];

        when(mockProductService.getProducts())
            .thenAnswer((_) async => mockProducts);

        // Act
        final result = await mockProductService.getProducts();

        // Assert
        expect(result, mockProducts);
        expect(result.length, 2);
        verify(mockProductService.getProducts()).called(1);
      });

      test('Get product by ID should return correct product', () async {
        // Arrange
        final mockProduct = {
          'id': '1',
          'name': 'منتج 1',
          'price': 100.0,
          'description': 'وصف المنتج 1',
          'category': 'فئة 1',
          'imageUrl': 'https://example.com/image1.jpg',
          'stock': 10,
        };

        when(mockProductService.getProductById('1'))
            .thenAnswer((_) async => mockProduct);

        // Act
        final result = await mockProductService.getProductById('1');

        // Assert
        expect(result, mockProduct);
        verify(mockProductService.getProductById('1')).called(1);
      });

      test('Add product should succeed', () async {
        // Arrange
        final mockProduct = {
          'name': 'منتج جديد',
          'price': 150.0,
          'description': 'وصف المنتج الجديد',
          'category': 'فئة جديدة',
          'imageUrl': 'https://example.com/new_image.jpg',
          'stock': 15,
        };

        when(mockProductService.addProduct(mockProduct))
            .thenAnswer((_) async => '3');

        // Act
        final result = await mockProductService.addProduct(mockProduct);

        // Assert
        expect(result, '3');
        verify(mockProductService.addProduct(mockProduct)).called(1);
      });

      test('Update product should succeed', () async {
        // Arrange
        final mockProduct = {
          'id': '1',
          'name': 'منتج محدث',
          'price': 120.0,
          'description': 'وصف المنتج المحدث',
          'category': 'فئة محدثة',
          'imageUrl': 'https://example.com/updated_image.jpg',
          'stock': 12,
        };

        when(mockProductService.updateProduct('1', mockProduct))
            .thenAnswer((_) async => true);

        // Act
        final result = await mockProductService.updateProduct('1', mockProduct);

        // Assert
        expect(result, true);
        verify(mockProductService.updateProduct('1', mockProduct)).called(1);
      });

      test('Delete product should succeed', () async {
        // Arrange
        when(mockProductService.deleteProduct('1'))
            .thenAnswer((_) async => true);

        // Act
        final result = await mockProductService.deleteProduct('1');

        // Assert
        expect(result, true);
        verify(mockProductService.deleteProduct('1')).called(1);
      });
    });
  }

  // اختبار خدمة الطلبات
  static void testOrderService() {
    group('OrderService Tests', () {
      late MockOrderService mockOrderService;

      setUp(() {
        mockOrderService = MockOrderService();
      });

      test('Get orders should return list of orders', () async {
        // Arrange
        final mockOrders = [
          {
            'id': '1',
            'customerId': 'customer1',
            'customerName': 'عميل 1',
            'items': [
              {'productId': '1', 'quantity': 2, 'price': 100.0},
              {'productId': '2', 'quantity': 1, 'price': 200.0},
            ],
            'totalAmount': 400.0,
            'status': 'pending',
            'createdAt': '2023-04-15T10:30:00Z',
          },
          {
            'id': '2',
            'customerId': 'customer2',
            'customerName': 'عميل 2',
            'items': [
              {'productId': '3', 'quantity': 3, 'price': 150.0},
            ],
            'totalAmount': 450.0,
            'status': 'delivered',
            'createdAt': '2023-04-14T14:20:00Z',
          },
        ];

        when(mockOrderService.getOrders()).thenAnswer((_) async => mockOrders);

        // Act
        final result = await mockOrderService.getOrders();

        // Assert
        expect(result, mockOrders);
        expect(result.length, 2);
        verify(mockOrderService.getOrders()).called(1);
      });

      test('Get order by ID should return correct order', () async {
        // Arrange
        final mockOrder = {
          'id': '1',
          'customerId': 'customer1',
          'customerName': 'عميل 1',
          'items': [
            {'productId': '1', 'quantity': 2, 'price': 100.0},
            {'productId': '2', 'quantity': 1, 'price': 200.0},
          ],
          'totalAmount': 400.0,
          'status': 'pending',
          'createdAt': '2023-04-15T10:30:00Z',
        };

        when(mockOrderService.getOrderById('1'))
            .thenAnswer((_) async => mockOrder);

        // Act
        final result = await mockOrderService.getOrderById('1');

        // Assert
        expect(result, mockOrder);
        verify(mockOrderService.getOrderById('1')).called(1);
      });

      test('Update order status should succeed', () async {
        // Arrange
        when(mockOrderService.updateOrderStatus('1', 'processing'))
            .thenAnswer((_) async => true);

        // Act
        final result =
            await mockOrderService.updateOrderStatus('1', 'processing');

        // Assert
        expect(result, true);
        verify(mockOrderService.updateOrderStatus('1', 'processing')).called(1);
      });

      test('Get seller sales statistics should return statistics data',
          () async {
        // Arrange
        final mockStatistics = {
          'totalSales': 5000.0,
          'totalOrders': 25,
          'averageOrderValue': 200.0,
          'salesGrowth': 15.5,
        };

        when(mockOrderService.getSellerSalesStatistics(timeRange: 'week'))
            .thenAnswer((_) async => mockStatistics);

        // Act
        final result =
            await mockOrderService.getSellerSalesStatistics(timeRange: 'week');

        // Assert
        expect(result, mockStatistics);
        verify(mockOrderService.getSellerSalesStatistics(timeRange: 'week'))
            .called(1);
      });
    });
  }

  // اختبار خدمة الإشعارات
  static void testNotificationService() {
    group('NotificationService Tests', () {
      late MockNotificationService mockNotificationService;

      setUp(() {
        mockNotificationService = MockNotificationService();
      });

      test('Get notifications should return list of notifications', () async {
        // Arrange
        final mockNotifications = [
          {
            'id': '1',
            'title': 'طلب جديد',
            'body': 'لديك طلب جديد بقيمة 400 ريال',
            'type': 'order',
            'data': {'orderId': '1'},
            'read': false,
            'createdAt': '2023-04-15T10:35:00Z',
          },
          {
            'id': '2',
            'title': 'تقييم جديد',
            'body': 'حصل منتجك "منتج 1" على تقييم 5 نجوم',
            'type': 'rating',
            'data': {'productId': '1', 'rating': 5},
            'read': true,
            'createdAt': '2023-04-14T15:20:00Z',
          },
        ];

        when(mockNotificationService.getNotifications())
            .thenAnswer((_) async => mockNotifications);

        // Act
        final result = await mockNotificationService.getNotifications();

        // Assert
        expect(result, mockNotifications);
        expect(result.length, 2);
        verify(mockNotificationService.getNotifications()).called(1);
      });

      test('Mark notification as read should succeed', () async {
        // Arrange
        when(mockNotificationService.markAsRead('1'))
            .thenAnswer((_) async => true);

        // Act
        final result = await mockNotificationService.markAsRead('1');

        // Assert
        expect(result, true);
        verify(mockNotificationService.markAsRead('1')).called(1);
      });

      test('Delete notification should succeed', () async {
        // Arrange
        when(mockNotificationService.deleteNotification('1'))
            .thenAnswer((_) async => true);

        // Act
        final result = await mockNotificationService.deleteNotification('1');

        // Assert
        expect(result, true);
        verify(mockNotificationService.deleteNotification('1')).called(1);
      });

      test('Send FCM token should succeed', () async {
        // Arrange
        const mockToken = 'fcm_token_123';
        when(mockNotificationService.sendFCMToken(mockToken))
            .thenAnswer((_) async => true);

        // Act
        final result = await mockNotificationService.sendFCMToken(mockToken);

        // Assert
        expect(result, true);
        verify(mockNotificationService.sendFCMToken(mockToken)).called(1);
      });
    });
  }

  // تشغيل جميع الاختبارات
  static void runAllTests() {
    testAuthService();
    testProductService();
    testOrderService();
    testNotificationService();
  }
}

// Mock Classes
class MockAuthService extends Mock implements AuthService {}

class MockProductService extends Mock implements ProductService {}

class MockOrderService extends Mock implements OrderService {}

class MockNotificationService extends Mock implements NotificationService {}
