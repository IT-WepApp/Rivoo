import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:seller_panel/features/products/domain/entities/product_entity.dart';
import 'package:seller_panel/features/products/domain/repositories/product_repository.dart';
import 'package:seller_panel/features/products/domain/usecases/get_products_usecase.dart';

import 'get_products_usecase_test.mocks.dart';

@GenerateMocks([ProductRepository])
void main() {
  late GetProductsUseCase useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetProductsUseCase(mockRepository);
  });

  final testSellerId = 'seller1';
  final testProducts = [
    ProductEntity(
      id: '1',
      name: 'منتج اختبار 1',
      description: 'وصف المنتج للاختبار 1',
      price: 100.0,
      imageUrls: ['url1', 'url2'],
      category: 'فئة الاختبار',
      isAvailable: true,
      sellerId: testSellerId,
      createdAt: DateTime(2025, 4, 20),
      updatedAt: DateTime(2025, 4, 20),
      stockQuantity: 10,
    ),
    ProductEntity(
      id: '2',
      name: 'منتج اختبار 2',
      description: 'وصف المنتج للاختبار 2',
      price: 200.0,
      imageUrls: ['url3', 'url4'],
      category: 'فئة الاختبار',
      isAvailable: true,
      sellerId: testSellerId,
      createdAt: DateTime(2025, 4, 20),
      updatedAt: DateTime(2025, 4, 20),
      stockQuantity: 5,
    ),
  ];

  test('يجب أن تستدعي حالة الاستخدام مستودع المنتجات وتعيد قائمة المنتجات', () async {
    // الإعداد
    when(mockRepository.getProducts(testSellerId))
        .thenAnswer((_) async => testProducts);

    // التنفيذ
    final result = await useCase(testSellerId);

    // التحقق
    expect(result, testProducts);
    verify(mockRepository.getProducts(testSellerId));
    verifyNoMoreInteractions(mockRepository);
  });
}
