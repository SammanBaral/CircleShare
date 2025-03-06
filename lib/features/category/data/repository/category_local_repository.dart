import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/category/data/data_source/category_data_source.dart';
import 'package:circle_share/features/category/domain/entity/category_entity.dart';
import 'package:circle_share/features/category/domain/repository/category_repository.dart';
import 'package:dartz/dartz.dart';

class CategoryLocalRepository implements ICategoryRepository {
  final ICategoryDataSource _categoryLocalDataSource;

  CategoryLocalRepository(this._categoryLocalDataSource);

  @override
  Future<Either<Failure, void>> addCategory(CategoryEntity category) async {
    try {
      await _categoryLocalDataSource.addCategory(category);
      return Right(null);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final categories = await _categoryLocalDataSource.getAllCategories();
      return Right(categories);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String categoryId) async {
    try {
      await _categoryLocalDataSource.deleteCategory(categoryId);
      return Right(null);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
