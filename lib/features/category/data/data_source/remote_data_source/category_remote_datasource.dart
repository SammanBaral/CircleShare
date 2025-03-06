import 'package:circle_share/app/constants/api_endpoints.dart';
import 'package:circle_share/features/category/data/data_source/category_data_source.dart';
import 'package:circle_share/features/category/domain/entity/category_entity.dart';
import 'package:dio/dio.dart';

class CategoryRemoteDataSource implements ICategoryDataSource {
  final Dio _dio;

  CategoryRemoteDataSource(this._dio);

  @override
  Future<void> addCategory(CategoryEntity category) async {
    try {
      Response response = await _dio.post(
        ApiEndpoints.createCategory,
        data: {
          "name": category.name,
        },
      );
      if (response.statusCode == 201) {
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
  Future<List<CategoryEntity>> getAllCategories() async {
    try {
      Response response = await _dio.get(ApiEndpoints.getAllCategories);
      if (response.statusCode == 200) {
        // Extract the data array from the response
        final Map<String, dynamic> responseData = response.data;
        final List<dynamic> categoriesJson = responseData['data'];

        // Convert each JSON object to a CategoryEntity
        final List<CategoryEntity> categories = categoriesJson
            .map((json) => CategoryEntity.fromJson(json))
            .toList();

        return categories;
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
  Future<void> deleteCategory(String categoryId) async {
    try {
      Response response =
          await _dio.delete("${ApiEndpoints.deleteCategory}$categoryId");
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
}
