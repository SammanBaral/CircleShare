import 'package:circle_share/features/location/domain/entity/location_entity.dart';

abstract interface class ILocationDataSource {
  Future<void> addLocation(LocationEntity location);

  Future<void> deleteLocation(String locationId);

  Future<List<LocationEntity>> getAllLocations();
}
