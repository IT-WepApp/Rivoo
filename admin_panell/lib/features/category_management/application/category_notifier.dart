import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/lib/models/shared_models.dart';
import 'package:shared_libs/lib/services/shared_services.dart';

class CategoryState {
  final List<Category> categories;
  final bool isLoading;
  final String? error;
  final Map<String, String> errors;

  CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
    this.errors = const {},
  });

  CategoryState copyWith({
    List<Category>? categories,
    bool? isLoading,
    String? error,
    Map<String, String>? errors,
    bool clearError = false,
    bool clearErrors = false,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      errors: clearErrors ? {} : errors ?? this.errors,
    );
  }
}

class CategoryNotifier extends Notifier<CategoryState> {
  late final CategoryService _categoryService;

  @override
  CategoryState build() {
    _categoryService = ref.read(categoryServiceProvider);
    // تحميل الفئات عند بناء الـ Notifier
    Future.microtask(() => loadCategories());
    return CategoryState();
  }

  Future<void> loadCategories() async {
    state =
        state.copyWith(isLoading: true, clearError: true, clearErrors: true);
    try {
      final categories = await _categoryService.getAllCategories();
      state = state.copyWith(categories: categories, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load categories: ${e.toString()}',
      );
    }
  }

  Future<bool> addCategory(Category category) async {
    state =
        state.copyWith(isLoading: true, clearError: true, clearErrors: true);

    if (category.name.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errors: {'name': 'Category name cannot be empty'},
      );
      return false;
    }

    try {
      await _categoryService.addCategory(category); // ✅ ما في قيمة راجعة
      await loadCategories(); // ✅ تحديث القائمة
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add category: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> updateCategory(Category category) async {
    state =
        state.copyWith(isLoading: true, clearError: true, clearErrors: true);

    if (category.name.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errors: {'name': 'Category name cannot be empty'},
      );
      return false;
    }

    try {
      await _categoryService.updateCategory(category); // ✅ ما في قيمة راجعة
      await loadCategories(); // ✅ تحديث القائمة
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update category: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _categoryService.deleteCategory(categoryId);
      await loadCategories(); // ✅ تحديث القائمة بعد الحذف
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete category: ${e.toString()}',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true, clearErrors: true);
  }
}

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService();
});

final categoryNotifierProvider =
    NotifierProvider<CategoryNotifier, CategoryState>(() => CategoryNotifier());
