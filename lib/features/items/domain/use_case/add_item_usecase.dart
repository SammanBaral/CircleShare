import 'package:circle_share/app/usecase/usecase.dart';
import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/items/domain/entity/item_entity.dart';
import 'package:circle_share/features/items/domain/repository/item_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class AddItemParams extends Equatable {
  final String name;
  final String categoryId;
  final String description;
  final String availabilityStatus;
  final String locationId;
  final String?
      userId; // Changed to optional since it will be set by the repository
  final String?
      borrowerId; // Changed to optional since not all items have borrowers initially
  final String? imageName;
  final String rulesNotes;
  final double price;
  final String condition;
  final int maxBorrowDuration;

  const AddItemParams({
    required this.name,
    required this.categoryId,
    required this.description,
    required this.availabilityStatus,
    required this.locationId,
    this.userId, // Made optional
    this.borrowerId, // Made optional
    this.imageName,
    required this.rulesNotes,
    required this.price,
    required this.condition,
    required this.maxBorrowDuration,
  });

  const AddItemParams.initial({
    required this.name,
    required this.categoryId,
    required this.description,
    required this.availabilityStatus,
    required this.locationId,
    this.userId, // Made optional
    this.borrowerId, // Made optional
    required this.imageName,
    required this.rulesNotes,
    required this.price,
    required this.condition,
    required this.maxBorrowDuration,
  });

  @override
  List<Object?> get props => [
        name,
        categoryId,
        description,
        availabilityStatus,
        locationId,
        userId,
        borrowerId,
        imageName,
        rulesNotes,
        price,
        condition,
        maxBorrowDuration,
      ];
}

class AddItemUseCase implements UsecaseWithParams<void, AddItemParams> {
  final IItemRepository itemRepository;

  AddItemUseCase({required this.itemRepository});

  @override
  Future<Either<Failure, void>> call(AddItemParams params) async {
    final itemEntity = ItemEntity(
      name: params.name,
      categoryId: params.categoryId,
      description: params.description,
      availabilityStatus: params.availabilityStatus,
      locationId: params.locationId,
      userId: params.userId, // Pass userId
      borrowerId: params.borrowerId,
      imageName: params.imageName,
      rulesNotes: params.rulesNotes,
      price: params.price,
      condition: params.condition,
      maxBorrowDuration: params.maxBorrowDuration,
    );
    return itemRepository.addItem(itemEntity);
  }
}
