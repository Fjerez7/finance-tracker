import '../entities/category.dart';

/// Contract interface for managing transaction categories.
abstract class CategoryRepository {
  /// Fetches categories, optionally filtered by [type].
  Future<List<Category>> getCategories({CategoryType? type});

  /// Fetches a specific category by its unique [id].
  Future<Category?> getCategoryById(String id);

  /// Creates a new category.
  Future<void> createCategory(Category category);

  /// Updates an existing category.
  Future<void> updateCategory(Category category);

  /// Deletes a custom category by its unique [id].
  Future<void> deleteCategory(String id);
}
