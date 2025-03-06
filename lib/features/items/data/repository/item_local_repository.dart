import 'dart:io';

import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/auth/data/data_source/auth_data_source.dart';
import 'package:circle_share/features/items/data/data_source/item_data_source.dart';
import 'package:circle_share/features/items/domain/entity/item_entity.dart';
import 'package:circle_share/features/items/domain/repository/item_repository.dart';
import 'package:dartz/dartz.dart';

class ItemLocalRepository implements IItemRepository {
  final IItemDataSource _itemLocalDataSource;
  final IAuthDataSource _userDataSource; // Add user data source

  ItemLocalRepository(this._itemLocalDataSource, this._userDataSource);

  @override
  Future<Either<Failure, void>> addItem(ItemEntity item) async {
    try {
      await _itemLocalDataSource.addItem(item);
      return Right(null);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> getItems() async {
    try {
      final items = await _itemLocalDataSource.getAllItems();
      return Right(items);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  // Note: Your interface likely has been updated to use getAllItems instead of getItems

  @override
  Future<Either<Failure, void>> deleteItem(String itemId) async {
    try {
      await _itemLocalDataSource.deleteItem(itemId);
      return Right(null);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadItemImage(File file) async {
    // For local repository, uploading may not be supported.  }
    return Left(LocalDatabaseFailure(message: "Uploading not supported"));
  }

  @override
  Future<Either<Failure, ItemEntity>> getItemById(String itemId) async {
    try {
      final item = await _itemLocalDataSource.getItemById(itemId);
      if (item == null) {
        return Left(LocalDatabaseFailure(message: "Item not found"));
      }
      return Right(item);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateItem(ItemEntity item) async {
    try {
      // Assuming your data source has an updateItem method
      // If not, you'll need to implement it
      await _itemLocalDataSource.updateItem(item);
      return Right(null);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> getItemsByUser(
      String userId) async {
    try {
      // Filter all items by user ID
      final allItems = await _itemLocalDataSource.getAllItems();
      final userItems =
          allItems.where((item) => item.userId == userId).toList();
      return Right(userItems);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> getItemsBorrowedByUser(
      String userId) async {
    try {
      // Filter all items by borrower ID
      final allItems = await _itemLocalDataSource.getAllItems();
      final borrowedItems =
          allItems.where((item) => item.borrowerId == userId).toList();
      return Right(borrowedItems);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> getFilteredItemsByUser(
    String userId, {
    String? categoryId,
    String? locationId,
    String? availabilityStatus,
  }) async {
    try {
      // Get all items by user first
      final allItems = await _itemLocalDataSource.getAllItems();

      // Filter by user ID and other criteria
      final filteredItems = allItems.where((item) {
        // First check user ID match
        bool matchesUser = item.userId == userId;
        if (!matchesUser) return false;

        // Then check other filters if specified
        if (categoryId != null && item.categoryId != categoryId) return false;
        if (locationId != null && item.locationId != locationId) return false;
        if (availabilityStatus != null &&
            item.availabilityStatus != availabilityStatus) return false;

        // All filters passed
        return true;
      }).toList();

      return Right(filteredItems);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> getCurrentUserItems() async {
    try {
      // Get current user
      final currentUser = await _userDataSource.getCurrentUser();

      // Use the existing method
      return getItemsByUser(currentUser.userId!);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>>
      getCurrentUserBorrowedItems() async {
    try {
      // Get current user
      final currentUser = await _userDataSource.getCurrentUser();

      // Use the existing method
      return getItemsBorrowedByUser(currentUser.userId!);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
