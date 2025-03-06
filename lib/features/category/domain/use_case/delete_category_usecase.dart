import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:circle_share/app/usecase/usecase.dart';
import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/category/domain/repository/category_repository.dart';

class DeleteCategoryParams extends Equatable {
  final String categoryId;

  const DeleteCategoryParams({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

class DeleteCategoryUseCase implements UsecaseWithParams<void, DeleteCategoryParams> {
  final ICategoryRepository categoryRepository;

  DeleteCategoryUseCase({required this.categoryRepository});

  @override
  Future<Either<Failure, void>> call(DeleteCategoryParams params) async {
    return await categoryRepository.deleteCategory(params.categoryId);
  }
}
