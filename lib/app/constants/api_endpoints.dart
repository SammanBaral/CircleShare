class ApiEndpoints {
  ApiEndpoints._();
  static const Duration connectionTimeout = Duration(seconds: 1000);
  static const Duration recieveTimeout = Duration(seconds: 1000);
  static const String baseUrl = "http://10.0.2.2:3000/api/";
  // static const String baseUrl = "http://192.168.254.21:3000/api/";

  // ====================== Auth Routes ======================
  static const String login = "auth/login";
  static const String register = "auth/register";
  static const String getAllUser = "auth/getAllUsers";
  static const String updateUser = "auth/updateUser/";
  static const String deleteUser = "auth/deleteUser/";
  static const String imageUrl = "http://10.0.2.2:3000/uploads/";
  static const String uploadImage = "auth/uploadImage";
  static const String getMe = "auth/getMe";

  // ====================== Item Routes ======================
  static const String createItem = "items/createItem";
  static const String getAllItems = "items/getAllItems";
  static const String getItemById = "items/";
  static const String updateItem = "items/updateItem/";
  static const String deleteItem = "items/deleteItem/";
  static const String uploadItemImage = "items/uploadImage";
  static const String ItemimageUrl =
      "http://10.0.2.2:3000/public/uploads/items/";

  // Add these new endpoints
  static const String getUserItems = "items/user/"; // Add /:userId in code
  static const String getBorrowedItems =
      "items/borrowed/"; // Add /:userId in code

  // ====================== Category Routes ======================
  static const String createCategory = "categories/createCategory";
  static const String getAllCategories = "categories/getAllCategories";
  static const String getCategoryById = "categories/";
  static const String updateCategory = "categories/updateCategory/";
  static const String deleteCategory = "categories/deleteCategory/";

  // ====================== Location Routes ======================
  static const String createLocation = "locations/createLocation";
  static const String getAllLocations = "locations/getAllLocations";
  static const String getLocationById = "locations/";
  static const String updateLocation = "locations/updateLocation/";
  static const String deleteLocation = "locations/deleteLocation/";
}
