import 'package:dartz/dartz.dart';
import 'package:circle_share/app/usecase/usecase.dart';
import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/items/domain/entity/item_entity.dart';
import 'package:circle_share/features/items/domain/repository/item_repository.dart';

class GetAllItemsUseCase implements UsecaseWithoutParams<List<ItemEntity>> {
  final IItemRepository itemRepository;

  GetAllItemsUseCase({required this.itemRepository});

  @override
  Future<Either<Failure, List<ItemEntity>>> call() async {
    return await itemRepository.getItems();
  }
}
