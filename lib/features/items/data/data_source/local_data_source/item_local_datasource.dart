import 'dart:io';

import 'package:circle_share/core/network/hive_service.dart';
import 'package:circle_share/features/items/data/data_source/item_data_source.dart';
import 'package:circle_share/features/items/data/model/item_hive_model.dart';
import 'package:circle_share/features/items/domain/entity/item_entity.dart';

class ItemLocalDataSource implements IItemDataSource {
  final HiveService _hiveService;

  ItemLocalDataSource(this._hiveService);

  @override
  Future<void> addItem(ItemEntity item) async {
    try {
      print(
          'ItemLocalDataSource: Adding item to Hive - ${item.id} - ${item.name}');
      final itemHiveModel = ItemHiveModel.fromEntity(item);
      await _hiveService.addItem(itemHiveModel);
      print('ItemLocalDataSource: Item added successfully to Hive');
    } catch (e) {
      print('ItemLocalDataSource: Error adding item to Hive - $e');
      return Future.error(e);
    }
  }

  @override
  Future<void> deleteItem(String itemId) async {
    try {
      print('ItemLocalDataSource: Deleting item from Hive - $itemId');
      await _hiveService.deleteItem(itemId);
      print('ItemLocalDataSource: Item deleted successfully from Hive');
    } catch (e) {
      print('ItemLocalDataSource: Error deleting item from Hive - $e');
      return Future.error(e);
    }
  }

  @override
  Future<List<ItemEntity>> getAllItems() async {
    try {
      print('ItemLocalDataSource: Getting all items from Hive');
      final items = await _hiveService.getAllItems();
      print('ItemLocalDataSource: Retrieved ${items.length} items from Hive');

      // Debug: print each item
      for (var item in items) {
        print(
            'ItemLocalDataSource: Item from Hive - ${item.id} - ${item.name}');
      }

      final entityList = items.map((e) => e.toEntity()).toList();
      print(
          'ItemLocalDataSource: Converted ${entityList.length} Hive models to entities');

      return entityList;
    } catch (e) {
      print('ItemLocalDataSource: Error getting items from Hive - $e');
      return Future.error(e);
    }
  }

  @override
  Future<ItemEntity?> getItemById(String itemId) async {
    try {
      print('ItemLocalDataSource: Getting item by ID from Hive - $itemId');
      final item = await _hiveService.getItemById(itemId);

      if (item != null) {
        print(
            'ItemLocalDataSource: Item found in Hive - ${item.id} - ${item.name}');
        return item.toEntity();
      } else {
        print('ItemLocalDataSource: No item found with ID - $itemId');
        return null;
      }
    } catch (e) {
      print('ItemLocalDataSource: Error getting item by ID from Hive - $e');
      return Future.error(e);
    }
  }

  @override
  Future<String> uploadItemPicture(File file) async {
    print('ItemLocalDataSource: Upload not supported in local data source');
    return Future.error("Upload not supported in local data source");
  }

  @override
  Future<void> updateItem(ItemEntity item) async {
    try {
      // For Hive, update is the same as add (it will overwrite existing items)
      print(
          'ItemLocalDataSource: Updating item in Hive - ${item.id} - ${item.name}');
      final itemHiveModel = ItemHiveModel.fromEntity(item);
      await _hiveService.addItem(itemHiveModel);
      print('ItemLocalDataSource: Item updated successfully in Hive');
    } catch (e) {
      print('ItemLocalDataSource: Error updating item in Hive - $e');
      return Future.error(e);
    }
  }

  // Add a debug method to check Hive contents directly
  Future<void> debugPrintAllItems() async {
    try {
      print('-------- HIVE DEBUG --------');
      final items = await _hiveService.getAllItems();
      print('Total items in Hive: ${items.length}');

      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        print(
            'Item $i: ID=${item.id}, Name=${item.name}, Category=${item.categoryId}');
      }
      print('----------------------------');
    } catch (e) {
      print('Error debugging Hive: $e');
    }
  }
}
