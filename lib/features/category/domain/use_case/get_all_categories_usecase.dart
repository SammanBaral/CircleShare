import 'package:dartz/dartz.dart';
import 'package:circle_share/app/usecase/usecase.dart';
import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/category/domain/entity/category_entity.dart';
import 'package:circle_share/features/category/domain/repository/category_repository.dart';

class GetAllCategoriesUseCase implements UsecaseWithoutParams<List<CategoryEntity>> {
  final ICategoryRepository categoryRepository;

  GetAllCategoriesUseCase({required this.categoryRepository});

  @override
  Future<Either<Failure, List<CategoryEntity>>> call() async {
    return await categoryRepository.getCategories();
  }
}
