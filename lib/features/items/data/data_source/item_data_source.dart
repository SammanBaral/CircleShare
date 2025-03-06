import 'dart:io';

import 'package:circle_share/features/items/domain/entity/item_entity.dart';

abstract interface class IItemDataSource {
  Future<void> addItem(ItemEntity item);

  Future<void> deleteItem(String itemId);
  Future<ItemEntity?> getItemById(String itemId);

  Future<List<ItemEntity>> getAllItems();

  Future<String> uploadItemPicture(File file);

  Future<void> updateItem(ItemEntity item);
}
