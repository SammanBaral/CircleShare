import 'package:circle_share/core/network/hive_service.dart';
import 'package:circle_share/features/category/data/data_source/category_data_source.dart';
import 'package:circle_share/features/category/data/model/category_hive_model.dart';
import 'package:circle_share/features/category/domain/entity/category_entity.dart';
import 'package:uuid/uuid.dart';

class CategoryLocalDataSource implements ICategoryDataSource {
  final HiveService _hiveService;
  final _uuid = Uuid();

  CategoryLocalDataSource(this._hiveService) {
    _initPredefinedCategories();
  }

  // Initialize predefined categories if none exist
  Future<void> _initPredefinedCategories() async {
    try {
      final existingCategories = await _hiveService.getAllCategories();

      // Only add predefined categories if the box is empty
      if (existingCategories.isEmpty) {
        final predefinedCategories = [
          CategoryEntity(
            categoryId: _uuid.v4(),
            name: 'Electronics',
          ),
          CategoryEntity(
            categoryId: _uuid.v4(),
            name: 'Books',
          ),
          CategoryEntity(
            categoryId: _uuid.v4(),
            name: 'Tools',
          ),
          CategoryEntity(
            categoryId: _uuid.v4(),
            name: 'Kitchen',
          ),
          CategoryEntity(
            categoryId: _uuid.v4(),
            name: 'Sports',
          ),
        ];

        // Add each predefined category
        for (final category in predefinedCategories) {
          final categoryHiveModel = CategoryHiveModel.fromEntity(category);
          await _hiveService.addCategory(categoryHiveModel);
        }

        print('Added ${predefinedCategories.length} predefined categories');
      }
    } catch (e) {
      print('Error initializing predefined categories: $e');
    }
  }

  @override
  Future<void> addCategory(CategoryEntity category) async {
    try {
      final categoryHiveModel = CategoryHiveModel.fromEntity(category);
      await _hiveService.addCategory(categoryHiveModel);
      return Future.value();
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _hiveService.deleteCategory(categoryId);
      return Future.value();
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    try {
      final categories = await _hiveService.getAllCategories();
      return categories.map((e) => e.toEntity()).toList();
    } catch (e) {
      return Future.error(e);
    }
  }
}
