import 'dart:io';

import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/auth/data/data_source/auth_data_source.dart';
import 'package:circle_share/features/items/data/data_source/remote_data_source/item_remote_datasource.dart';
import 'package:circle_share/features/items/domain/entity/item_entity.dart';
import 'package:circle_share/features/items/domain/repository/item_repository.dart';
import 'package:dartz/dartz.dart';

class ItemRemoteRepository implements IItemRepository {
  final ItemRemoteDataSource remoteDataSource;
  final IAuthDataSource authDataSource;

  ItemRemoteRepository({
    required this.remoteDataSource,
    required this.authDataSource,
  });

  @override
  Future<Either<Failure, void>> addItem(ItemEntity item) async {
    try {
      await remoteDataSource.addItem(item);
      return Right(null);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> getItems() async {
    try {
      final items = await remoteDataSource.getAllItems();
      return Right(items);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ItemEntity>> getItemById(String itemId) async {
    try {
      final item = await remoteDataSource.getItemById(itemId);
      return Right(item);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteItem(String itemId) async {
    try {
      await remoteDataSource.deleteItem(itemId);
      return Right(null);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadItemImage(File image) async {
    try {
      final imageName = await remoteDataSource.uploadItemPicture(image);
      return Right(imageName);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateItem(ItemEntity item) async {
    try {
      await remoteDataSource.updateItem(item);
      return Right(null);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> getItemsByUser(
      String userId) async {
    try {
      final items = await remoteDataSource.getItemsByUser(userId);
      return Right(items);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> getItemsBorrowedByUser(
      String userId) async {
    try {
      final items = await remoteDataSource.getItemsBorrowedByUser(userId);
      return Right(items);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
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
      // Get all user items first
      final result = await getItemsByUser(userId);

      return result.fold(
        (failure) => Left(failure),
        (items) {
          // Apply filters
          var filteredItems = items;

          if (categoryId != null) {
            filteredItems = filteredItems
                .where((item) => item.categoryId == categoryId)
                .toList();
          }

          if (locationId != null) {
            filteredItems = filteredItems
                .where((item) => item.locationId == locationId)
                .toList();
          }

          if (availabilityStatus != null) {
            filteredItems = filteredItems
                .where((item) => item.availabilityStatus == availabilityStatus)
                .toList();
          }

          return Right(filteredItems);
        },
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> getCurrentUserItems() async {
    try {
      // Get current user
      final currentUser = await authDataSource.getCurrentUser();
      final userId = currentUser.userId;

      if (userId == null || userId.isEmpty) {
        return Left(ApiFailure(message: 'User not authenticated'));
      }

      return getItemsByUser(userId);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>>
      getCurrentUserBorrowedItems() async {
    try {
      // Get current user
      final currentUser = await authDataSource.getCurrentUser();
      final userId = currentUser.userId;

      if (userId == null || userId.isEmpty) {
        return Left(ApiFailure(message: 'User not authenticated'));
      }

      return getItemsBorrowedByUser(userId);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
