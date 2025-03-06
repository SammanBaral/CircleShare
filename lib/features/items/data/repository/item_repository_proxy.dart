import 'dart:io';

import 'package:circle_share/core/common/internet_checker/connectivity_checker.dart';
import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/items/data/repository/item_local_repository.dart';
import 'package:circle_share/features/items/data/repository/item_remote_repository.dart';
import 'package:circle_share/features/items/domain/entity/item_entity.dart';
import 'package:circle_share/features/items/domain/repository/item_repository.dart';
import 'package:dartz/dartz.dart';

class ItemRepositoryProxy implements IItemRepository {
  final ConnectivityListener connectivityListener;
  final ItemRemoteRepository remoteRepository;
  final ItemLocalRepository localRepository;

  ItemRepositoryProxy({
    required this.connectivityListener,
    required this.remoteRepository,
    required this.localRepository,
  });

  @override
  Future<Either<Failure, void>> addItem(ItemEntity item) async {
    if (await connectivityListener.isConnected) {
      try {
        print("Connected to the internet");
        return await remoteRepository.addItem(item);
      } catch (e) {
        print("Remote call failed, falling back to local storage");
        return await localRepository.addItem(item);
      }
    } else {
      print("No internet, saving item locally");
      return await localRepository.addItem(item);
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> getItems() async {
    try {
      bool isConnected = false;
      try {
        isConnected = await connectivityListener.isConnected;
        print("ConnectivityCheck result: $isConnected");
      } catch (e) {
        print("Error checking connectivity: $e");
        isConnected = false;
      }

      if (isConnected) {
        try {
          print("Connected to the internet, trying remote repository");
          final items = await remoteRepository.getItems();
          return items;
        } catch (e) {
          print("Remote error: $e");
          print("Error type: ${e.runtimeType}");
          print("Falling back to local repository");
          return await localRepository.getItems();
        }
      } else {
        print("No internet connection detected, using local repository");
        return await localRepository.getItems();
      }
    } catch (e) {
      print("Unexpected error in proxy: $e");
      // Still try local as a last resort
      try {
        return await localRepository.getItems();
      } catch (localError) {
        return Left(LocalDatabaseFailure(message: localError.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, ItemEntity>> getItemById(String itemId) async {
    if (await connectivityListener.isConnected) {
      try {
        print("Connected to the internet");
        return await remoteRepository.getItemById(itemId);
      } catch (e) {
        print("Remote call failed, falling back to local storage");
        return await localRepository.getItemById(itemId);
      }
    } else {
      print("No internet, retrieving item from local storage");
      return await localRepository.getItemById(itemId);
    }
  }

  @override
  Future<Either<Failure, void>> deleteItem(String itemId) async {
    if (await connectivityListener.isConnected) {
      try {
        print("Connected to the internet");
        return await remoteRepository.deleteItem(itemId);
      } catch (e) {
        print("Remote call failed, falling back to local storage");
        return await localRepository.deleteItem(itemId);
      }
    } else {
      print("No internet, deleting item locally");
      return await localRepository.deleteItem(itemId);
    }
  }

  @override
  Future<Either<Failure, String>> uploadItemImage(File file) async {
    if (await connectivityListener.isConnected) {
      try {
        print("Connected to the internet");
        return await remoteRepository.uploadItemImage(file);
      } catch (e) {
        print("Remote call failed, falling back to local storage");
        return await localRepository.uploadItemImage(file);
      }
    } else {
      print("No internet, can't upload image");
      return await localRepository.uploadItemImage(file);
    }
  }

  @override
  Future<Either<Failure, void>> updateItem(ItemEntity item) async {
    if (await connectivityListener.isConnected) {
      try {
        print("Connected to the internet");
        return await remoteRepository.updateItem(item);
      } catch (e) {
        print("Remote call failed, falling back to local storage");
        return await localRepository.updateItem(item);
      }
    } else {
      print("No internet, updating item locally");
      return await localRepository.updateItem(item);
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> getItemsByUser(
      String userId) async {
    if (await connectivityListener.isConnected) {
      try {
        print("Connected to the internet");
        return await remoteRepository.getItemsByUser(userId);
      } catch (e) {
        print("Remote call failed, falling back to local storage");
        return await localRepository.getItemsByUser(userId);
      }
    } else {
      print("No internet, retrieving items from local storage");
      return await localRepository.getItemsByUser(userId);
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> getItemsBorrowedByUser(
      String userId) async {
    if (await connectivityListener.isConnected) {
      try {
        print("Connected to the internet");
        return await remoteRepository.getItemsBorrowedByUser(userId);
      } catch (e) {
        print("Remote call failed, falling back to local storage");
        return await localRepository.getItemsBorrowedByUser(userId);
      }
    } else {
      print("No internet, retrieving borrowed items from local storage");
      return await localRepository.getItemsBorrowedByUser(userId);
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> getFilteredItemsByUser(
    String userId, {
    String? categoryId,
    String? locationId,
    String? availabilityStatus,
  }) async {
    if (await connectivityListener.isConnected) {
      try {
        print("Connected to the internet");
        return await remoteRepository.getFilteredItemsByUser(
          userId,
          categoryId: categoryId,
          locationId: locationId,
          availabilityStatus: availabilityStatus,
        );
      } catch (e) {
        print("Remote call failed, falling back to local storage");
        return await localRepository.getFilteredItemsByUser(
          userId,
          categoryId: categoryId,
          locationId: locationId,
          availabilityStatus: availabilityStatus,
        );
      }
    } else {
      print("No internet, retrieving filtered items from local storage");
      return await localRepository.getFilteredItemsByUser(
        userId,
        categoryId: categoryId,
        locationId: locationId,
        availabilityStatus: availabilityStatus,
      );
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> getCurrentUserItems() async {
    if (await connectivityListener.isConnected) {
      try {
        print("Connected to the internet");
        return await remoteRepository.getCurrentUserItems();
      } catch (e) {
        print("Remote call failed, falling back to local storage");
        return await localRepository.getCurrentUserItems();
      }
    } else {
      print("No internet, retrieving current user items from local storage");
      return await localRepository.getCurrentUserItems();
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>>
      getCurrentUserBorrowedItems() async {
    if (await connectivityListener.isConnected) {
      try {
        print("Connected to the internet");
        return await remoteRepository.getCurrentUserBorrowedItems();
      } catch (e) {
        print("Remote call failed, falling back to local storage");
        return await localRepository.getCurrentUserBorrowedItems();
      }
    } else {
      print(
          "No internet, retrieving current user borrowed items from local storage");
      return await localRepository.getCurrentUserBorrowedItems();
    }
  }
}
