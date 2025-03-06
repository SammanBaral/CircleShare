import 'package:circle_share/app/usecase/usecase.dart';
import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/items/domain/entity/item_entity.dart';
import 'package:circle_share/features/items/domain/repository/item_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// Use case for getting items created by a user
class GetUserItemsUseCase implements UsecaseWithParams<List<ItemEntity>, String> {
  final IItemRepository itemRepository;

  GetUserItemsUseCase({required this.itemRepository});

  @override
  Future<Either<Failure, List<ItemEntity>>> call(String userId) async {
    return itemRepository.getItemsByUser(userId);
  }
}

// Use case for getting items borrowed by a user
class GetBorrowedItemsUseCase implements UsecaseWithParams<List<ItemEntity>, String> {
  final IItemRepository itemRepository;

  GetBorrowedItemsUseCase({required this.itemRepository});

  @override
  Future<Either<Failure, List<ItemEntity>>> call(String userId) async {
    return itemRepository.getItemsBorrowedByUser(userId);
  }
}

// Parameters for getting a user's items with optional filters
class GetUserItemsParams extends Equatable {
  final String userId;
  final String? categoryId;
  final String? locationId;
  final String? availabilityStatus;

  const GetUserItemsParams({
    required this.userId,
    this.categoryId,
    this.locationId,
    this.availabilityStatus,
  });

  @override
  List<Object?> get props => [userId, categoryId, locationId, availabilityStatus];
}

// Use case for getting items with filters
class GetFilteredUserItemsUseCase implements UsecaseWithParams<List<ItemEntity>, GetUserItemsParams> {
  final IItemRepository itemRepository;

  GetFilteredUserItemsUseCase({required this.itemRepository});

  @override
  Future<Either<Failure, List<ItemEntity>>> call(GetUserItemsParams params) async {
    return itemRepository.getFilteredItemsByUser(
      params.userId,
      categoryId: params.categoryId,
      locationId: params.locationId,
      availabilityStatus: params.availabilityStatus,
    );
  }
}