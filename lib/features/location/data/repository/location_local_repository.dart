import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/location/data/data_source/location_data_source.dart';
import 'package:circle_share/features/location/domain/entity/location_entity.dart';
import 'package:circle_share/features/location/domain/repository/location_repository.dart';
import 'package:dartz/dartz.dart';

class LocationLocalRepository implements ILocationRepository {
  final ILocationDataSource _locationLocalDataSource;

  LocationLocalRepository(this._locationLocalDataSource);

  @override
  Future<Either<Failure, void>> addLocation(LocationEntity location) async {
    try {
      await _locationLocalDataSource.addLocation(location);
      return Right(null);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LocationEntity>>> getLocations() async {
    try {
      final locations = await _locationLocalDataSource.getAllLocations();
      return Right(locations);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLocation(String locationId) async {
    try {
      await _locationLocalDataSource.deleteLocation(locationId);
      return Right(null);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
