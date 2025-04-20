import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:seller_panel/features/products/data/datasources/product_firebase_datasource.dart';
import 'package:seller_panel/features/products/data/repositories/product_repository_impl.dart';
import 'package:seller_panel/features/products/domain/entities/product_entity.dart';

import 'product_repository_impl_test.mocks.dart';

@GenerateMocks([ProductFirebaseDataSource])
void main() {
  late ProductRepositoryImpl repository;
  late MockProductFirebaseDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockProductFirebaseDataSource();
    repository = ProductRepositoryImpl(mockDataSource);
  });

  final testSellerId = 'seller1';
  final testProductsData = [
    {
      'id': '1',
      'name': 'منتج اختبار 1',
      'description': 'وصف المنتج للاختبار 1',
      'price': 100.0,
      'imageUrls': ['url1', 'url2'],
      'category': 'فئة الاختبار',
      'isAvailable': true,
      'sellerId': 'seller1',
      'createdAt': DateTime(2025, 4, 20),
      'updatedAt': DateTime(2025, 4, 20),
      'stockQuantity': 10,
    },
    {
      'id': '2',
      'name': 'منتج اختبار 2',
      'description': 'وصف المنتج للاختبار 2',
      'price': 200.0,
      'imageUrls': ['url3', 'url4'],
      'category': 'فئة الاختبار',
      'isAvailable': true,
      'sellerId': 'seller1',
      'createdAt': DateTime(2025, 4, 20),
      'updatedAt': DateTime(2025, 4, 20),
      'stockQuantity': 5,
    },
  ];

  test('يجب أن يستدعي المستودع مصدر البيانات ويحول البيانات إلى كيانات', () async {
    // الإعداد
    when(mockDataSource.getProducts(testSellerId))
        .thenAnswer((_) async => testProductsData);

    // التنفيذ
    final result = await repository.getProducts(testSellerId);

    // التحقق
    expect(result.length, 2);
    expect(result[0].id, '1');
    expect(result[0].name, 'منتج اختبار 1');
    expect(result[0].imageUrls, ['url1', 'url2']);
    expect(result[1].id, '2');
    expect(result[1].name, 'منتج اختبار 2');
    expect(result[1].imageUrls, ['url3', 'url4']);
    verify(mockDataSource.getProducts(testSellerId));
    verifyNoMoreInteractions(mockDataSource);
  });

  test('يجب أن يستدعي المستودع مصدر البيانات لرفع صور المنتج', () async {
    // الإعداد
    final testProductId = 'product1';
    final testLocalImagePaths = ['/path/to/image1.jpg', '/path/to/image2.jpg'];
    final testImageUrls = ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'];
    
    when(mockDataSource.uploadProductImages(testProductId, testLocalImagePaths))
        .thenAnswer((_) async => testImageUrls);

    // التنفيذ
    final result = await repository.uploadProductImages(testProductId, testLocalImagePaths);

    // التحقق
    expect(result, testImageUrls);
    verify(mockDataSource.uploadProductImages(testProductId, testLocalImagePaths));
    verifyNoMoreInteractions(mockDataSource);
  });
}
