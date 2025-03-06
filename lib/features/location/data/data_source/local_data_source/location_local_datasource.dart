import 'package:circle_share/core/network/hive_service.dart';
import 'package:circle_share/features/location/data/data_source/location_data_source.dart';
import 'package:circle_share/features/location/data/model/location_hive_model.dart';
import 'package:circle_share/features/location/domain/entity/location_entity.dart';
import 'package:uuid/uuid.dart';

class LocationLocalDataSource implements ILocationDataSource {
  final HiveService _hiveService;
  final _uuid = Uuid();

  LocationLocalDataSource(this._hiveService) {
    _initPredefinedLocations();
  }

  // Initialize predefined locations if none exist
  Future<void> _initPredefinedLocations() async {
    try {
      final existingLocations = await _hiveService.getAllLocations();

      // Only add predefined locations if the box is empty
      if (existingLocations.isEmpty) {
        final predefinedLocations = [
          LocationEntity(
            id: _uuid.v4(),
            name: 'Kathmandu',
          ),
          LocationEntity(
            id: _uuid.v4(),
            name: 'Jhapa',
          ),
          LocationEntity(
            id: _uuid.v4(),
            name: 'Lalitpur',
          ),
          LocationEntity(
            id: _uuid.v4(),
            name: 'Bhaktapur',
          ),
          LocationEntity(
            id: _uuid.v4(),
            name: 'Garage',
          ),
        ];

        // Add each predefined location
        for (final location in predefinedLocations) {
          final locationHiveModel = LocationHiveModel.fromEntity(location);
          await _hiveService.addLocation(locationHiveModel);
        }

        print('Added ${predefinedLocations.length} predefined locations');
      }
    } catch (e) {
      print('Error initializing predefined locations: $e');
    }
  }

  @override
  Future<void> addLocation(LocationEntity location) async {
    try {
      final locationHiveModel = LocationHiveModel.fromEntity(location);
      await _hiveService.addLocation(locationHiveModel);
      return Future.value();
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<void> deleteLocation(String locationId) async {
    try {
      await _hiveService.deleteLocation(locationId);
      return Future.value();
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<List<LocationEntity>> getAllLocations() async {
    try {
      final locations = await _hiveService.getAllLocations();
      return locations.map((e) => e.toEntity()).toList();
    } catch (e) {
      return Future.error(e);
    }
  }
}
