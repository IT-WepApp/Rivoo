import 'package:shared_models/src/models/category.dart';

class CategoryService {
  // Replace with your actual database implementation
  final _database = {}; // Example in-memory "database"

  Future<List<Category>> getAllCategories() async {
    // In a real implementation, fetch from a database
    return _database.values.map((data) => Category.fromJson(data)).toList();
  }

  Future<Category?> getCategoryById(String id) async {
    // In a real implementation, fetch from a database by ID
    final data = _database[id];
    return data != null ? Category.fromJson(data) : null;
  }

  Future<String> addCategory(Category category) async {
    // In a real implementation, add to a database and return the generated ID
    final id =
        category.id; // Assuming the ID is generated before calling this method
    _database[id] = category.toJson();
    return id;
  }

  Future<void> updateCategory(Category category) async {
    // In a real implementation, update the category in the database
    if (!_database.containsKey(category.id)) {
      throw Exception('Category not found');
    }
    _database[category.id] = category.toJson();
  }

  Future<void> deleteCategory(String id) async {
    // In a real implementation, delete the category from the database
    if (!_database.containsKey(id)) {
      throw Exception('Category not found');
    }
    _database.remove(id);
  }
}
