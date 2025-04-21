import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:user_app/core/architecture/domain/failure.dart';
import 'package:user_app/features/orders/domain/entities/order.dart';
import 'package:user_app/features/orders/domain/repositories/order_repository.dart';
import 'package:user_app/features/orders/domain/usecases/order_usecases.dart';

@GenerateMocks([OrderRepository])
import 'order_usecases_test.mocks.dart';

void main() {
  late MockOrderRepository mockRepository;
  late GetOrdersUseCase getOrdersUseCase;
  late GetOrderDetailsUseCase getOrderDetailsUseCase;
  late CreateOrderUseCase createOrderUseCase;
  late CancelOrderUseCase cancelOrderUseCase;

  setUp(() {
    mockRepository = MockOrderRepository();
    getOrdersUseCase = GetOrdersUseCase(mockRepository);
    getOrderDetailsUseCase = GetOrderDetailsUseCase(mockRepository);
    createOrderUseCase = CreateOrderUseCase(mockRepository);
    cancelOrderUseCase = CancelOrderUseCase(mockRepository);
  });

  group('GetOrdersUseCase', () {
    final orders = [
      Order(
        id: 'order1',
        userId: 'user1',
        items: [
          const OrderItem(
            productId: 'product1',
            productName: 'Product 1',
            price: 100.0,
            quantity: 2,
            imageUrl: 'https://example.com/image1.jpg',
          ),
        ],
        totalAmount: 200.0,
        status: OrderStatus.processing,
        orderDate: DateTime.now(),
        shippingAddress: ShippingAddress(
          fullName: 'John Doe',
          street: '123 Main St',
          city: 'New York',
          state: 'NY',
          zipCode: '10001',
          country: 'USA',
          phoneNumber: '+1234567890',
        ),
      ),
      Order(
        id: 'order2',
        userId: 'user1',
        items: [
          const OrderItem(
            productId: 'product2',
            productName: 'Product 2',
            price: 150.0,
            quantity: 1,
            imageUrl: 'https://example.com/image2.jpg',
          ),
        ],
        totalAmount: 150.0,
        status: OrderStatus.delivered,
        orderDate: DateTime.now().subtract(const Duration(days: 5)),
        shippingAddress: ShippingAddress(
          fullName: 'John Doe',
          street: '123 Main St',
          city: 'New York',
          state: 'NY',
          zipCode: '10001',
          country: 'USA',
          phoneNumber: '+1234567890',
        ),
      ),
    ];

    test('should get orders from repository', () async {
      // Arrange
      when(mockRepository.getOrders()).thenAnswer((_) async => Right(orders));

      // Act
      final result = await getOrdersUseCase(NoParams());

      // Assert
      expect(result, Right(orders));
      verify(mockRepository.getOrders()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = ServerFailure(message: 'Server error');
      when(mockRepository.getOrders())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await getOrdersUseCase(NoParams());

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.getOrders()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('GetOrderDetailsUseCase', () {
    const orderId = 'order1';
    final order = Order(
      id: orderId,
      userId: 'user1',
      items: [
        const OrderItem(
          productId: 'product1',
          productName: 'Product 1',
          price: 100.0,
          quantity: 2,
          imageUrl: 'https://example.com/image1.jpg',
        ),
      ],
      totalAmount: 200.0,
      status: OrderStatus.processing,
      orderDate: DateTime.now(),
      shippingAddress: ShippingAddress(
        fullName: 'John Doe',
        street: '123 Main St',
        city: 'New York',
        state: 'NY',
        zipCode: '10001',
        country: 'USA',
        phoneNumber: '+1234567890',
      ),
    );

    test('should get order details from repository', () async {
      // Arrange
      when(mockRepository.getOrderDetails(orderId))
          .thenAnswer((_) async => Right(order));

      // Act
      final result = await getOrderDetailsUseCase(orderId);

      // Assert
      expect(result, Right(order));
      verify(mockRepository.getOrderDetails(orderId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('CreateOrderUseCase', () {
    final params = CreateOrderParams(
      items: [
        const OrderItem(
          productId: 'product1',
          productName: 'Product 1',
          price: 100.0,
          quantity: 2,
          imageUrl: 'https://example.com/image1.jpg',
        ),
      ],
      totalAmount: 200.0,
      shippingAddress: ShippingAddress(
        fullName: 'John Doe',
        street: '123 Main St',
        city: 'New York',
        state: 'NY',
        zipCode: '10001',
        country: 'USA',
        phoneNumber: '+1234567890',
      ),
    );

    final order = Order(
      id: 'order1',
      userId: 'user1',
      items: params.items,
      totalAmount: params.totalAmount,
      status: OrderStatus.processing,
      orderDate: DateTime.now(),
      shippingAddress: params.shippingAddress,
    );

    test('should create order through repository', () async {
      // Arrange
      when(mockRepository.createOrder(
        items: params.items,
        totalAmount: params.totalAmount,
        shippingAddress: params.shippingAddress,
      )).thenAnswer((_) async => Right(order));

      // Act
      final result = await createOrderUseCase(params);

      // Assert
      expect(result, Right(order));
      verify(mockRepository.createOrder(
        items: params.items,
        totalAmount: params.totalAmount,
        shippingAddress: params.shippingAddress,
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('CancelOrderUseCase', () {
    const orderId = 'order1';

    test('should cancel order through repository', () async {
      // Arrange
      when(mockRepository.cancelOrder(orderId))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await cancelOrderUseCase(orderId);

      // Assert
      expect(result, const Right(unit));
      verify(mockRepository.cancelOrder(orderId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
