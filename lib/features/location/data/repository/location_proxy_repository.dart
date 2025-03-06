import 'package:circle_share/core/common/internet_checker/connectivity_checker.dart';
import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/location/data/repository/location_local_repository.dart';
import 'package:circle_share/features/location/data/repository/location_remote_repository.dart';
import 'package:circle_share/features/location/domain/entity/location_entity.dart';
import 'package:circle_share/features/location/domain/repository/location_repository.dart';
import 'package:dartz/dartz.dart';

class LocationRepositoryProxy implements ILocationRepository {
  final ConnectivityListener connectivityListener;
  final LocationRemoteRepository remoteRepository;
  final LocationLocalRepository localRepository;

  LocationRepositoryProxy({
    required this.connectivityListener,
    required this.remoteRepository,
    required this.localRepository,
  });

  @override
  Future<Either<Failure, void>> addLocation(LocationEntity location) async {
    if (await connectivityListener.isConnected) {
      try {
        print("Connected to the internet");
        return await remoteRepository.addLocation(location);
      } catch (e) {
        print("Remote call failed, falling back to local storage");
        return await localRepository.addLocation(location);
      }
    } else {
      print("No internet, saving location locally");
      return await localRepository.addLocation(location);
    }
  }

  @override
  Future<Either<Failure, List<LocationEntity>>> getLocations() async {
    if (await connectivityListener.isConnected) {
      try {
        print("Connected to the internet");
        
        final locations = await remoteRepository.getLocations();
        // TODO: Consider saving to local storage for offline use
        return locations;
      } catch (e) {
        print("Remote call failed, falling back to local storage");
        return await localRepository.getLocations();
      }
    } else {
      print("No internet, retrieving locations from local storage");
      return await localRepository.getLocations();
    }
  }

  @override
  Future<Either<Failure, void>> deleteLocation(String locationId) async {
    if (await connectivityListener.isConnected) {
      try {
        print("Connected to the internet");
        return await remoteRepository.deleteLocation(locationId);
      } catch (e) {
        print("Remote call failed, falling back to local storage");
        return await localRepository.deleteLocation(locationId);
      }
    } else {
      print("No internet, deleting location locally");
      return await localRepository.deleteLocation(locationId);
    }
  }
}