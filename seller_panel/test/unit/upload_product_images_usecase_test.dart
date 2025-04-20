import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:seller_panel/features/products/domain/entities/product_entity.dart';
import 'package:seller_panel/features/products/domain/repositories/product_repository.dart';
import 'package:seller_panel/features/products/domain/usecases/upload_product_images_usecase.dart';

import 'upload_product_images_usecase_test.mocks.dart';

@GenerateMocks([ProductRepository])
void main() {
  late UploadProductImagesUseCase useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = UploadProductImagesUseCase(mockRepository);
  });

  final testProductId = 'product1';
  final testLocalImagePaths = [
    '/path/to/image1.jpg',
    '/path/to/image2.jpg',
    '/path/to/image3.jpg',
  ];
  final testImageUrls = [
    'https://example.com/image1.jpg',
    'https://example.com/image2.jpg',
    'https://example.com/image3.jpg',
  ];

  test('يجب أن تستدعي حالة الاستخدام مستودع المنتجات وتعيد قائمة روابط الصور', () async {
    // الإعداد
    when(mockRepository.uploadProductImages(testProductId, testLocalImagePaths))
        .thenAnswer((_) async => testImageUrls);

    // التنفيذ
    final result = await useCase(testProductId, testLocalImagePaths);

    // التحقق
    expect(result, testImageUrls);
    verify(mockRepository.uploadProductImages(testProductId, testLocalImagePaths));
    verifyNoMoreInteractions(mockRepository);
  });
}
