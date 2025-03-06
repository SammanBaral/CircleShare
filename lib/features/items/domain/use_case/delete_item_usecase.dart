import 'package:circle_share/app/usecase/usecase.dart';
import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/items/domain/repository/item_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class DeleteItemParams extends Equatable {
  final String itemId;

  const DeleteItemParams({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}

class DeleteItemUseCase implements UsecaseWithParams<void, DeleteItemParams> {
  final IItemRepository itemRepository;

  DeleteItemUseCase({required this.itemRepository});

  @override
  Future<Either<Failure, void>> call(DeleteItemParams params) async {
    return await itemRepository.deleteItem(params.itemId);
  }
}
