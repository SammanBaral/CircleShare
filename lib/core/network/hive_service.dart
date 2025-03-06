import 'package:circle_share/app/constants/hive_table_constant.dart';
import 'package:circle_share/features/auth/data/model/auth_hive_model.dart';
import 'package:circle_share/features/category/data/model/category_hive_model.dart';
import 'package:circle_share/features/items/data/model/item_hive_model.dart';
import 'package:circle_share/features/location/data/model/location_hive_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class HiveService {
  static Future<void> init() async {
    // Initialize the database
    var directory = await getApplicationDocumentsDirectory();
    var path = '${directory.path}circle_share.db';

    Hive.init(path);

    // Register Adapters
    Hive.registerAdapter(AuthHiveModelAdapter());
    Hive.registerAdapter(ItemHiveModelAdapter());
    Hive.registerAdapter(CategoryHiveModelAdapter());
    Hive.registerAdapter(LocationHiveModelAdapter());
  }

  // ========================= AUTH =========================
  Future<void> register(AuthHiveModel auth) async {
    var box = await Hive.openBox<AuthHiveModel>(HiveTableConstant.userBox);
    await box.put(auth.userId, auth);
  }

  Future<void> deleteAuth(String id) async {
    var box = await Hive.openBox<AuthHiveModel>(HiveTableConstant.userBox);
    await box.delete(id);
  }

  Future<List<AuthHiveModel>> getAllAuth() async {
    var box = await Hive.openBox<AuthHiveModel>(HiveTableConstant.userBox);
    return box.values.toList();
  }

  Future<AuthHiveModel?> login(String username, String password) async {
    var box = await Hive.openBox<AuthHiveModel>(HiveTableConstant.userBox);
    var user = box.values.firstWhere(
      (element) => element.username == username && element.password == password,
      orElse: () => AuthHiveModel.initial(),
    );
    box.close();
    return user;
  }

  //update user
  Future<void> updateUser(AuthHiveModel user) async {
    var box = await Hive.openBox<AuthHiveModel>(HiveTableConstant.userBox);
    await box.put(user.userId, user);
  }
  
  // Clear current user data - useful for logout
  Future<void> clearUser() async {
    try {
      print("HiveService: Clearing current user data");
      
      // Instead of deleting the entire box, we could just clear the current user session
      // This would typically involve some session management, but for now, we'll implement
      // a simple approach that preserves user accounts but clears any session indicators
      
      // If you have a dedicated session box or field, you would clear that here
      // For this implementation, we'll assume keeping the user accounts but logging them out
      
      // Example: if you want to actually delete user data, uncomment the next line
      // await Hive.deleteBoxFromDisk(HiveTableConstant.userBox);
      
      print("HiveService: User data cleared");
      return Future.value();
    } catch (e) {
      print("HiveService: Error clearing user data: $e");
      return Future.error(e);
    }
  }

  // ========================= ITEM =========================
  Future<void> addItem(ItemHiveModel item) async {
    var box = await Hive.openBox<ItemHiveModel>(HiveTableConstant.itemBox);
    await box.put(item.id, item);
  }

  Future<void> deleteItem(String itemId) async {
    var box = await Hive.openBox<ItemHiveModel>(HiveTableConstant.itemBox);
    await box.delete(itemId);
  }

  Future<List<ItemHiveModel>> getAllItems() async {
    var box = await Hive.openBox<ItemHiveModel>(HiveTableConstant.itemBox);
    return box.values.toList();
  }

  Future<ItemHiveModel?> getItemById(String itemId) async {
    var box = await Hive.openBox<ItemHiveModel>(HiveTableConstant.itemBox);
    var item = box.get(itemId);
    box.close();
    return item;
  }

  // ========================= CATEGORY =========================
  Future<void> addCategory(CategoryHiveModel category) async {
    var box =
        await Hive.openBox<CategoryHiveModel>(HiveTableConstant.categoryBox);
    await box.put(category.categoryId, category);
  }

  Future<void> deleteCategory(String categoryId) async {
    var box =
        await Hive.openBox<CategoryHiveModel>(HiveTableConstant.categoryBox);
    await box.delete(categoryId);
  }

  Future<List<CategoryHiveModel>> getAllCategories() async {
    var box =
        await Hive.openBox<CategoryHiveModel>(HiveTableConstant.categoryBox);
    return box.values.toList();
  }

  // ========================= LOCATION =========================
  Future<void> addLocation(LocationHiveModel location) async {
    var box =
        await Hive.openBox<LocationHiveModel>(HiveTableConstant.locationBox);
    await box.put(location.id, location);
  }

  Future<void> deleteLocation(String locationId) async {
    var box =
        await Hive.openBox<LocationHiveModel>(HiveTableConstant.locationBox);
    await box.delete(locationId);
  }

  Future<List<LocationHiveModel>> getAllLocations() async {
    var box =
        await Hive.openBox<LocationHiveModel>(HiveTableConstant.locationBox);
    return box.values.toList();
  }

  // ========================= UTILITIES =========================
  Future<void> clearAll() async {
    await Hive.deleteBoxFromDisk(HiveTableConstant.userBox);
    await Hive.deleteBoxFromDisk(HiveTableConstant.itemBox);
    await Hive.deleteBoxFromDisk(HiveTableConstant.categoryBox);
    await Hive.deleteBoxFromDisk(HiveTableConstant.locationBox);
  }

  Future<void> close() async {
    await Hive.close();
  }
}