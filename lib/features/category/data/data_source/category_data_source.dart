import 'package:circle_share/features/category/domain/entity/category_entity.dart';

abstract interface class ICategoryDataSource {
  Future<void> addCategory(CategoryEntity category);

  Future<void> deleteCategory(String categoryId);

  Future<List<CategoryEntity>> getAllCategories();
}
