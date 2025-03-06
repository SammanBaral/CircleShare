import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/location/domain/entity/location_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class ILocationRepository {
  Future<Either<Failure, void>> addLocation(LocationEntity location);

  Future<Either<Failure, List<LocationEntity>>> getLocations();

  Future<Either<Failure, void>> deleteLocation(String locationId);
}
