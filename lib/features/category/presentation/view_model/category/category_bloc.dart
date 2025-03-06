import 'package:bloc/bloc.dart';
import 'package:circle_share/features/category/domain/entity/category_entity.dart';
import 'package:circle_share/features/category/domain/use_case/add_category_usecase.dart';
import 'package:circle_share/features/category/domain/use_case/delete_category_usecase.dart';
import 'package:circle_share/features/category/domain/use_case/get_all_categories_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final AddCategoryUseCase _addCategoryUseCase;
  final GetAllCategoriesUseCase _getAllCategoryUseCase;
  final DeleteCategoryUseCase _deleteCategoryUseCase;

  CategoryBloc({
    required AddCategoryUseCase addCategoryUseCase,
    required GetAllCategoriesUseCase getAllCategoryUseCase,
    required DeleteCategoryUseCase deleteCategoryUseCase,
  })  : _addCategoryUseCase = addCategoryUseCase,
        _getAllCategoryUseCase = getAllCategoryUseCase,
        _deleteCategoryUseCase = deleteCategoryUseCase,
        super(CategoryState.initial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<DeleteCategory>(_onDeleteCategory);

    add(LoadCategories());
  }

  Future<void> _onLoadCategories(
      LoadCategories event, Emitter<CategoryState> emit) async {
    print("Loading categories...");
    emit(state.copyWith(isLoading: true));
    final result = await _getAllCategoryUseCase.call();
    result.fold(
      (failure) {
        print("Failed to load categories: ${failure.message}");
        emit(state.copyWith(isLoading: false, error: failure.message));
      },
      (categories) {
        print("Successfully loaded ${categories.length} categories");
        for (var category in categories) {
          print("Category: ${category.name}, ID: ${category.categoryId}");
        }
        emit(state.copyWith(isLoading: false, categories: categories));
      },
    );
  }

  Future<void> _onAddCategory(
      AddCategory event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(isLoading: true));
    final result = await _addCategoryUseCase
        .call(AddCategoryParams(categoryName: event.categoryName));
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (_) {
        emit(state.copyWith(isLoading: false, error: null));
        add(LoadCategories());
      },
    );
  }

  Future<void> _onDeleteCategory(
      DeleteCategory event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(isLoading: true));
    final result = await _deleteCategoryUseCase
        .call(DeleteCategoryParams(categoryId: event.categoryId));
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (_) {
        emit(state.copyWith(isLoading: false, error: null));
        add(LoadCategories());
      },
    );
  }
}
