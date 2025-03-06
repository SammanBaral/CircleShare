import 'dart:io';

import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/items/domain/entity/item_entity.dart';
import 'package:dartz/dartz.dart';

abstract class IItemRepository {
  // Basic CRUD operations
  Future<Either<Failure, void>> addItem(ItemEntity item);
  Future<Either<Failure, List<ItemEntity>>> getItems();
  Future<Either<Failure, ItemEntity>> getItemById(String itemId);
  Future<Either<Failure, void>> updateItem(ItemEntity item);
  Future<Either<Failure, void>> deleteItem(String itemId);
  
  // Image upload
  Future<Either<Failure, String>> uploadItemImage(File image);
  
  // User-specific item operations
  Future<Either<Failure, List<ItemEntity>>> getItemsByUser(String userId);
  Future<Either<Failure, List<ItemEntity>>> getItemsBorrowedByUser(String userId);
  
  // Filtered user items
  Future<Either<Failure, List<ItemEntity>>> getFilteredItemsByUser(
    String userId, {
    String? categoryId,
    String? locationId,
    String? availabilityStatus,
  });
  
  // Optional: Get current user's items (convenience method)
  Future<Either<Failure, List<ItemEntity>>> getCurrentUserItems();
  
  // Optional: Get items currently borrowed by the current user
  Future<Either<Failure, List<ItemEntity>>> getCurrentUserBorrowedItems();
}