import '../repositories/product_repository.dart';

// حالة استخدام لرفع صور متعددة للمنتج
class UploadProductImagesUseCase {
  final ProductRepository repository;

  UploadProductImagesUseCase(this.repository);

  Future<List<String>> call(String productId, List<String> localImagePaths) async {
    return await repository.uploadProductImages(productId, localImagePaths);
  }
}
