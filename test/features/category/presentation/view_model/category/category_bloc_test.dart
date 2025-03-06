import 'package:bloc_test/bloc_test.dart';
import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/category/domain/entity/category_entity.dart';
import 'package:circle_share/features/category/domain/use_case/add_category_usecase.dart';
import 'package:circle_share/features/category/domain/use_case/delete_category_usecase.dart';
import 'package:circle_share/features/category/domain/use_case/get_all_categories_usecase.dart';
import 'package:circle_share/features/category/presentation/view_model/category/category_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'category_bloc_test.mocks.dart';

// Custom failure for testing
class TestFailure extends Failure {
  const TestFailure(String message) : super(message: message);
}

@GenerateMocks([
  AddCategoryUseCase,
  GetAllCategoriesUseCase,
  DeleteCategoryUseCase,
])
void main() {
  late MockAddCategoryUseCase mockAddCategoryUseCase;
  late MockGetAllCategoriesUseCase mockGetAllCategoriesUseCase;
  late MockDeleteCategoryUseCase mockDeleteCategoryUseCase;
  late CategoryBloc categoryBloc;

  final testCategories = [
    CategoryEntity(categoryId: '1', name: 'Work'),
    CategoryEntity(categoryId: '2', name: 'Personal'),
    CategoryEntity(categoryId: '3', name: 'Shopping'),
  ];

  final testErrorMessage = 'Something went wrong';

  setUp(() {
    mockAddCategoryUseCase = MockAddCategoryUseCase();
    mockGetAllCategoriesUseCase = MockGetAllCategoriesUseCase();
    mockDeleteCategoryUseCase = MockDeleteCategoryUseCase();

    categoryBloc = CategoryBloc(
      addCategoryUseCase: mockAddCategoryUseCase,
      getAllCategoryUseCase: mockGetAllCategoriesUseCase,
      deleteCategoryUseCase: mockDeleteCategoryUseCase,
    );
  });

  tearDown(() {
    categoryBloc.close();
  });

  test('Initial state should be CategoryState.initial()', () {
    expect(categoryBloc.state, equals(CategoryState.initial()));
  });

  blocTest<CategoryBloc, CategoryState>(
    'Successfully loads all categories',
    build: () {
      when(mockGetAllCategoriesUseCase.call())
          .thenAnswer((_) async => Right(testCategories));
      return categoryBloc;
    },
    act: (bloc) => bloc.add(LoadCategories()),
    expect: () => [
      CategoryState.initial().copyWith(isLoading: true),
      CategoryState.initial()
          .copyWith(isLoading: false, categories: testCategories),
    ],
  );

  blocTest<CategoryBloc, CategoryState>(
    'Successfully adds a category',
    build: () {
      when(mockAddCategoryUseCase.call(any))
          .thenAnswer((_) async => const Right(null));
      when(mockGetAllCategoriesUseCase.call()).thenAnswer((_) async => Right([
            ...testCategories,
            CategoryEntity(categoryId: '4', name: 'New Category')
          ]));

      return categoryBloc;
    },
    act: (bloc) => bloc.add(AddCategory('New Category')),
    expect: () => [
      CategoryState.initial().copyWith(isLoading: true),
      CategoryState.initial().copyWith(isLoading: false, categories: [
        ...testCategories,
        CategoryEntity(categoryId: '4', name: 'New Category')
      ]),
    ],
  );

  blocTest<CategoryBloc, CategoryState>(
    'Successfully deletes a category',
    build: () {
      when(mockDeleteCategoryUseCase.call(any))
          .thenAnswer((_) async => const Right(null));
      when(mockGetAllCategoriesUseCase.call()).thenAnswer((_) async => Right([
            CategoryEntity(categoryId: '2', name: 'Personal'),
            CategoryEntity(categoryId: '3', name: 'Shopping'),
          ]));

      return categoryBloc;
    },
    act: (bloc) => bloc.add(DeleteCategory('1')),
    expect: () => [
      CategoryState.initial().copyWith(isLoading: true),
      CategoryState.initial().copyWith(isLoading: false, categories: [
        CategoryEntity(categoryId: '2', name: 'Personal'),
        CategoryEntity(categoryId: '3', name: 'Shopping'),
      ]),
    ],
  );

  blocTest<CategoryBloc, CategoryState>(
    'Handles empty category list correctly',
    build: () {
      when(mockGetAllCategoriesUseCase.call())
          .thenAnswer((_) async => const Right([]));
      return categoryBloc;
    },
    act: (bloc) => bloc.add(LoadCategories()),
    expect: () => [
      CategoryState.initial().copyWith(isLoading: true),
      CategoryState.initial().copyWith(isLoading: false, categories: []),
    ],
  );

  blocTest<CategoryBloc, CategoryState>(
    'Fails to add category and shows error',
    build: () {
      when(mockAddCategoryUseCase.call(any))
          .thenAnswer((_) async => Left(TestFailure(testErrorMessage)));
      return categoryBloc;
    },
    act: (bloc) => bloc.add(AddCategory('Failing Category')),
    expect: () => [
      CategoryState.initial().copyWith(isLoading: true),
      CategoryState.initial()
          .copyWith(isLoading: false, error: testErrorMessage),
    ],
  );

  blocTest<CategoryBloc, CategoryState>(
    'Fails to delete category and shows error',
    build: () {
      when(mockDeleteCategoryUseCase.call(any))
          .thenAnswer((_) async => Left(TestFailure(testErrorMessage)));
      return categoryBloc;
    },
    act: (bloc) => bloc.add(DeleteCategory('1')),
    expect: () => [
      CategoryState.initial().copyWith(isLoading: true),
      CategoryState.initial()
          .copyWith(isLoading: false, error: testErrorMessage),
    ],
  );
}
