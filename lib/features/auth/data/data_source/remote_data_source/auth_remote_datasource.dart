import 'dart:io';

import 'package:circle_share/app/constants/api_endpoints.dart';
import 'package:circle_share/app/shared_prefs/token_shared_prefs.dart'; // Import token shared prefs
import 'package:circle_share/features/auth/data/data_source/auth_data_source.dart';
import 'package:circle_share/features/auth/domain/entity/auth_entity.dart';
import 'package:dio/dio.dart';

class AuthRemoteDataSource implements IAuthDataSource {
  final Dio _dio;
  final TokenSharedPrefs _tokenPrefs; // Add token prefs for authentication

  AuthRemoteDataSource(this._dio, this._tokenPrefs);

  @override
  Future<void> registerUser(AuthEntity user) async {
    try {
      Response response = await _dio.post(
        ApiEndpoints.register,
        data: {
          "fname": user.fName,
          "lname": user.lName,
          "phone": user.phone,
          "image": user.image,
          "username": user.username,
          "password": user.password,
        },
      );

      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception(response.statusMessage);
      }
    } on DioException catch (e) {
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<AuthEntity> getCurrentUser() async {
    try {
      // Get token from shared preferences
      final tokenResult = await _tokenPrefs.getToken();
      late String token;

      tokenResult.fold(
        (failure) {
          throw Exception("Authentication token not found");
        },
        (value) {
          token = value;
        },
      );

      if (token.isEmpty) {
        throw Exception("Authentication token is empty");
      }

      // Make API call to get current user profile
      Response response = await _dio.get(
        ApiEndpoints.getMe,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        // The user data is directly in the response body, not in a "data" field
        final userData = response.data;

        if (userData == null) {
          throw Exception("No user data received from server");
        }

        // Create and return AuthEntity from response data
        return AuthEntity(
          userId: userData['_id'],
          fName: userData['fname'] ?? "",
          lName: userData['lname'] ?? "",
          username: userData['username'] ?? "",
          phone: userData['phone'] ?? "",
          image: userData['image'],
          // Don't include password in returned data for security
          password: '',
        );
      } else {
        throw Exception(response.statusMessage ?? "Failed to get user profile");
      }
    } on DioException catch (e) {
      print("Error fetching current user: ${e.message}");
      if (e.response?.statusCode == 401) {
        throw Exception(
            "Authentication expired or invalid. Please log in again.");
      }
      throw Exception("Failed to get current user: ${e.message}");
    } catch (e) {
      print("Error in getCurrentUser: $e");
      throw Exception("Failed to get current user: $e");
    }
  }

  @override
  Future<String> loginUser(String username, String password) async {
    try {
      Response response = await _dio.post(
        ApiEndpoints.login,
        data: {
          "username": username,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        final str = response.data['token'];
        return str;
      } else {
        throw Exception(response.statusMessage);
      }
    } on DioException catch (e) {
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<String> uploadProfilePicture(File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap(
        {
          'profilePicture': await MultipartFile.fromFile(
            file.path,
            filename: fileName,
          ),
        },
      );

      Response response = await _dio.post(
        ApiEndpoints.uploadImage,
        data: formData,
      );

      if (response.statusCode == 200) {
        // Extract the image name from the response
        final str = response.data['data'];

        return str;
      } else {
        throw Exception(response.statusMessage);
      }
    } on DioException catch (e) {
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }

  //update user
  Future<void> updateUser(String userId, AuthEntity user) async {
    try {
      Response response = await _dio.put(
        ApiEndpoints.updateUser + userId,
        data: {
          "fname": user.fName,
          "lname": user.lName,
          "phone": user.phone,
          "username": user.username,
          // Only include image if it exists and isn't empty
          if (user.image != null && user.image!.isNotEmpty) "image": user.image,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(response.statusMessage);
      }
    } on DioException catch (e) {
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }
}
