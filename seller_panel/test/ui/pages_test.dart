import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import '../../../features/dashboard/presentation/pages/seller_dashboard_page.dart';
import '../../../features/products/presentation/pages/products_management_page.dart';
import '../../../features/orders/presentation/pages/orders_management_page.dart';
import '../../../features/statistics/presentation/pages/statistics_page.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/product_service.dart';
import '../../../core/services/order_service.dart';

/// اختبارات واجهة المستخدم للصفحات الرئيسية في تطبيق البائع
class UITests {
  // اختبار صفحة لوحة التحكم
  static void testDashboardPage() {
    group('SellerDashboardPage UI Tests', () {
      testWidgets('Dashboard page should display all required widgets', (WidgetTester tester) async {
        // Arrange
        final mockAuthService = MockAuthService();
        final mockOrderService = MockOrderService();
        
        when(mockAuthService.getCurrentUser()).thenAnswer((_) async => {
          'id': 'seller1',
          'name': 'محمد أحمد',
          'email': 'seller@rivosy.com',
        });
        
        when(mockOrderService.getRecentOrders()).thenAnswer((_) async => [
          {
            'id': '1',
            'customerName': 'عميل 1',
            'totalAmount': 400.0,
            'status': 'pending',
            'createdAt': '2023-04-15T10:30:00Z',
          },
          {
            'id': '2',
            'customerName': 'عميل 2',
            'totalAmount': 450.0,
            'status': 'processing',
            'createdAt': '2023-04-14T14:20:00Z',
          },
        ]);
        
        when(mockOrderService.getSellerSummary()).thenAnswer((_) async => {
          'totalSales': 5000.0,
          'totalOrders': 25,
          'pendingOrders': 5,
          'lowStockProducts': 3,
        });
        
        // Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authServiceProvider.overrideWithValue(mockAuthService),
              orderServiceProvider.overrideWithValue(mockOrderService),
            ],
            child: const MaterialApp(
              home: SellerDashboardPage(),
            ),
          ),
        );
        
        // Wait for async operations
        await tester.pumpAndSettle();
        
        // Assert
        expect(find.text('لوحة التحكم'), findsOneWidget);
        expect(find.text('مرحباً، محمد أحمد'), findsOneWidget);
        expect(find.text('ملخص المتجر'), findsOneWidget);
        expect(find.text('الطلبات الأخيرة'), findsOneWidget);
        expect(find.text('إجمالي المبيعات'), findsOneWidget);
        expect(find.text('5000.0 ر.س'), findsOneWidget);
        expect(find.text('عدد الطلبات'), findsOneWidget);
        expect(find.text('25'), findsOneWidget);
        expect(find.text('طلبات قيد الانتظار'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
        expect(find.text('منتجات منخفضة المخزون'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('عميل 1'), findsOneWidget);
        expect(find.text('عميل 2'), findsOneWidget);
        expect(find.text('400.0 ر.س'), findsOneWidget);
        expect(find.text('450.0 ر.س'), findsOneWidget);
        expect(find.text('قيد الانتظار'), findsOneWidget);
        expect(find.text('قيد المعالجة'), findsOneWidget);
      });
    });
  }
  
  // اختبار صفحة إدارة المنتجات
  static void testProductsManagementPage() {
    group('ProductsManagementPage UI Tests', () {
      testWidgets('Products management page should display all required widgets', (WidgetTester tester) async {
        // Arrange
        final mockProductService = MockProductService();
        
        when(mockProductService.getProducts()).thenAnswer((_) async => [
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
        ]);
        
        when(mockProductService.getCategories()).thenAnswer((_) async => [
          'فئة 1',
          'فئة 2',
          'فئة 3',
        ]);
        
        // Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              productServiceProvider.overrideWithValue(mockProductService),
            ],
            child: const MaterialApp(
              home: ProductsManagementPage(),
            ),
          ),
        );
        
        // Wait for async operations
        await tester.pumpAndSettle();
        
        // Assert
        expect(find.text('إدارة المنتجات'), findsOneWidget);
        expect(find.text('منتج 1'), findsOneWidget);
        expect(find.text('منتج 2'), findsOneWidget);
        expect(find.text('100.0 ر.س'), findsOneWidget);
        expect(find.text('200.0 ر.س'), findsOneWidget);
        expect(find.text('المخزون: 10'), findsOneWidget);
        expect(find.text('المخزون: 20'), findsOneWidget);
        expect(find.text('فئة 1'), findsOneWidget);
        expect(find.text('فئة 2'), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
        expect(find.byIcon(Icons.filter_list), findsOneWidget);
      });
    });
  }
  
  // اختبار صفحة إدارة الطلبات
  static void testOrdersManagementPage() {
    group('OrdersManagementPage UI Tests', () {
      testWidgets('Orders management page should display all required widgets', (WidgetTester tester) async {
        // Arrange
        final mockOrderService = MockOrderService();
        
        when(mockOrderService.getOrders()).thenAnswer((_) async => [
          {
            'id': '1',
            'customerId': 'customer1',
            'customerName': 'عميل 1',
            'items': [
              {'productId': '1', 'productName': 'منتج 1', 'quantity': 2, 'price': 100.0},
              {'productId': '2', 'productName': 'منتج 2', 'quantity': 1, 'price': 200.0},
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
              {'productId': '3', 'productName': 'منتج 3', 'quantity': 3, 'price': 150.0},
            ],
            'totalAmount': 450.0,
            'status': 'delivered',
            'createdAt': '2023-04-14T14:20:00Z',
          },
        ]);
        
        // Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              orderServiceProvider.overrideWithValue(mockOrderService),
            ],
            child: const MaterialApp(
              home: OrdersManagementPage(),
            ),
          ),
        );
        
        // Wait for async operations
        await tester.pumpAndSettle();
        
        // Assert
        expect(find.text('إدارة الطلبات'), findsOneWidget);
        expect(find.text('عميل 1'), findsOneWidget);
        expect(find.text('عميل 2'), findsOneWidget);
        expect(find.text('400.0 ر.س'), findsOneWidget);
        expect(find.text('450.0 ر.س'), findsOneWidget);
        expect(find.text('قيد الانتظار'), findsOneWidget);
        expect(find.text('تم التسليم'), findsOneWidget);
        expect(find.byIcon(Icons.filter_list), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
      });
    });
  }
  
  // اختبار صفحة الإحصائيات
  static void testStatisticsPage() {
    group('StatisticsPage UI Tests', () {
      testWidgets('Statistics page should display all required widgets', (WidgetTester tester) async {
        // Arrange
        final mockOrderService = MockOrderService();
        
        when(mockOrderService.getSellerSalesStatistics(timeRange: 'week')).thenAnswer((_) async => {
          'totalSales': 5000.0,
          'totalOrders': 25,
          'averageOrderValue': 200.0,
          'salesGrowth': 15.5,
          'salesByDay': [
            {'day': 'الأحد', 'sales': 800.0},
            {'day': 'الاثنين', 'sales': 650.0},
            {'day': 'الثلاثاء', 'sales': 900.0},
            {'day': 'الأربعاء', 'sales': 750.0},
            {'day': 'الخميس', 'sales': 1100.0},
            {'day': 'الجمعة', 'sales': 500.0},
            {'day': 'السبت', 'sales': 300.0},
          ],
          'salesByCategory': [
            {'category': 'فئة 1', 'sales': 2000.0, 'percentage': 40.0},
            {'category': 'فئة 2', 'sales': 1500.0, 'percentage': 30.0},
            {'category': 'فئة 3', 'sales': 1000.0, 'percentage': 20.0},
            {'category': 'فئة 4', 'sales': 500.0, 'percentage': 10.0},
          ],
        });
        
        when(mockOrderService.getSellerProductsStatistics(timeRange: 'week')).thenAnswer((_) async => {
          'totalProducts': 48,
          'outOfStockProducts': 3,
          'lowStockProducts': 5,
          'topSellingProducts': [
            {'id': '1', 'name': 'منتج 1', 'sales': 1200.0, 'quantity': 12, 'stock': 8},
            {'id': '2', 'name': 'منتج 2', 'sales': 900.0, 'quantity': 9, 'stock': 15},
            {'id': '3', 'name': 'منتج 3', 'sales': 800.0, 'quantity': 8, 'stock': 4},
          ],
        });
        
        when(mockOrderService.getSellerCustomersStatistics(timeRange: 'week')).thenAnswer((_) async => {
          'totalCustomers': 35,
          'newCustomers': 8,
          'returningCustomers': 27,
          'customerRetentionRate': 77.1,
          'topCustomers': [
            {'name': 'عميل 1', 'email': 'customer1@example.com', 'totalSpent': 1500.0, 'ordersCount': 5},
            {'name': 'عميل 2', 'email': 'customer2@example.com', 'totalSpent': 1200.0, 'ordersCount': 4},
            {'name': 'عميل 3', 'email': 'customer3@example.com', 'totalSpent': 900.0, 'ordersCount': 3},
          ],
        });
        
        // Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              orderServiceProvider.overrideWithValue(mockOrderService),
            ],
            child: const MaterialApp(
              home: StatisticsPage(),
            ),
          ),
        );
        
        // Wait for async operations
        await tester.pumpAndSettle();
        
        // Assert
        expect(find.text('الإحصائيات والتحليلات'), findsOneWidget);
        expect(find.text('المبيعات'), findsOneWidget);
        expect(find.text('المنتجات'), findsOneWidget);
        expect(find.text('العملاء'), findsOneWidget);
        expect(find.text('يوم'), findsOneWidget);
        expect(find.text('أسبوع'), findsOneWidget);
        expect(find.text('شهر'), findsOneWidget);
        expect(find.text('سنة'), findsOneWidget);
        expect(find.text('إجمالي المبيعات'), findsOneWidget);
        expect(find.text('5000.0 ر.س'), findsOneWidget);
        expect(find.text('عدد الطلبات'), findsOneWidget);
        expect(find.text('25'), findsOneWidget);
        expect(find.text('متوسط قيمة الطلب'), findsOneWidget);
        expect(find.text('200.0 ر.س'), findsOneWidget);
        expect(find.text('نمو المبيعات'), findsOneWidget);
        expect(find.text('+15.5%'), findsOneWidget);
        expect(find.text('المبيعات حسب اليوم'), findsOneWidget);
        expect(find.text('المبيعات حسب الفئة'), findsOneWidget);
      });
    });
  }
  
  // تشغيل جميع اختبارات واجهة المستخدم
  static void runAllUITests() {
    testDashboardPage();
    testProductsManagementPage();
    testOrdersManagementPage();
    testStatisticsPage();
  }
}

// Mock Classes
class MockAuthService extends Mock implements AuthService {}
class MockProductService extends Mock implements ProductService {}
class MockOrderService extends Mock implements OrderService {}
