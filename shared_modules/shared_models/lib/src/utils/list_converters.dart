import '../models/product.dart';

/// مساعد لتحويل قائمة JSON إلى قائمة من نماذج Product
class ProductListConverter {
  /// تحويل قائمة JSON إلى قائمة من نماذج Product
  static List<Product> fromJsonList(List<dynamic> jsonList) {
    return List<Product>.from(jsonList.map((e) => Product.fromJson(e)));
  }

  /// تحويل قائمة من نماذج Product إلى قائمة JSON
  static List<Map<String, dynamic>> toJsonList(List<Product> products) {
    return products.map((product) => product.toJson()).toList();
  }
}
