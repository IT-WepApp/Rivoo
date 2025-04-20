import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

// حالة استخدام للحصول على قائمة المنتجات للبائع
class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<List<ProductEntity>> call(String sellerId) async {
    return await repository.getProducts(sellerId);
  }
}
