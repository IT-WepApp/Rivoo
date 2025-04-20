import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

// حالة استخدام لإضافة منتج جديد
class AddProductUseCase {
  final ProductRepository repository;

  AddProductUseCase(this.repository);

  Future<String> call(ProductEntity product) async {
    return await repository.addProduct(product);
  }
}
