import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

// حالة استخدام لتحديث منتج موجود
class UpdateProductUseCase {
  final ProductRepository repository;

  UpdateProductUseCase(this.repository);

  Future<bool> call(ProductEntity product) async {
    return await repository.updateProduct(product);
  }
}
