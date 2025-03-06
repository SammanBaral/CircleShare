import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:circle_share/core/common/snackbar/my_snackbar.dart';
import 'package:circle_share/features/items/domain/entity/item_entity.dart';
import 'package:circle_share/features/items/domain/use_case/add_item_usecase.dart';
import 'package:circle_share/features/items/domain/use_case/delete_item_usecase.dart';
import 'package:circle_share/features/items/domain/use_case/get_item_usecase.dart';
import 'package:circle_share/features/items/domain/use_case/upload_item_image_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'item_event.dart';
part 'item_state.dart';

class ItemBloc extends Bloc<ItemEvent, ItemState> {
  final AddItemUseCase _addItemUseCase;
  final GetAllItemsUseCase _getAllItemUseCase;
  final DeleteItemUseCase _deleteItemUseCase;
  final UploadItemImagesUseCase _uploadItemImageUseCase;

  ItemBloc({
    required AddItemUseCase addItemUseCase,
    required GetAllItemsUseCase getAllItemUseCase,
    required DeleteItemUseCase deleteItemUseCase,
    required UploadItemImagesUseCase uploadItemImageUseCase,
  })  : _addItemUseCase = addItemUseCase,
        _getAllItemUseCase = getAllItemUseCase,
        _deleteItemUseCase = deleteItemUseCase,
        _uploadItemImageUseCase = uploadItemImageUseCase,
        super(ItemState.initial()) {
    on<LoadItems>(_onLoadItems);
    on<AddItem>(_onAddItem);
    on<DeleteItem>(_onDeleteItem);
    on<UploadItemImage>(_onUploadItemImage);
  }

  // In your ItemBloc, modify the _onLoadItems method:

  void _onLoadItems(
    LoadItems event,
    Emitter<ItemState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    // Debug: Print the current state before loading
    print('Loading items. Current state has ${state.items.length} items');

    final result = await _getAllItemUseCase.call();

    result.fold(
      (failure) {
        print('Failed to load items: ${failure.message}');
        emit(state.copyWith(isLoading: false, error: failure.message));
      },
      (items) {
        // Debug: Print the loaded items
        print('Successfully loaded ${items.length} items from repository');
        for (var item in items) {
          print('Loaded item: ${item.id} - ${item.name}');
        }

        emit(state.copyWith(isLoading: false, items: items));
      },
    );
  }

// After adding an item, make sure to reload items:
  void _onAddItem(
    AddItem event,
    Emitter<ItemState> emit,
  ) async {
    // Get the image name from state or event
    String? imageName = state.imageName;

    // Changed: Make image optional instead of required
    // Now we'll proceed with the item creation regardless of image presence

    emit(state.copyWith(isLoading: true));
    final result = await _addItemUseCase.call(
      AddItemParams(
        name: event.name,
        categoryId: event.categoryId,
        description: event.description,
        availabilityStatus: event.availabilityStatus,
        locationId: event.locationId,
        borrowerId: event.borrowerId ?? '',
        imageName: imageName, // Pass whatever image name we have, even if null
        rulesNotes: event.rulesNotes ?? '',
        price: event.price,
        condition: event.condition,
        maxBorrowDuration: event.maxBorrowDuration ?? 0,
      ),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, isSuccess: false));
        showMySnackBar(
            context: event.context,
            message: failure.message,
            color: Colors.red);
      },
      (_) {
        emit(state.copyWith(isLoading: false, isSuccess: true));
        showMySnackBar(
            context: event.context, message: "Item added successfully");

        // Important: Explicitly reload items with a small delay to ensure
        // the database has time to update
        Future.delayed(Duration(milliseconds: 300), () {
          add(LoadItems());
        });
      },
    );
  }

  void _onDeleteItem(
    DeleteItem event,
    Emitter<ItemState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final result = await _deleteItemUseCase.call(
      DeleteItemParams(itemId: event.itemId),
    );

    result.fold(
      (l) => emit(state.copyWith(isLoading: false, isSuccess: false)),
      (r) {
        emit(state.copyWith(isLoading: false, isSuccess: true));
      },
    );
  }

  void _onUploadItemImage(
    UploadItemImage event,
    Emitter<ItemState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final result = await _uploadItemImageUseCase.call(
      UploadItemImagesParams(image: event.file),
    );

    result.fold(
      (l) => emit(state.copyWith(isLoading: false, isSuccess: false)),
      (r) {
        emit(state.copyWith(isLoading: false, isSuccess: true, imageName: r));
      },
    );
  }
}
