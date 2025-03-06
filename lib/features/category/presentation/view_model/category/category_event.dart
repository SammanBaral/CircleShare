part of 'category_bloc.dart';

@immutable
sealed class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

final class LoadCategories extends CategoryEvent {}

final class AddCategory extends CategoryEvent {
  final String categoryName;

  const AddCategory(this.categoryName);

  @override
  List<Object> get props => [categoryName];
}

final class DeleteCategory extends CategoryEvent {
  final String categoryId;

  const DeleteCategory(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}
