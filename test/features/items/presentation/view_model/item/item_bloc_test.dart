import 'package:bloc_test/bloc_test.dart';
import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/items/domain/entity/item_entity.dart';
import 'package:circle_share/features/items/domain/use_case/add_item_usecase.dart';
import 'package:circle_share/features/items/domain/use_case/delete_item_usecase.dart';
import 'package:circle_share/features/items/domain/use_case/get_item_usecase.dart';
import 'package:circle_share/features/items/domain/use_case/upload_item_image_usecase.dart';
import 'package:circle_share/features/items/presentation/view_model/item/item_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../auth/domain/use_case/upload_image_usecase_test.dart';

void
    // Register a fallback value for AddItemParams
    setUpAll() {
  registerFallbackValue(
    AddItemParams(
      name: 'Test Item',
      categoryId: 'Cat1',
      description: 'Test Description',
      availabilityStatus: 'available',
      imageName: 'test_image.jpg',
      rulesNotes: 'Some rules',
      locationId: 'Loc1',
      price: 100.0,
      condition: 'New',
      maxBorrowDuration: 0,
    ),
  );
}

// Mock Classes
class MockAddItemUseCase extends Mock implements AddItemUseCase {}

class MockGetAllItemsUseCase extends Mock implements GetAllItemsUseCase {}

class MockDeleteItemUseCase extends Mock implements DeleteItemUseCase {}

class MockUploadItemImageUseCase extends Mock
    implements UploadItemImagesUseCase {}

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  late ItemBloc itemBloc;
  late MockAddItemUseCase mockAddItemUseCase;
  late MockGetAllItemsUseCase mockGetAllItemsUseCase;
  late MockDeleteItemUseCase mockDeleteItemUseCase;
  late MockUploadItemImageUseCase mockUploadItemImageUseCase;

  setUp(() {
    mockAddItemUseCase = MockAddItemUseCase();
    mockGetAllItemsUseCase = MockGetAllItemsUseCase();
    mockDeleteItemUseCase = MockDeleteItemUseCase();
    mockUploadItemImageUseCase = MockUploadItemImageUseCase();

    itemBloc = ItemBloc(
      addItemUseCase: mockAddItemUseCase,
      getAllItemUseCase: mockGetAllItemsUseCase,
      deleteItemUseCase: mockDeleteItemUseCase,
      uploadItemImageUseCase: mockUploadItemImageUseCase,
    );
  });

  tearDown(() {
    itemBloc.close();
  });

  // Test 1: Load Items
  blocTest<ItemBloc, ItemState>(
    'emits [loading, success] when items are loaded successfully',
    build: () {
      when(() => mockGetAllItemsUseCase.call()).thenAnswer(
        (_) async => Right([
          ItemEntity(
            id: '1',
            name: 'Test Item',
            categoryId: 'Cat1',
            locationId: 'Loc1',
            userId: 'User1',
            description: 'Description of Test Item',
            availabilityStatus: 'available',
            borrowerId: null,
            imageName: 'test_image.jpg',
            rulesNotes: 'Some rules',
            price: 100.0,
            condition: 'New',
            maxBorrowDuration: 7,
          ),
        ]),
      );
      return itemBloc;
    },
    act: (bloc) => bloc.add(LoadItems()),
    expect: () => [
      ItemState(isLoading: true, items: [], isSuccess: false),
      ItemState(
        isLoading: false,
        items: [
          ItemEntity(
            id: '1',
            name: 'Test Item',
            categoryId: 'Cat1',
            locationId: 'Loc1',
            userId: 'User1',
            description: 'Description of Test Item',
            availabilityStatus: 'available',
            borrowerId: null,
            imageName: 'test_image.jpg',
            rulesNotes: 'Some rules',
            price: 100.0,
            condition: 'New',
            maxBorrowDuration: 7,
          ),
        ],
        isSuccess: true,
      ),
    ],
  );

  // Test 2: Add Item
  blocTest<ItemBloc, ItemState>(
    'emits [loading, success] when an item is added successfully',
    build: () {
      when(() => mockAddItemUseCase.call(any()))
          .thenAnswer((_) async => Right(null));
      when(() => mockGetAllItemsUseCase.call()).thenAnswer(
        (_) async => Right([
          ItemEntity(
            id: '1',
            name: 'Test Item',
            categoryId: 'Cat1',
            locationId: 'Loc1',
            userId: 'User1',
            description: 'Description of Test Item',
            availabilityStatus: 'available',
            borrowerId: null,
            imageName: 'test_image.jpg',
            rulesNotes: 'Some rules',
            price: 100.0,
            condition: 'New',
            maxBorrowDuration: 7,
          ),
        ]),
      );
      return itemBloc;
    },
    act: (bloc) => bloc.add(AddItem(
      context: MockBuildContext(),
      name: 'New Item',
      categoryId: 'Cat2',
      description: 'Description of New Item',
      imageName: 'new_image.jpg',
      availabilityStatus: 'available',
      locationId: 'Loc2',
      price: 150.0,
      condition: 'Used',
    )),
    expect: () => [
      ItemState(isLoading: true, items: [], isSuccess: false),
      ItemState(
        isLoading: false,
        items: [
          ItemEntity(
            id: '1',
            name: 'Test Item',
            categoryId: 'Cat1',
            locationId: 'Loc1',
            userId: 'User1',
            description: 'Description of Test Item',
            availabilityStatus: 'available',
            borrowerId: null,
            imageName: 'test_image.jpg',
            rulesNotes: 'Some rules',
            price: 100.0,
            condition: 'New',
            maxBorrowDuration: 7,
          ),
        ],
        isSuccess: true,
      ),
    ],
  );

  // Test 3: Delete Item
  blocTest<ItemBloc, ItemState>(
    'emits [loading, success] when an item is deleted successfully',
    build: () {
      when(() => mockDeleteItemUseCase.call(any()))
          .thenAnswer((_) async => Right(null));
      when(() => mockGetAllItemsUseCase.call()).thenAnswer(
        (_) async => Right([
          ItemEntity(
            id: '1',
            name: 'Test Item',
            categoryId: 'Cat1',
            locationId: 'Loc1',
            userId: 'User1',
            description: 'Description of Test Item',
            availabilityStatus: 'available',
            borrowerId: null,
            imageName: 'test_image.jpg',
            rulesNotes: 'Some rules',
            price: 100.0,
            condition: 'New',
            maxBorrowDuration: 7,
          ),
        ]),
      );
      return itemBloc;
    },
    act: (bloc) => bloc.add(DeleteItem('1')),
    expect: () => [
      ItemState(
        isLoading: true,
        items: [
          ItemEntity(
            id: '1',
            name: 'Test Item',
            categoryId: 'Cat1',
            locationId: 'Loc1',
            userId: 'User1',
            description: 'Description of Test Item',
            availabilityStatus: 'available',
            borrowerId: null,
            imageName: 'test_image.jpg',
            rulesNotes: 'Some rules',
            price: 100.0,
            condition: 'New',
            maxBorrowDuration: 7,
          ),
        ],
        isSuccess: false,
      ),
      ItemState(
        isLoading: false,
        items: [],
        isSuccess: true,
      ),
    ],
  );

  // Test 4: Upload Item Image
  blocTest<ItemBloc, ItemState>(
    'emits [loading, success] when an item image is uploaded successfully',
    build: () {
      when(() => mockUploadItemImageUseCase.call(any()))
          .thenAnswer((_) async => Right('new_image.jpg'));
      return itemBloc;
    },
    act: (bloc) => bloc.add(UploadItemImage(file: MockFile())),
    expect: () => [
      ItemState(isLoading: true, items: [], isSuccess: false),
      ItemState(
        isLoading: false,
        isSuccess: true,
        items: [],
        imageName: 'new_image.jpg',
      ),
    ],
  );

  // Test 5: Load Items Failure
  blocTest<ItemBloc, ItemState>(
    'emits [loading, failure] when loading items fails',
    build: () {
      when(() => mockGetAllItemsUseCase.call()).thenAnswer(
        (_) async => Left(NetworkFailure(message: 'Failed to load items')),
      );
      return itemBloc;
    },
    act: (bloc) => bloc.add(LoadItems()),
    expect: () => [
      ItemState(isLoading: true, items: [], isSuccess: false),
      ItemState(
          isLoading: false,
          items: [],
          error: 'Failed to load items',
          isSuccess: false),
    ],
  );
}
