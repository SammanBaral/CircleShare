import 'package:circle_share/app/usecase/usecase.dart';
import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/category/domain/entity/category_entity.dart';
import 'package:circle_share/features/category/domain/repository/category_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class AddCategoryParams extends Equatable {
  final String categoryName;

  const AddCategoryParams({required this.categoryName});

  @override
  List<Object?> get props => [categoryName];
}

class AddCategoryUseCase implements UsecaseWithParams<void, AddCategoryParams> {
  final ICategoryRepository categoryRepository;

  AddCategoryUseCase({required this.categoryRepository});

  @override
  Future<Either<Failure, void>> call(AddCategoryParams params) async {
    return categoryRepository
        .addCategory(CategoryEntity(name: params.categoryName));
  }
}
