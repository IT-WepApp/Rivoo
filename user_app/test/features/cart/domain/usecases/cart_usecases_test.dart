import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:user_app/core/architecture/domain/failure.dart';
import 'package:user_app/features/cart/domain/entities/cart_item.dart';
import 'package:user_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:user_app/features/cart/domain/usecases/cart_usecases.dart';

@GenerateMocks([CartRepository])
import 'cart_usecases_test.mocks.dart';

void main() {
  late MockCartRepository mockRepository;
  late GetCartItemsUseCase getCartItemsUseCase;
  late AddToCartUseCase addToCartUseCase;
  late UpdateCartItemUseCase updateCartItemUseCase;
  late RemoveFromCartUseCase removeFromCartUseCase;
  late ClearCartUseCase clearCartUseCase;

  setUp(() {
    mockRepository = MockCartRepository();
    getCartItemsUseCase = GetCartItemsUseCase(mockRepository);
    addToCartUseCase = AddToCartUseCase(mockRepository);
    updateCartItemUseCase = UpdateCartItemUseCase(mockRepository);
    removeFromCartUseCase = RemoveFromCartUseCase(mockRepository);
    clearCartUseCase = ClearCartUseCase(mockRepository);
  });

  group('GetCartItemsUseCase', () {
    final cartItems = [
      CartItem(
        id: 'item1',
        productId: 'product1',
        productName: 'Product 1',
        price: 100.0,
        quantity: 2,
        imageUrl: 'https://example.com/image1.jpg',
      ),
      CartItem(
        id: 'item2',
        productId: 'product2',
        productName: 'Product 2',
        price: 150.0,
        quantity: 1,
        imageUrl: 'https://example.com/image2.jpg',
      ),
    ];

    test('should get cart items from repository', () async {
      // Arrange
      when(mockRepository.getCartItems())
          .thenAnswer((_) async => Right(cartItems));

      // Act
      final result = await getCartItemsUseCase(NoParams());

      // Assert
      expect(result, Right(cartItems));
      verify(mockRepository.getCartItems()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      final failure = ServerFailure(message: 'Server error');
      when(mockRepository.getCartItems())
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await getCartItemsUseCase(NoParams());

      // Assert
      expect(result, Left(failure));
      verify(mockRepository.getCartItems()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('AddToCartUseCase', () {
    final params = AddToCartParams(
      productId: 'product1',
      productName: 'Product 1',
      price: 100.0,
      quantity: 2,
      imageUrl: 'https://example.com/image1.jpg',
    );

    final cartItem = CartItem(
      id: 'item1',
      productId: params.productId,
      productName: params.productName,
      price: params.price,
      quantity: params.quantity,
      imageUrl: params.imageUrl,
    );

    test('should add item to cart through repository', () async {
      // Arrange
      when(mockRepository.addToCart(
        productId: params.productId,
        productName: params.productName,
        price: params.price,
        quantity: params.quantity,
        imageUrl: params.imageUrl,
      )).thenAnswer((_) async => Right(cartItem));

      // Act
      final result = await addToCartUseCase(params);

      // Assert
      expect(result, Right(cartItem));
      verify(mockRepository.addToCart(
        productId: params.productId,
        productName: params.productName,
        price: params.price,
        quantity: params.quantity,
        imageUrl: params.imageUrl,
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('UpdateCartItemUseCase', () {
    final params = UpdateCartItemParams(
      itemId: 'item1',
      quantity: 3,
    );

    final cartItem = CartItem(
      id: params.itemId,
      productId: 'product1',
      productName: 'Product 1',
      price: 100.0,
      quantity: params.quantity,
      imageUrl: 'https://example.com/image1.jpg',
    );

    test('should update cart item through repository', () async {
      // Arrange
      when(mockRepository.updateCartItem(
        itemId: params.itemId,
        quantity: params.quantity,
      )).thenAnswer((_) async => Right(cartItem));

      // Act
      final result = await updateCartItemUseCase(params);

      // Assert
      expect(result, Right(cartItem));
      verify(mockRepository.updateCartItem(
        itemId: params.itemId,
        quantity: params.quantity,
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('RemoveFromCartUseCase', () {
    final itemId = 'item1';

    test('should remove item from cart through repository', () async {
      // Arrange
      when(mockRepository.removeFromCart(itemId))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await removeFromCartUseCase(itemId);

      // Assert
      expect(result, const Right(unit));
      verify(mockRepository.removeFromCart(itemId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('ClearCartUseCase', () {
    test('should clear cart through repository', () async {
      // Arrange
      when(mockRepository.clearCart())
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await clearCartUseCase(NoParams());

      // Assert
      expect(result, const Right(unit));
      verify(mockRepository.clearCart()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
