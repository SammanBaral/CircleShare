import 'dart:io';

import 'package:circle_share/app/constants/api_endpoints.dart';
import 'package:circle_share/app/shared_prefs/token_shared_prefs.dart';
import 'package:circle_share/features/auth/data/data_source/auth_data_source.dart';
import 'package:circle_share/features/items/data/data_source/item_data_source.dart';
import 'package:circle_share/features/items/data/model/item_api_model.dart';
import 'package:circle_share/features/items/domain/entity/item_entity.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class ItemRemoteDataSource implements IItemDataSource {
  final Dio _dio;
  final TokenSharedPrefs _tokenPrefs;
  final IAuthDataSource _userDataSource; // Add user data source

  ItemRemoteDataSource({
    required Dio dio,
    required TokenSharedPrefs tokenPrefs,
    required IAuthDataSource userDataSource, // Add this parameter
  })  : _dio = dio,
        _tokenPrefs = tokenPrefs,
        _userDataSource = userDataSource;

  @override
  Future<void> addItem(ItemEntity item) async {
    try {
      // Get current user ID
      final currentUserId = await _getCurrentUserId();

      if (currentUserId == null) {
        throw Exception("User must be logged in to create an item");
      }

      // Create a map for the request data
      Map<String, dynamic> data = {
        "name": item.name,
        "categoryId": item.categoryId,
        "locationId": item.locationId,
        "userId": currentUserId, // Add the current user's ID
        "description": item.description,
        "availabilityStatus": item.availabilityStatus,
        "imageName": item.imageName,
        "rulesNotes": item.rulesNotes,
        "price": item.price,
        "condition": item.condition,
        "maxBorrowDuration": item.maxBorrowDuration,
      };

      // Only add borrowerId if it's not null and not empty
      if (item.borrowerId != null && item.borrowerId!.isNotEmpty) {
        data["borrowerId"] = item.borrowerId;
      }

      // Get token for authorization
      final tokenResult = await _tokenPrefs.getToken();
      String? token;
      tokenResult.fold(
        (failure) {
          print('Failed to get token: ${failure.message}');
          throw Exception("Authorization required to create item");
        },
        (tokenValue) {
          token = tokenValue;
        },
      );

      // Set authorization header
      Options options = Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      Response response = await _dio.post(
        ApiEndpoints.createItem,
        data: data,
        options: options,
      );

      if (response.statusCode != 201) {
        throw Exception(response.statusMessage);
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? "Failed to add item");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Helper method to get current user ID
  Future<String?> _getCurrentUserId() async {
    try {
      final user = await _userDataSource.getCurrentUser();
      return user.userId;
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
    }
  }

  @override
  Future<List<ItemEntity>> getAllItems() async {
    try {
      Response response = await _dio.get(ApiEndpoints.getAllItems);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data
            .map((json) => ItemApiModel.fromJson(json).toEntity())
            .toList();
      } else {
        throw Exception(response.statusMessage);
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? "Failed to fetch items");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // New method to get items by user ID
  Future<List<ItemEntity>> getItemsByUser(String userId) async {
    try {
      Response response =
          await _dio.get("${ApiEndpoints.baseUrl}items/user/$userId");

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data
            .map((json) => ItemApiModel.fromJson(json).toEntity())
            .toList();
      } else {
        throw Exception(response.statusMessage);
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? "Failed to fetch user items");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // New method to get items borrowed by user
  Future<List<ItemEntity>> getItemsBorrowedByUser(String userId) async {
    try {
      Response response =
          await _dio.get("${ApiEndpoints.baseUrl}items/borrowed/$userId");

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data
            .map((json) => ItemApiModel.fromJson(json).toEntity())
            .toList();
      } else {
        throw Exception(response.statusMessage);
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? "Failed to fetch borrowed items");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<ItemEntity> getItemById(String itemId) async {
    try {
      Response response = await _dio.get("${ApiEndpoints.getItemById}$itemId");

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null) {
          return ItemApiModel.fromJson(data).toEntity();
        }
      }
      throw Exception("Item not found"); // Ensure a non-null return
    } on DioException catch (e) {
      throw Exception(e.message ?? "Failed to fetch item");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> deleteItem(String itemId) async {
    try {
      // Get token for authorization
      final tokenResult = await _tokenPrefs.getToken();
      String? token;
      tokenResult.fold(
        (failure) {
          print('Failed to get token: ${failure.message}');
          throw Exception("Authorization required to delete item");
        },
        (tokenValue) {
          token = tokenValue;
        },
      );

      // Set authorization header
      Options options = Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      Response response = await _dio.delete(
        "${ApiEndpoints.deleteItem}$itemId",
        options: options,
      );

      if (response.statusCode != 200) {
        throw Exception(response.statusMessage);
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? "Failed to delete item");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<String> uploadItemPicture(File file) async {
    try {
      // Get the file extension to determine content type
      String fileName = file.path.split('/').last;
      String extension = fileName.split('.').last.toLowerCase();

      // Determine the MIME type based on file extension
      String mimeType = 'image/jpeg'; // Default
      if (extension == 'png') {
        mimeType = 'image/png';
      } else if (extension == 'gif') {
        mimeType = 'image/gif';
      }

      // Get token for authorization if not already handled by interceptor
      final tokenResult = await _tokenPrefs.getToken();
      String? token;
      tokenResult.fold(
        (failure) {
          print('Failed to get token: ${failure.message}');
        },
        (tokenValue) {
          token = tokenValue;
        },
      );

      // Create form data with appropriate content type
      FormData formData = FormData.fromMap({
        'itemPicture': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      });

      // Set the proper Content-Type header for multipart/form-data and add auth token
      Options options = Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          if (token != null && token!.isNotEmpty)
            'Authorization': 'Bearer $token', // Add authorization header
        },
      );

      // Log the request for debugging
      print('Uploading item image to: ${ApiEndpoints.uploadItemImage}');
      print('File name: $fileName');
      print('Token present: ${token != null && token!.isNotEmpty}');

      Response response = await _dio.post(
        ApiEndpoints.uploadItemImage,
        data: formData,
        options: options,
      );

      // Log the response for debugging
      print('Upload response status: ${response.statusCode}');
      print('Upload response data: ${response.data}');

      if (response.statusCode == 200) {
        // Make sure to access the correct field in the response
        final filename = response.data['data'];
        if (filename == null) {
          throw Exception("Server did not return a filename");
        }
        return filename;
      } else {
        throw Exception(
            response.statusMessage ?? "Unknown error during upload");
      }
    } on DioException catch (e) {
      print("Dio Error: ${e.message}");
      print("Response: ${e.response?.data}");
      print("Error type: ${e.type}");
      print("Request: ${e.requestOptions.uri}");
      throw Exception(e.message ?? "Failed to upload item image");
    } catch (e) {
      print("General Error during upload: $e");
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> updateItem(ItemEntity item) async {
    try {
      // Get current user ID
      final currentUserId = await _getCurrentUserId();

      if (currentUserId == null) {
        throw Exception("User must be logged in to update an item");
      }

      // Create a map for the request data
      Map<String, dynamic> data = {
        "name": item.name,
        "categoryId": item.categoryId,
        "locationId": item.locationId,
        "userId": currentUserId, // Add the current user's ID
        "description": item.description,
        "availabilityStatus": item.availabilityStatus,
        "imageName": item.imageName,
        "rulesNotes": item.rulesNotes,
        "price": item.price,
        "condition": item.condition,
        "maxBorrowDuration": item.maxBorrowDuration,
      };

      // Only add borrowerId if it's not null and not empty
      if (item.borrowerId != null && item.borrowerId!.isNotEmpty) {
        data["borrowerId"] = item.borrowerId;
      }

      // Get token for authorization
      final tokenResult = await _tokenPrefs.getToken();
      String? token;
      tokenResult.fold(
        (failure) {
          print('Failed to get token: ${failure.message}');
          throw Exception("Authorization required to update item");
        },
        (tokenValue) {
          token = tokenValue;
        },
      );

      // Set authorization header
      Options options = Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      Response response = await _dio.put(
        "${ApiEndpoints.updateItem}${item.id}",
        data: data,
        options: options,
      );

      if (response.statusCode != 200) {
        throw Exception(response.statusMessage);
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? "Failed to update item");
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
