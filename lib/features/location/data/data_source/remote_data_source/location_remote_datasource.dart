import 'package:circle_share/app/constants/api_endpoints.dart';
import 'package:circle_share/features/location/data/data_source/location_data_source.dart';
import 'package:circle_share/features/location/domain/entity/location_entity.dart';
import 'package:dio/dio.dart';

class LocationRemoteDataSource implements ILocationDataSource {
  final Dio _dio;

  LocationRemoteDataSource(this._dio);

  @override
  Future<void> addLocation(LocationEntity location) async {
    try {
      Response response = await _dio.post(
        ApiEndpoints.createLocation,
        data: {
          "name": location.name,
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
  Future<List<LocationEntity>> getAllLocations() async {
    try {
      Response response = await _dio.get(ApiEndpoints.getAllLocations);
      if (response.statusCode == 200) {
        // Extract the data array from the response
        final Map<String, dynamic> responseData = response.data;
        final List<dynamic> locationsJson = responseData['data'];
        
        // Convert each JSON object to a LocationEntity
        final List<LocationEntity> locations = locationsJson
            .map((json) => LocationEntity.fromJson(json))
            .toList();
            
        return locations;
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
  Future<void> deleteLocation(String locationId) async {
    try {
      Response response =
          await _dio.delete("${ApiEndpoints.deleteLocation}$locationId");
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