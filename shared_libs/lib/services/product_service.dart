import 'package:shared_libs/models/product.dart';
import 'package:shared_libs/models/promotion.dart';
import 'package:shared_libs/utils/logger.dart';

class ProductService {
  final AppLogger _logger = AppLogger();

  ProductService();

  Future<void> createPromotion({
    required String productId,
    required PromotionType type,
    required double value,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Product(
        id: 'temp',
        name: 'temp',
        description: 'temp',
        categoryId: 'temp',
        sellerId: 'temp',
        price: 1.0,
        imageUrl: 'temp',
        status: 'pending',
        hasPromotion: true,
        promotionType: type,
        promotionValue: value,
        promotionStartDate: startDate,
        promotionEndDate: endDate,
      );
    } catch (e) {
      _logger.error('Failed to create promotion', e);
      throw Exception('Failed to create promotion: $e');
    }
  }

  Future<void> updatePromotion({
    required String productId,
    required PromotionType type,
    required double value,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Product(
        id: 'temp',
        name: 'temp',
        description: 'temp',
        categoryId: 'temp',
        sellerId: 'temp',
        price: 1.0,
        imageUrl: 'temp',
        status: 'pending',
        hasPromotion: true,
        promotionType: type,
        promotionValue: value,
        promotionStartDate: startDate,
        promotionEndDate: endDate,
      );
    } catch (e) {
      _logger.error('Failed to update promotion', e);
      throw Exception('Failed to update promotion: $e');
    }
  }

  Future<void> deletePromotion(String productId) async {
    try {
      const Product(
        id: 'temp',
        name: 'temp',
        description: 'temp',
        categoryId: 'temp',
        sellerId: 'temp',
        price: 1.0,
        imageUrl: 'temp',
        status: 'pending',
        hasPromotion: false,
        promotionType: null,
        promotionValue: null,
        promotionStartDate: null,
        promotionEndDate: null,
      );
    } catch (e) {
      _logger.error('Failed to delete promotion', e);
      throw Exception('Failed to delete promotion: $e');
    }
  }

  Future<PromotionDetails?> getPromotionsForProduct(String productId) async {
    try {
      const product = Product(
        id: 'temp',
        name: 'temp',
        description: 'temp',
        categoryId: 'temp',
        sellerId: 'temp',
        price: 1.0,
        imageUrl: 'temp',
        status: 'pending',
        hasPromotion: false,
        promotionType: null,
        promotionValue: null,
        promotionStartDate: null,
        promotionEndDate: null,
      );

      if (product.hasPromotion) {
        return PromotionDetails(
          type: product.promotionType!,
          value: product.promotionValue!,
          startDate: product.promotionStartDate,
          endDate: product.promotionEndDate,
        );
      } else {
        return null;
      }
    } catch (e) {
      _logger.error('Failed to get promotion for product', e);
      throw Exception('Failed to get promotion for product: $e');
    }
  }

  Future<List<Product>> getAllProducts() async {
    return [
      const Product(
        id: '1',
        name: 'Test Product',
        description: 'Sample description',
        categoryId: 'cat1',
        sellerId: 'seller1',
        price: 100.0,
        imageUrl: 'https://example.com/image.jpg',
        status: 'pending',
        hasPromotion: false,
      ),
    ];
  }

  Future<Product?> getProduct(String productId) async {
    try {
      final allProducts = await getAllProducts();
      for (final product in allProducts) {
        if (product.id == productId) return product;
      }
      return null;
    } catch (e) {
      _logger.error('Failed to get product', e);
      throw Exception('Failed to get product: $e');
    }
  }

  Future<void> approveProduct(String productId) async {
    try {
      _logger.info('Product $productId approved');
    } catch (e) {
      _logger.error('Failed to approve product', e);
      throw Exception('Failed to approve product: $e');
    }
  }

  Future<void> rejectProduct(String productId) async {
    try {
      _logger.info('Product $productId rejected');
    } catch (e) {
      _logger.error('Failed to reject product', e);
      throw Exception('Failed to reject product: $e');
    }
  }

  Future<List<Product>> getProductsBySeller(String sellerId) async {
    try {
      final allProducts = await getAllProducts();
      return allProducts.where((product) => product.sellerId == sellerId).toList();
    } catch (e) {
      _logger.error('Failed to fetch products by seller', e);
      throw Exception('Failed to fetch products by seller: $e');
    }
  }

  Future<void> createProduct(Product product) async {
    try {
      _logger.info('Product ${product.id} created');
    } catch (e) {
      _logger.error('Failed to create product', e);
      throw Exception('Failed to create product: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      _logger.info('Product ${product.id} updated');
    } catch (e) {
      _logger.error('Failed to update product', e);
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      _logger.info('Product $productId deleted');
    } catch (e) {
      _logger.error('Failed to delete product', e);
      throw Exception('Failed to delete product: $e');
    }
  }
}

class PromotionDetails {
  final PromotionType type;
  final double value;
  final DateTime? startDate;
  final DateTime? endDate;

  PromotionDetails({
    required this.type,
    required this.value,
    this.startDate,
    this.endDate,
  });
}
