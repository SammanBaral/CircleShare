import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/category/domain/entity/category_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class ICategoryRepository {
  Future<Either<Failure, void>> addCategory(CategoryEntity category);

  Future<Either<Failure, List<CategoryEntity>>> getCategories();


  Future<Either<Failure, void>> deleteCategory(String categoryId);
}
